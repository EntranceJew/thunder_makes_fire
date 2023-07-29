AddCSLuaFile()
AddCSLuaFile("jewui.lua")
local JewUI = include("jewui.lua")

local print = JewUI.wrappedprint(print, "sv_tmf_debug_enable", "ThunderMakesFire:")

local con_struct = {
  meta = {
    prefix = "tmf",
    title = "ThunderMakesFire",
  },
  toolmenus = {
    {
      tab = "Utilities",
      heading = "Admin",
      uid = "ThunderMakesFire_AdminOptions",
      titlebar = "Thunder Makes Fire",
      prefix = "sv",
      sets = {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED},
      contents = {
        {"category", "general", "General", {
          {"float", "fireball_nudge", "How far to increase the fireball's spawn position to prevent tunneling through thin geometry or props.", 16, 0, nil},
          {"float", "life",  "How large the fireball will become.", 30, 0, nil},
          {"float", "feed",  "How much growth over time the impact fireball will pass to the fires it starts.", 15, 0, nil},
          {"float", "duration",  "How long a struck entity should burn for. This will have no effect when vFire is installed.", 15, 0, nil},
          {"float", "radius",  "How far fire should spread from each entity struck.", 10, 0, nil},
          -- {"bool", "ignite_vfire_gas", "Should we ignite gas made by a vfire gas can?", 1},
        }},
        {"category", "debug", "Debug", {
          {"bool", "debug_enable", "Should we be using extra debug prints?", 0, 0, 1},
        }},
      },
    },
  }
}

JewUI.PopulateConVars(con_struct)

ThunderMakesFire = {
  ConVars = con_struct,
}