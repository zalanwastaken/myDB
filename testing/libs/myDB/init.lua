local function getScriptFolder()
    return(debug.getinfo(1, "S").source:sub(2):match("(.*/)"))
end
--local json = require(getScriptFolder().."/json/json")
local json = require("libs.myDB.json.json") --* Provides json.encode and json.decode
local function idgen(length)
    local chars = {
        --* Small chars
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", 
        "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        --* Capital chars
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", 
        "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        --* Numbers
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        --* Special chars
        "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_", "=", "+", 
        "{", "}", "[", "]", ":", ";", "'", "<", ">", ",", ".", "?", "/"
    }
    local ret = ""
    for i = 1, length, 1 do
        ret = ret..chars[love.math.random(1, #chars)]
    end
    return(ret)
end
local function contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end
local function isArray(tbl)
    local maxIndex = 0
    local count = 0
    for k, _ in pairs(tbl) do
        if type(k) == "number" then
            maxIndex = math.max(maxIndex, k)
            count = count + 1
        else
            return false -- Found a non-numeric key, so it's not an array
        end
    end
    return maxIndex == count -- Ensure there are no gaps in numeric keys
end
local function mergeDicts(t1, t2)
    if isArray(t1) and isArray(t2) then
        -- Both are arrays; concatenate them
        local result = {}
        for _, v in ipairs(t1) do
            table.insert(result, v)
        end
        for _, v in ipairs(t2) do
            table.insert(result, v)
        end
        return result
    else
        -- Treat as dictionaries and merge
        local result = {}
        for k, v in pairs(t1) do
            result[k] = v
        end
        for k, v in pairs(t2) do
            result[k] = v
        end
        return result
    end
end
local function getdbinfo(dbname)
    if love.filesystem.getInfo(dbname) then
        return(json.decode(love.filesystem.read(dbname.."/info.json")))
    else
        return(nil)
    end
end
local function savedbinfo(dbname, info)
    if love.filesystem.getInfo(dbname) then
        love.filesystem.write(dbname.."/info.json", json.encode(info))
    end
end
function removeFileExtension(filename)
    return filename:match("(.+)%.[^%.]+$") or filename
end
function isJsonFile(filename)
    return filename:lower():match("%.json$") ~= nil
end
local myDBInternal = {
    __VER__ = "INF_DEV"
}
local myDB = {
    __VER__ = myDBInternal.__VER__,
    db = {
        createDB = function(name)
            if not(love.filesystem.getInfo(name)) then
                love.filesystem.createDirectory(name)
                love.filesystem.newFile(name.."info.json")
                love.filesystem.write(name.."/info.json", json.encode({
                    name = name,
                    id = idgen(16),
                    TOC = os.date(), --? Time of creation
                    VER = myDBInternal.__VER__,
                    tables = {}
                }))
            else
                error("DB already exists")
            end
        end,
        createTable = function(dbname, tablename, data)
            if love.filesystem.getInfo(dbname) then
                local dbinfo = json.decode(love.filesystem.read(dbname.."/info.json"))
                print(dbinfo)
                if type(data):lower() == "table" then
                    if not(contains(dbinfo["tables"], tablename)) then
                        love.filesystem.newFile(dbname.."/"..tablename..".json")
                        love.filesystem.write(dbname.."/"..tablename..".json", json.encode(data))
                        dbinfo["tables"][#dbinfo["tables"] + 1] = tablename
                        love.filesystem.write(dbname.."/info.json", json.encode(dbinfo))
                    else
                        error("Table already exists !")
                    end
                end
            end
        end,
        getTableData = function(dbname, tablename)
            if love.filesystem.getInfo(dbname) then
                local dbinfo = json.decode(love.filesystem.read(dbname.."/info.json"))
                if contains(dbinfo.tables, tablename) then
                    return(json.decode(love.filesystem.read(dbname.."/"..tablename..".json")))
                end
            end
        end,
        getdbInfo = function(dbname)
            if love.filesystem.getInfo(dbname) then
                return(json.decode(love.filesystem.read(dbname.."/info.json")))
            end
        end,
        modifyTable = function(dbname, tablename, data)
            if love.filesystem.getInfo(dbname) then
                local dbinfo = json.decode(love.filesystem.read(dbname.."/info.json"))
                if contains(dbinfo["tables"], tablename) then
                    love.filesystem.write(dbname.."/"..tablename..".json", json.encode(mergeDicts(json.decode(love.filesystem.read(dbname.."/"..tablename..".json")), data)))
                end
            end
        end,
        tableExists = function(dbname, tablename)
            if love.filesystem.getInfo(dbname) then
                if love.filesystem.getInfo(dbname.."/"..tablename..".json") then
                    return(true)
                else
                    return(false)
                end
            end
        end,
        dbExists = function(dbname)
            if love.filesystem.getInfo(dbname) then
                return(true)
            else
                return(false)
            end
        end,
        createStructTable = function(dbname, tablename, struct)
            local info = getdbinfo(dbname)
            if info ~= nil then
                if contains(info.tables, tablename) ~= true then
                    info.tables[#info.tables + 1] = tablename
                    savedbinfo(dbname, info)
                    love.filesystem.newFile(dbname.."/"..tablename..".json")
                    struct = {struct=struct}
                    print(json.encode(struct))
                    love.filesystem.write(dbname.."/"..tablename..".json", json.encode(struct))
                else
                    error("Table "..tablename.." already exists")
                end
            end
        end,
        addStructData = function(dbname, tablename, vals)
            local info = getdbinfo(dbname)
            --TODO
        end
    },
    json = {
        --? Provided by the json lib
        encode = json.encode,
        decode = json.decode
    },
    fs = {
        removeDbFile = function(dbname, file) --! Does NOT update the DB info use with care
            if love.filesystem.getInfo(dbname) then
                if love.filesystem.getInfo(dbname.."/"..file) then
                    love.filesystem.remove(dbname.."/"..file)
                end
            end
        end,
        fixTableInfo = function(dbname)
            local info = getdbinfo(dbname)
            if info ~= nil then
                local files = love.filesystem.getDirectoryItems(dbname)
                info.tables = {}
                for i = 1, #files, 1 do
                    if files[i] ~= "info.json" and isJsonFile(files[i]) then
                        info.tables[#info.tables + 1] = removeFileExtension(files[i])
                    end
                end
                savedbinfo(dbname, info)
            end
        end
    }
}
return(myDB)
