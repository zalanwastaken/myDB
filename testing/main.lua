mydb = require("libs.myDB.init")
local dbname = "mydb"
function love.load()
    mydb.db.createDB(dbname)
    mydb.db.createTable(dbname, "Hello", {
        data = "Hello world !"
    })
    print(mydb.db.getTableData(dbname, "Hello").data)
    mydb.db.modifyTable(dbname, "Hello", {data = "Hi"})
    print(mydb.db.getTableData(dbname, "Hello").data)
end
