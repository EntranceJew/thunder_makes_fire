if not SERVER then return end

if StormFox2 then
  hook.Remove("StormFox2.Thunder.OnStrike", "ThunderMakesFire")
  hook.Add("StormFox2.Thunder.OnStrike", "ThunderMakesFire", function(pos, hitEnts)
    if vFireInstalled then
      pos = pos + Vector(0, 0, GetConVar("sv_tmf_fireball_nudge"):GetFloat())
      CreateVFireBall(
        GetConVar("sv_tmf_life"):GetFloat(),
        GetConVar("sv_tmf_feed"):GetFloat(),
        pos,
        Vector(0, 0, 0)
      )
    end
    for _, ent in ipairs(hitEnts) do
      ent:Ignite(
        GetConVar("sv_tmf_duration"):GetFloat(),
        GetConVar("sv_tmf_radius"):GetFloat()
      )
    end
  end)
end