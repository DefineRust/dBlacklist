function dbl.scale( value )
	return math.max( value * ( ScrH() / 1080 ) , 1 )
end

concommand.Add( "dwhitelist", function()
	if IsValid( element ) then element:Remove() return end
	if not dbl.config.Ranks.Staff[LocalPlayer():GetUserGroup()] then return end
	local element = vgui.Create( "dbl:WhitelistGUI" )
	element:AlphaTo( 255, 0.2, 0 )
end)
