dbl.util = dbl.util or {}

function dbl.util.IsBlockedModel( mdl )
	return dbl.data.GetData( mdl )
end

function dbl.util.Notify( ply, message )
	net.Start( "dbl::Notify" )
	net.WriteString( message )
	if ply == "all" then
		net.Broadcast()
	else
		net.Send( ply )
	end
end

hook.Add( "dbl::BlacklistUpdated", "dbl::DoUpdate", function( mdl, added )
	local str = added and " added to" or " removed from"
	dbl.util.Notify( "all", "dbl:  " .. '"' .. mdl .. '"' .. " was" .. str .. " the blacklist" )
	for k, v in ents.Iterator() do
		if v:GetModel() == mdl then v:Remove() end
	end
    if added then
        if dbl.config["DataMode"]:lower() == "sqlite" then
            sql.Query( "INSERT INTO " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " ( model ) VALUES( " .. sql.SQLStr( mdl ) .. " )" )
        elseif dbl.config["DataMode"]:lower() == "sql" then
            local query = string.format("REPLACE INTO %s (model) VALUES (?);", dbl.config["DatabaseName"])
            local prepared = dbl.data.sql.instance:prepare(query)
            prepared:setString(1, mdl)
            prepared:start()
        end

        dbl.data.cached[mdl] = true
    else
		if dbl.config["DataMode"]:lower() == "sqlite" then
			sql.Query( "DELETE FROM " .. sql.SQLStr( dbl.config["DatabaseName"] ) .. " WHERE model = " .. sql.SQLStr( mdl ) )
        elseif dbl.config["DataMode"]:lower() == "sql" then
            local query = string.format("DELETE FROM %s WHERE model = ?;", dbl.config["DatabaseName"])
            local prepared = dbl.data.sql.instance:prepare(query)
            prepared:setString(1, mdl)
            prepared:start()
        end

        dbl.data.cached[mdl] = nil
    end
	if dbl.config["DataMode"]:lower() == "file" then
		file.Write( "dbl/" .. dbl.config["DatabaseName"] .. ".txt", util.TableToJSON( dbl.data.cached ) )
	end
end)

hook.Add( "PlayerSpawnProp", "dbl::BlockSpawning", function( ply, mdl )
	local b = dbl.util.IsBlockedModel( mdl )
	if b == true then dbl.util.Notify( ply, "Model (" .. mdl .. ") is on the blacklist." ) return ( not b ) end
end)
