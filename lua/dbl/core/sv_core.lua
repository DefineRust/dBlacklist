dbl.util = dbl.util or {}

function dbl.util.IsBlockedModel( mdl )
	local data = dbl.data.GetData()
	for k, v in pairs( data ) do
		if dbl.config["DataMode"] == "file" then
			if v:lower() ~= mdl:lower() then continue end
			return true
		elseif dbl.config["DataMode"] == "sql" then
			if v["model"]:lower() ~= mdl:lower() then continue end
			return true
		end
		return false
	end
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
		if v:GetModel() == mdl then
			v:Remove()
		end
	end
end)

hook.Add( "PlayerSpawnProp", "dbl::BlockSpawning", function( ply, mdl )
	if dbl.util.IsBlockedModel( mdl ) then
		dbl.util.Notify( ply, "Model (" .. mdl .. ") is blacklisted!")
		return false 
	end
end)