--[[
Copyright (c) 2024 zalanwastaken(Mudit Mishra)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

1. Redistributions of source code must retain the above copyright notice, this list of conditions, and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions, and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the authors nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
--* IMPORTANT STUFF
local function getScriptFolder()
    return(debug.getinfo(1, "S").source:sub(2):match("(.*/)"))
end
--local json = require(getScriptFolder().."/json/json") --* Provides json.encode and json.decode
local json = require("libs.myDB.json.json") --* Provides json.encode and json.decode
--* FUNCS
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
local function removeFileExtension(filename)
    return filename:match("(.+)%.[^%.]+$") or filename
end
local function isJsonFile(filename)
    return filename:lower():match("%.json$") ~= nil
end
local function getKeys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    return(keys)
end
--* CODE
local myDBInternal = {
    __VER__ = "1.0.0"
}
local myDB = {
    __VER__ = myDBInternal.__VER__,
    db = {
        createDB = function(dbname)
            if not(love.filesystem.getInfo(dbname)) then
                love.filesystem.createDirectory(dbname)
                love.filesystem.newFile(dbname.."info.json")
                love.filesystem.write(dbname.."/info.json", json.encode({
                    name = dbname,
                    id = idgen(16),
                    TOC = os.date(), --? Time of creation
                    VER = myDBInternal.__VER__,
                    tables = {}
                }))
            else
                error("DB "..dbname.." already exists")
            end
        end,
        createTable = function(dbname, tablename, data)
            if love.filesystem.getInfo(dbname) then
                local info = getdbinfo(dbname)
                if type(data):lower() == "table" then
                    if not(contains(info.tables, tablename)) then
                        love.filesystem.newFile(dbname.."/"..tablename..".json")
                        love.filesystem.write(dbname.."/"..tablename..".json", json.encode(data))
                        info.tables[#info.tables + 1] = tablename
                        savedbinfo(dbname, info)
                    else
                        error("Table already exists !")
                    end
                end
            end
        end,
        getTableData = function(dbname, tablename)
            if love.filesystem.getInfo(dbname) then
                local info = getdbinfo(dbname)
                if contains(info.tables, tablename) then
                    return(json.decode(love.filesystem.read(dbname.."/"..tablename..".json")))
                end
            end
        end,
        getDbInfo = function(dbname)
            if love.filesystem.getInfo(dbname) then
                return(getdbinfo(dbname))
            end
        end,
        modifyTable = function(dbname, tablename, data)
            if love.filesystem.getInfo(dbname) then
                local info = getdbinfo(dbname)
                if contains(info.tables, tablename) then
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
                    struct = {struct=struct, data={}}
                    print(json.encode(struct))
                    love.filesystem.write(dbname.."/"..tablename..".json", json.encode(struct))
                else
                    error("Table "..tablename.." does already exist in DB "..dbname)
                end
            else
                error("DB "..dbname.." does not exist")
            end
        end,
        addStructData = function(dbname, tablename, vals)
            local info = getdbinfo(dbname)
            if getdbinfo ~= nil then
                if contains(info.tables, tablename) then
                    local table = json.decode(love.filesystem.read(dbname.."/"..tablename..".json"))
                    local structkeys = table.struct
                    local valskeys = getKeys(vals)
                    local function chkkey(key, tbl)
                        for i = 1, #tbl, 1 do
                            if tbl[i] == key then
                                return(true)
                            end
                        end
                        return(false)
                    end
                    for i = 1, #valskeys, 1 do
                        if not(chkkey(valskeys[i], structkeys)) then
                            error("Key error at pos "..tostring(i))
                        end 
                    end
                    table.data[#table.data + 1] = vals
                    love.filesystem.write(dbname.."/"..tablename..".json", json.encode(table))
                else
                    error("Table "..tablename.." does not exist in DB "..dbname)
                end
            else
                error("DB "..dbname.." does not exist")
            end
        end,
        getStructData = function(dbname, tablename, sno)
            local info = getdbinfo(dbname)
            if info ~= nil then
                if contains(info.tables, tablename) then
                    local table = json.decode(love.filesystem.read(dbname.."/"..tablename..".json"))
                    if sno == nil then
                        return(table.data)
                    else
                        return(table.data[sno])
                    end
                else
                    error("Table "..tablename.." does not exist in DB "..dbname)
                end
            else
                error("DB "..dbname.." does not exist")
            end
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
--* INIT
print("myDB DBMS "..myDBInternal.__VER__.." with JSON "..json._version)
return(myDB)
