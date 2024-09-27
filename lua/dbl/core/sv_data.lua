dbl.data = dbl.data or {}
dbl.data.cached = dbl.data.cached or {}

function dbl.data.SetupSQL()
	sql.Query("CREATE TABLE IF NOT EXISTS " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " ( model TEXT )")
end

function dbl.data.SetupFlatFile()
	if not file.Exists( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) then
		file.CreateDir( "dbl" )
		file.Write( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON({}))
	end
end

function dbl.data.CacheData()
	if #dbl.data.cached > 0 then return end
	if dbl.config["DataMode"]:lower() == "sql" then
		dbl.data.cached = sql.Query( "SELECT * FROM " .. sql.SQLStr( dbl.config["DatabaseName"] ) )
	elseif dbl.config["DataMode"]:lower() == "file" then
		dbl.data.cached = util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) )
	end
end

dbl.data.SetupFlatFile()
dbl.data.SetupSQL()
dbl.data.CacheData()

function dbl.data.AddModel( mdl )
	mdl = mdl:lower()
	if dbl.config["DataMode"]:lower() == "sql" then
		local data = dbl.data.cached or sql.Query( "SELECT * FROM " .. sql.SQLStr( dbl.config["DatabaseName"] .. " WHERE model = " .. sql.SQLStr( mdl ) ) )
		if ( not data ) then
            sql.Query( "INSERT INTO " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " ( model ) VALUES( " .. sql.SQLStr( mdl ) .. " )" )
		end
	elseif dbl.config["DataMode"]:lower() == "file" then
		local data,bool = dbl.data.cached or util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) )
		for k, v in pairs( data ) do
			if v ~= mdl then continue end
			bool = true
		end
		if ( not bool ) then
			data[(#data+1 or 1)] = mdl
            file.Write( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON( data ) )
		end
	end
	--dbl.data.cached[#dbl.data.cached+1] = mdl
	hook.Run( "dbl::BlacklistUpdated", mdl, true )
end

function dbl.data.RemoveModel( mdl )
	mdl = mdl:lower()
	local data, removed = dbl.data.cached["blacklist"] or util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) ), 0
	if dbl.config["DataMode"]:lower() == "sql" then
		sql.Query( "DELETE FROM " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " WHERE model = " .. sql.SQLStr( mdl ) )
	elseif dbl.config["DataMode"]:lower() == "file" then
		for k, v in ipairs( data ) do
			if v == mdl then
                data[k] = nil
                removed = removed + 1
			elseif removed > 0 then
				data[k-removed] = v
                if k > ( #data - removed ) then
                    data[k] = nil
				end
			end
		end
		file.Write( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON( data ) )
	end
	removed = 0
	for k, v in pairs( dbl.data.cached ) do
		if v == mdl then
			dbl.data.cached[k] = nil
			removed = removed + 1
		elseif removed > 0 then
			dbl.data.cached[k-removed] = v
			if k > ( #dbl.data.cached - removed ) then
				dbl.data.cached[k] = nil
			end
		end
	end
	hook.Run( "dbl::BlacklistUpdated", mdl, false )
end

function dbl.data.GetData()
	if dbl.data.cached then return dbl.data.cached end
	if dbl.config["DataMode"]:lower() == "sql" then
		dbl.data.cached = sql.Query( "SELECT * FROM " .. sql.SQLStr( dbl.config["DatabaseName"] ) )
	elseif dbl.config["DataMode"]:lower() == "file" then
		dbl.data.cached = util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) )
	end
	return dbl.data.cached or {}
end
