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

dbl.data.SetupFlatFile()
dbl.data.SetupSQL()

function dbl.data.AddModel( mdl )
	if dbl.config["DataMode"]:lower() == "sql" then
		local data = sql.Query( "SELECT * FROM " .. sql.SQLStr( dbl.config["DatabaseName"] .. " WHERE model = " .. sql.SQLStr( mdl:lower() ) ) )
		if ( not data ) then
            sql.Query( "INSERT INTO " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " ( model ) VALUES( " .. sql.SQLStr( mdl:lower() ) .. " )" )
		end
	elseif dbl.config["DataMode"]:lower() == "file" then
		local data,bool = dbl.data.cached["blacklist"] or util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) )
		for k, v in pairs( data ) do
			if v ~= mdl then continue end
			bool = true
		end
		if ( not bool ) then
			data[(#data+1 or 1)] = mdl:lower()
            file.Write( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON( data ) )
		end
	end
	hook.Run( "dbl::BlacklistUpdated", mdl, true )
end

function dbl.data.RemoveModel( mdl )
	local data, removed = dbl.data.cached["blacklist"] or util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) ), 0
	if dbl.config["DataMode"]:lower() == "sql" then
		sql.Query( "DELETE FROM " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " WHERE model = " .. sql.SQLStr( mdl:lower() ) )
	elseif dbl.config["DataMode"]:lower() == "file" then
		for k, v in ipairs( data ) do
			if v == mdl:lower() then
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
	hook.Run( "dbl::BlacklistUpdated", mdl:lower(), false )
end

function dbl.data.GetData()
	if dbl.config["DataMode"]:lower() == "sql" then
		return sql.Query( "SELECT * FROM " .. sql.SQLStr( dbl.config["DatabaseName"] ) )
	elseif dbl.config["DataMode"]:lower() == "file" then
		return util.JSONToTable( file.Read( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", "DATA" ) )
	end
end
