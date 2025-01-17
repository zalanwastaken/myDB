local mydb = require("libs.myDB.init")
local dbname = "mydb"
function love.load()
    if not(mydb.db.dbExists(dbname)) then
        mydb.db.createDB(dbname)
    end
    if not(mydb.db.tableExists(dbname, "Hello")) then
        mydb.db.createTable(dbname, "Hello", {
            data = "Hello world !"
        })
    else
        mydb.db.modifyTable(dbname, "Hello", {data = "Hello world !"})
    end
    print(mydb.db.getTableData(dbname, "Hello").data)
    mydb.db.modifyTable(dbname, "Hello", {data = "Hi"})
    print(mydb.db.getTableData(dbname, "Hello").data)
    if not(mydb.db.tableExists(dbname, "test")) then
        mydb.db.createStructTable(dbname, "test", {"a", "b", "c"})
        mydb.db.addStructData(dbname, "test", {a = 1, b = 2, c = 3})
        print(mydb.db.getStructData(dbname, "test", 1).a)
    else
        mydb.fs.removeDbFile(dbname, "test.json")
        mydb.fs.fixTableInfo(dbname)
    end
    local query = mydb.queryStructData("mydb", "test", "b")
    for i = 1, #query, 1 do
        print(query[i], i)
    end
end
