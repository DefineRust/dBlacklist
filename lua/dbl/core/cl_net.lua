function dbl.RemoveModel( mdl )
	net.Start( "dbl::RemoveModel" )
		net.WriteString( mdl )
	net.SendToServer()
end

net.Receive( "dbl::Notify", function()
	local str = net.ReadString()
	notification.AddLegacy( str, 1, 5 )
end)