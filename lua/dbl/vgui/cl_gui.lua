local colors = {
	["main"] = Color( 25, 25, 25 ),
	["dark"] = Color( 18, 18, 18 ),
	["light"] = Color( 32, 32, 32 ),
	["contrast"] = Color( 225, 150, 75 ),
}

local PANEL = {}

function PANEL:Init()
	self:SetSize( dbl.scale( 400 ), dbl.scale( 200 ) )
	self:Center()
	self:MakePopup()
	self:SetTitle( "dWhitelist" )
	self:ShowCloseButton( false )
	self.textentry = self:Add( "DTextEntry" )
		self.textentry:SetSize( dbl.scale( 350 ), dbl.scale( 75 ) )
		self.textentry:SetPos( dbl.scale( 25 ), dbl.scale( 45 ) )
		self.textentry:SetUpdateOnType( true )
		self.textentry:SetPaintBackground( false )
		self.textentry:SetPlaceholderText( "Model" )
		self.textentry:SetPlaceholderColor( colors.contrast )
		self.textentry:SetTextColor( colors.contrast )

	self.textentry.Paint = function( s, w, h )
		local txt = self.textentry:GetValue() ~= ( "" or nil ) and self.textentry:GetValue() or self.textentry:GetPlaceholderText()
		draw.RoundedBox( 8, 0, 0, w, h, colors.light )
		draw.SimpleText( txt, "Trebuchet18", w / 2, h / 2, colors.contrast, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	self.btn = self:Add( "DButton" )
		self.btn:SetSize( dbl.scale( 200 ), dbl.scale( 50 ) )
		self.btn:SetPos( dbl.scale( 100 ), dbl.scale( 135 ) )
		self.btn:SetText( "" )

	self.btn.Paint = function( s, w, h )
		if self.btn:IsHovered() then
            draw.RoundedBox( 8, 0, 0, w, h, colors.dark )
		else
            draw.RoundedBox( 8, 0, 0, w, h, colors.light )
		end
        draw.SimpleText( self.textentry:GetValue() == ( "" or nil ) and "Close GUI" or "Remove from Blacklist", "Trebuchet18", w / 2, h / 2, colors.contrast, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	self.btn.DoClick = function()
		net.Start( "dbl::RemoveModel" )
			net.WriteString( self.textentry:GetValue() or "" )
		net.SendToServer()
		self:AlphaTo( 0, 0.2, 0, function( anim, pnl )
			if not IsValid( pnl ) then return end
            pnl:Remove()
		end)
	end
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 8, 0, 0, w, h, colors.main )
end

vgui.Register( "dbl:WhitelistGUI", PANEL, "DFrame" )