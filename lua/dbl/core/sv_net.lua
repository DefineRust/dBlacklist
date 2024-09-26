util.AddNetworkString( "dbl::Notify" )

util.AddNetworkString( "dbl::ToolDeployed" )

util.AddNetworkString( "dbl::RemoveModel" )
net.Receive( "dbl::RemoveModel", function( _, ply )

	if ( not dbl.config.Ranks.Staff[ply:GetUserGroup()] ) then dbl.util.Notify( ply, "You are not authorized to use this tool!" ) return end

	local mdl = net.ReadString()

	if not mdl or mdl == "" then return end

	if dbl.util.IsBlockedModel( mdl ) then
        dbl.data.RemoveModel( mdl )
	else
		dbl.util.Notify( ply, "Model not found in blacklist" )
	end

end)