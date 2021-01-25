--[[
Description: A mod to export an in-game region to a YAML format
Feature: 
Author: Charles Zhang
]]

local function PrintHelp()
  print([[
Region Export Utility:
  /re: print this help message;
  /re <|+df|> <|-df|> <|+dy|> <|-dy|> <name>: export a region roughly specified by forward view distance <+df>, 
      backward view distance <-df>, above distance <+dy> and below distance <-dy> into a file named "<name>.re"
      into folder <world>/regions; Put absolute values and don't use negative sign
  /re <x1> <y1> <z1> <x2> <y2> <z2> <name>: export a region precisely specified by two end nodes (inclusive) 
      positions into a file named "<name>.re" into folder <world>/regions
For example:
  - To export (roughly) a 10x10x10 (11x11x11) region around you into a file named "r1.re", 
      issue command: `/re 5 5 5 5 r1`
  - To export (precisely) a 10x10x10 region around you (assume location x0,y0,z0) into a file named "r1.re", 
      issue command: `/re (x0-4) (y0-4) (z0-4) (x1+5) (y1+5) (z1+5) r1`
Notice:
  - No space is allowed in file name.
  - Exported ".re" file is a ".yaml" file and can be opened with text editor
]])
end

local function round(num)
  return math.floor(num+0.5)
end

local function count(base, pattern)
  return select(2, string.gsub(base, pattern, ""))
end

local function dumpRegion(x1, y1, z1, x2, y2, z2, fileName)
  -- Get file path
  local basePath = minetest.get_worldpath()
  local folderPath = basePath.."/regions/"
  local filePath = folderPath..fileName..".re"
  -- Create folder (in case it doesn't exist)
  minetest.mkdir(folderPath)
  -- Open file ready
  local file = io.open(filePath, "w")
  -- Write high level region information
  file:write("SizeX: "..(math.abs(x2-x1)+1).."\n")
  file:write("SizeY: "..(math.abs(y2-y1)+1).."\n")
  file:write("SizeZ: "..(math.abs(z2-z1)+1).."\n")
  file:write("Nodes: \n")
  -- Get Vox Manip
  local p1 = {x=x1, y=y1, z=z1}
  local p2 = {x=x2, y=y2, z=z2}
  local manip = minetest.get_voxel_manip(p1, p2)
  -- Gather data
  local increX = 1
  local increY = 1
  local increZ = 1
  if x2 < x1 then increX = -1 end
  if y2 < y1 then increY = -1 end
  if z2 < z1 then increZ = -1 end
  for z = z1, z2, increZ do
    for y = y1, y2, increY do
      for x = x1, x2, increX do
        -- Get node
        local node = manip:get_node_at({x=x, y=y, z=z})
        -- Format output
        local output = 
          "  - Pos: ["..x..", "..y..", "..z.."]".."\n"..
          "    Name: "..node.name.."\n"
        -- Dump string content
        file:write(output)
      end
    end
    -- Progress report
    print("Exporting... "..round((z-z1)/(z2-z1)*100).."%")
  end
  -- Release resource
  file:close()
  -- Debug Pring
  print("Export finished!\nSaved to file: "..filePath)
end

minetest.register_chatcommand("re", {
    description = "Exports a specified region onto disk in YAML format.",
    privs = {server = true},
    func = function(playerName, params)
      -- Handle missing parameter: output help
      if params == nil or params:len() == 0 then
        PrintHelp()
      else
        -- Get player location
        local pos = minetest.get_player_by_name(playerName):get_pos()
        -- Handle rough export
        if count(params, " ") == 4 then
          local _,_,df1,df2,dy1,dy2,fileName = params:find("^([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%S+)%s*$")
          -- Get current location
          local pos = minetest.get_player_by_name(playerName):getpos()
          -- Get current view and constraint look direction to horizontal plane
          local dir = minetest.get_player_by_name(playerName):get_look_dir()
          dir.y = 0
          -- Gather peak distance
          local end1 = {x=pos.x+dir.x*df1, y=pos.y, z=pos.z+dir.z*df1}
          local end2 = {x=pos.x-dir.x*df2, y=pos.y, z=pos.z-dir.z*df2}
          -- Define boundary
          x1 = round(end1.x)
          y1 = round(pos.y+dy1)
          z1 = round(end1.z)
          x2 = round(end2.x)
          y2 = round(pos.y-dy2)
          z2 = round(end2.z)
          -- Debug Print
          print("Current Location: "..round(pos.x)..", "..round(pos.y)..", "..round(pos.z))
          print("Boundary: ["..x1..", "..y1..", "..z1.." -> "..x2..", "..y2..", "..z2.."]")
          -- Dump
          dumpRegion(x1,y1,z1,x2,y2,z2,fileName)
        -- Handle precise export
        elseif count(params, " ") == 6 then
          local _,_,x1,y1,z1,x2,y2,z2,fileName = params:find("^([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%d+)%s+([+-]?%S+)%s*$")
          -- Debug Print
          print("Boundary: ["..x1..", "..y1..", "..z1.." -> "..x2..", "..y2..", "..z2.."]")
          -- Dump
          dumpRegion(tonumber(x1),tonumber(y1),tonumber(z1),tonumber(x2),tonumber(y2),tonumber(z2),fileName)
        -- Invalid syntax
        else
          print("Unrecognized command or incorrect syntax for `"..params.."` - did you miss any required arguments? (Also notice space is not allowed in file names)")
        end
      end
    end
})