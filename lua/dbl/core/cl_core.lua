function dbl.scale( value )
	return math.max( value * ( ScrH() / 1080 ) , 1 )
end

concommand.Add( "dwhitelist", function()
	if IsValid( element ) then element:Remove() return end
	local element = vgui.Create( "dbl:WhitelistGUI" )
end)