TOOL.Category = "dBlacklist"
TOOL.Name = "dBlacklist Tool"

if CLIENT then
	local fTime, g, r, gPly, lastEnt = fTime or CurTime() + .1, Color( 100, 200, 100, 255 ), Color( 200, 100, 100, 255 )

	local function DeployCL()

		hook.Add( "PreDrawEffects", "dbl::DrawWireframeBoxes", function()

			if fTime < CurTime() then

				fTime = CurTime() + .1
				local tr = gPly:GetEyeTrace()
				if lastEnt and tr.Entity ~= lastEnt then lastEnt.color = nil end
				lastEnt = tr.Entity
				tr.Entity.color = r

			end

            for k, v in ents.Iterator() do

                if ( v:GetClass() ~= "prop_physics" ) or ( v:GetPos():Distance( gPly:GetPos() ) > 1000 ) then continue end
                local pos, ang, min, max = v:GetPos(), v:GetAngles(), v:OBBMins(), v:OBBMaxs()
                render.DrawWireframeBox( pos, ang, min, max, v.color or g, false )

            end

		end)

	end

	net.Receive( "dbl::ToolDeployed", function()
		gPly = LocalPlayer()
		DeployCL()
	end)

	function TOOL:RightClick( tr )

		gPly:ConCommand( "dwhitelist" )
	
	end

	function TOOL:Holster()

		hook.Remove( "PreDrawEffects", "dbl::DrawWireframeBoxes" )

	end

	function TOOL:Think()

		if not gPly then gPly = self:GetOwner() end

	end

	language.Add( "Tool.dblwep.name",	"dBlacklist Tool" )
	language.Add( "Tool.dblwep.desc",	"Blacklist props." )
	language.Add( "Tool.dblwep.0"	,	"Primary: Blacklist prop. Secondary: Open Whitelisting GUI." )

end

if SERVER then

	function TOOL:LeftClick( tr )

		local ply, ent, mdl, hitPos = self:GetOwner(), tr.Entity, tr.Entity:GetModel(), tr.HitPos
		
		if ( not dbl.config.Ranks.Staff[ply:GetUserGroup()] ) then dbl.util.Notify( ply, "You are not authorized to use this tool!" ) return false end

		if ( hitPos:Distance( ply:GetPos() ) > 1000 ) or ( not string.EndsWith( mdl, ".mdl" ) ) then return false end

		dbl.data.AddModel( mdl )

	end

	function TOOL:Deploy()

		local ply = self:GetOwner()

		net.Start( "dbl::ToolDeployed" )
		net.Send( ply )

	end

end
