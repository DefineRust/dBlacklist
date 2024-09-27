dbl.data = dbl.data or {}
dbl.data.sql = dbl.data.sql or {}
dbl.data.mdls = dbl.data.mdls or {}
function dbl.data.SetupSQLLite()
    sql.Query("CREATE TABLE IF NOT EXISTS " .. sql.SQLStr(dbl.config["DatabaseName"]) .. " ( model TEXT )")
end

function dbl.data.SetupSQL()
    if not util.IsBinaryModuleInstalled("mysqloo") then error("You can't use sql with out the module\nhttps://github.com/FredyH/MySQLOO") end
    function dbl.data.sql:Init()
        self.instance = mysqloo.connect(dbl.config["sql"].host, dbl.config["sql"].username, dbl.config["sql"].password, dbl.config["sql"].dbname, dbl.config["sql"].port)
        self.instance.onConnected = function(db, err)
            dbl.data.sql:OnConnected(db)
        end

        self.instance.onConnectionFailed = function(db, err) error("connection failed " .. err) end
        self.instance:connect()
    end

    timer.Simple(1, function() dbl.data.sql:Init() end)
    function dbl.data.sql:OnConnected(db)
        local query = string.format("CREATE TABLE IF NOT EXISTS `%s` ( model TEXT );", dbl.config["DatabaseName"])
        local prepared = dbl.data.sql.instance:prepare(query)
        prepared:start()
    end
end

function dbl.data.SetupFlatFile()
    if not file.Exists("dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA") then
        file.CreateDir("dbl")
        file.Write("dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON({}))
    end
end

function dbl.data.LoadDataMethod()
    local mode = dbl.config["DataMode"]:lower()
    if mode == "sqllite" then
        dbl.data.SetupSQLLite()
    elseif mode == "file" then
        dbl.data.SetupFlatFile()
    elseif mode == "sql" then
        dbl.data.SetupSQL()
    end
end

function dbl.data.AddModel(mdl)
    mdl = mdl:lower()
    if dbl.config["DataMode"]:lower() == "sqllite" then
        local data = sql.Query("SELECT * FROM " .. sql.SQLStr(dbl.config["DatabaseName"] .. " WHERE model = " .. sql.SQLStr(mdl)))
        if not data then sql.Query("INSERT INTO " .. sql.SQLStr(dbl.config["DatabaseName"]) .. " ( model ) VALUES( " .. sql.SQLStr(mdl) .. " )") end
    elseif dbl.config["DataMode"]:lower() == "file" then
        local data, bool = dbl.data.mdls or util.JSONToTable(file.Read("dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA"))
        for k, v in pairs(data) do
            if v ~= mdl then continue end
            bool = true
        end

        if not bool then
            data[mdl] = true
            file.Write("dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON(data))
        end
    elseif dbl.config["DataMode"]:lower() == "sql" then
        local query = string.format("REPLACE INTO %s (model) VALUES (?);", dbl.config["DatabaseName"])
        local prepared = dbl.data.sql.instance:prepare(query)
        prepared:setString(1, mdl)
        prepared:start()
    end

    hook.Run("dbl::BlacklistUpdated", mdl, true)
end

function dbl.data.RemoveModel(mdl)
    mdl = mdl:lower()
    local data, removed = dbl.data.mdls or util.JSONToTable(file.Read("dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA")), 0
    if dbl.config["DataMode"]:lower() == "sqllite" then
        sql.Query("DELETE FROM " .. sql.SQLStr(dbl.config["DatabaseName"]) .. " WHERE model = " .. sql.SQLStr(mdl))
    elseif dbl.config["DataMode"]:lower() == "file" then
        data[mdl] = nil
        file.Write("dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON(data))
    elseif dbl.config["DataMode"]:lower() == "sql" then
        local query = string.format("DELETE FROM %s WHERE model = ?;", dbl.config["DatabaseName"])
        local prepared = dbl.data.sql.instance:prepare(query)
        prepared:setString(1, mdl)
        prepared:start()
    end

    hook.Run("dbl::BlacklistUpdated", mdl:lower(), false)
end

function dbl.data.LoadData()
    if dbl.config["DataMode"]:lower() == "sqlite" then
        local query = sql.Query("SELECT * FROM " .. sql.SQLStr(dbl.config["DatabaseName"]))
        for i = 1, #query do
            dbl.data.mdls[query[i].model] = true
        end
    elseif dbl.config["DataMode"]:lower() == "file" then
        dbl.data.mdls = util.JSONToTable(file.Read("dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA"))
    elseif dbl.config["DataMode"]:lower() == "sql" then
        local query = string.format("SELECT * FROM %s ;", dbl.config["DatabaseName"])
        local prepared = dbl.data.sql.instance:prepare(query)
        prepared:start()
        prepared.onSuccess = function(_, data)
            for i = 1, #data do
                dbl.data.mdls[data[i].model] = true
            end
        end
    end
end

hook.Add("PlayerConnect", "LoadModelBlackList", function()
    hook.Remove("PlayerConnect", "LoadModelBlackList")
    dbl.data.LoadDataMethod()
    timer.Simple(5, function() dbl.data.LoadData() end)
end)