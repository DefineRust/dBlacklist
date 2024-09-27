dbl.util = dbl.util or {}
function dbl.util.IsBlockedModel(mdl)
    return dbl.data.mdls[mdl]
end

function dbl.util.Notify(ply, message)
    net.Start("dbl::Notify")
    net.WriteString(message)
    if ply == "all" then
        net.Broadcast()
    else
        net.Send(ply)
    end
end

hook.Add("dbl::BlacklistUpdated", "dbl::DoUpdate", function(mdl, added)
    local str = added and " added to" or " removed from"
    dbl.util.Notify("all", "dbl:  " .. '"' .. mdl .. '"' .. " was" .. str .. " the blacklist")
    for k, v in ents.Iterator() do
        if v:GetModel() == mdl then v:Remove() end
    end

    if added then
        dbl.data.mdls[mdl] = true
    else
        dbl.data.mdls[mdl] = nil
    end
end)

hook.Add("PlayerSpawnProp", "dbl::BlockSpawning", function(ply, mdl)
    if dbl.util.IsBlockedModel(mdl:lower()) then
        dbl.util.Notify(ply, "Model (" .. mdl .. ") is blacklisted!")
        return false
    end
end)