local JewUI = {
  PropData = {},
  StorageMode = true,
}

JewUI.setproptext = function(key, value)
  print(key, value)
  if JewUI.StorageMode then
    JewUI.PropData[key] = value
  end
  return "#" .. key
end
JewUI.dumpproptext = function(filename)
  local dump = ""
  -- TODO: parse out linebreaks maybe
  for key, value in SortedPairs(JewUI.PropData) do
    dump = dump .. key .. "=" .. value .. "\n"
  end
  local dir = "jewui/resource/localization/en"
  file.CreateDir(dir)
  file.Write( dir .. "/" .. string.lower(filename) .. ".txt", dump )
end
-- usage: local print = JewUI.wrappedprint(print, "cl_tim_debug_enable", "TimelyMusic:")
JewUI.wrappedprint = function(func, cvn, prefix)
  return function(...)
    if GetConVar(cvn):GetBool() then
      local out = {...}
      table.insert(out, 1, prefix)
      func(unpack(out))
    end
  end
end
JewUI.wrapto = function(val, size)
  return (val % (#size)) + 1
end
JewUI.slugify = function(str, replacement)
  replacement = replacement or "_"
  local out = {}
  for k in string.gmatch(str, "(%w+)") do
    table.insert(out, k)
  end
  return table.concat(out, replacement):lower()
end
JewUI.ucwords = function(str)
  str = str:gsub("_+", " ")
  return str:gsub("(%a)([%w]*)", function(first, rest) return first:upper() .. rest:lower() end)
end
JewUI.RenderPanelFromData = function(panel, data, prefix, title)
  local varname = prefix .. data[2]
  local el = nil

  local tstring = JewUI.setproptext(string.lower(title) .. "." .. varname .. ".title", JewUI.ucwords(data[2]))
  local dstring = JewUI.setproptext(string.lower(title) .. "." .. varname .. ".description", data[3])

  if data[1] == "category" then
    local pan = vgui.Create("DForm")
    pan:SetName(dstring)
    for i = 1, #data[4] do
      local v = data[4][i]
      JewUI.RenderPanelFromData(pan, v, prefix, title)
    end
    panel:AddItem(pan)
    el = pan
  elseif data[1] == "themeselect" then
    TimelyMusic.ListView = vgui.Create( "DListView")
    for i, col in pairs(data[4]) do
      local cstring = JewUI.setproptext(string.lower(TimelyMusic.ConVars.meta.title) .. "." .. varname .. ".col" .. i, col)
      TimelyMusic.ListView:AddColumn( cstring )
    end
    TimelyMusic.ListView:GetDataHeight()
    TimelyMusic.ListView:SetTall(22 + math.min(TimelyMusic.ListView:DataLayout(), 160))
    TimelyMusic.ListView:SetMultiSelect( false )

    TimelyMusic.ListView.DoDoubleClick = data[5]

    TimelyMusic.RefreshListView()
    panel:AddItem(TimelyMusic.ListView)
    el = TimelyMusic.ListView
  elseif data[1] == "bool" then
    el = panel:CheckBox( tstring, varname )
  elseif data[1] == "string" then
    el = panel:TextEntry(tstring, varname )
  elseif data[1] == "button" then
    el = vgui.Create( "DButton" )
    el:SetText( tstring )
    if type( data[4] ) == "function" then
      el.DoClick = data[4]
    else
      el.DoClick = function()
        for k2, v2 in pairs(data[4]) do
          RunConsoleCommand( k2, v2 )
        end
      end
    end
    panel:AddItem(el)
  elseif data[1] == "float" then
    local min = data[5] or 0
    local max = data[6] or data[4]
    if data[6] == nil then
      max = math.pow(max, 1.25)
    end
    el = panel:NumSlider( tstring, varname, min, max )
  end
  if data[1] ~= "category" then
    if el ~= nil then
      local tip = varname
      if data[4] ~= nil and type(data[4]) ~= "table" and type(data[4]) ~= "function" then
        tip = tip .. "\n" .. language.GetPhrase("#default") .. ": " .. data[4]
      end
      el:SetTooltip(tip)
    end
    panel:ControlHelp(dstring)
  end
end
JewUI.RegisterConVarFromData = function(cm, tmenu, prefix)
  if cm[1] == "category" then
    for j = 1, #cm[4] do
      local v = cm[4][j]
      JewUI.RegisterConVarFromData(v, tmenu, prefix)
    end
  elseif cm[1] ~= "themeselect" and cm[1] ~= "button" then
    CreateConVar(
      prefix .. cm[2],
      cm[4],
      tmenu.sets,
      cm[3],
      cm[5],
      cm[6]
    )
  end
end
JewUI.PopulateConVars = function(con_struct)
  for tm = 1, #con_struct.toolmenus do
    local tmenu = con_struct.toolmenus[tm]
    for i = 1, #tmenu.contents do
      JewUI.RegisterConVarFromData(tmenu.contents[i], tmenu, tmenu.prefix .. "_" .. con_struct.meta.prefix .. "_")
    end
  end
end
JewUI.PopulateToolMenus = function(cv)
  hook.Add( "PopulateToolMenu", cv.meta.title .. "_CustomMenuSettings", function()
    for tm = 1, #cv.toolmenus do
      local tmenu = cv.toolmenus[tm]
      spawnmenu.AddToolMenuOption(
          tmenu.tab,
          tmenu.heading,
          cv.meta.title .. "_" .. tmenu.heading .. "Options",
          tmenu.titlebar, "", "", function( panel )
            for i = 1, #tmenu.contents do
              local c = tmenu.contents[i]
              JewUI.RenderPanelFromData(panel, c, tmenu.prefix .. "_" .. cv.meta.prefix .. "_", cv.meta.title)
            end
            panel:Help("")
      end)
    end
    JewUI.dumpproptext(cv.meta.title)
  end)
end

return JewUI