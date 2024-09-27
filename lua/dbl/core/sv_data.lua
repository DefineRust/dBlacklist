dbl.data = dbl.data or {}
dbl.data.cached = dbl.data.cached or {}

function dbl.data.SetupSQLite()
	sql.Query("CREATE TABLE IF NOT EXISTS " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " ( model TEXT )")
end

function dbl.data.SetupFlatFile()
	if not file.Exists( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) then
		file.CreateDir( "dbl" )
		file.Write( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON({}))
	end
end

function dbl.data.SetupSQL()
	sql.Query("CREATE TABLE IF NOT EXISTS " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " ( model TEXT )")
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

function dbl.data.LoadDataMethod()
    local mode = dbl.config["DataMode"]:lower()
    if mode == "sqlite" then
        dbl.data.SetupSQLite()
    elseif mode == "file" then
        dbl.data.SetupFlatFile()
    elseif mode == "sql" then
        dbl.data.SetupSQL()
    end
end

dbl.data.LoadDataMethod()

function dbl.data.CacheData()
	if dbl.data.cached then return end
	local data
	if dbl.config["DataMode"]:lower() == "sqlite" then
		data = sql.Query( "SELECT * FROM " .. sql.SQLStr( dbl.config["DatabaseName"] ) )
	elseif dbl.config["DataMode"]:lower() == "file" then
		data = util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) )
	end
	if not data then return end
	for k, v in pairs( data ) do
		if v["model"] then dbl.data.cached[v["model"]] = true continue end
		if string.EndsWith( v, ".mdl" ) then dbl.data.cached[v] = true continue end
	end
end

dbl.data.CacheData()

function dbl.data.AddModel( mdl )
	mdl = mdl:lower()
	if ( dbl.util.IsBlockedModel( mdl ) ) then return end
	hook.Run( "dbl::BlacklistUpdated", mdl, true )
end

function dbl.data.RemoveModel( mdl )
	mdl = mdl:lower()
	local data = dbl.data.GetData( mdl )
	if ( not data ) or ( not dbl.util.IsBlockedModel( mdl ) ) then return end
	hook.Run( "dbl::BlacklistUpdated", mdl, false )
end

function dbl.data.GetData( mdl )
	if mdl then
		return dbl.data.cached[mdl]
	end
	if dbl.data.cached then return dbl.data.cached end
	if dbl.config["DataMode"]:lower() == "sqlite" then
        local query = sql.Query("SELECT * FROM " .. sql.SQLStr(dbl.config["DatabaseName"]))
        for i = 1, #query do
            dbl.data.cached[query[i].model] = true
        end
	elseif dbl.config["DataMode"]:lower() == "file" then
		dbl.data.cached = util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) )
    elseif dbl.config["DataMode"]:lower() == "sql" then
        local query = string.format("SELECT * FROM %s ;", dbl.config["DatabaseName"])
        local prepared = dbl.data.sql.instance:prepare(query)
        prepared:start()
        prepared.onSuccess = function(_, data)
            for i = 1, #data do
                dbl.data.cached[data[i].model] = true
            end
        end
    end
	return dbl.data.cached or {}
end
