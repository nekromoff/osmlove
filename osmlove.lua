--[[
OSM Love - library for drawing maps in LOVE game engine

(c) 2017+ Daniel Duris, dusoft@staznosti.sk

GPS lat/long coordinate conversion to cartesian X/Y based on routine found here:
https://stackoverflow.com/questions/39024601/scale-or-zoom-x-y-pixels-obtained-from-gps-lat-long-to-fit-a-certain-area/39028490#39028490
Thanks!
--]]

local json = require 'json'
local xl = require 'xl'

local osmlove = { _version = '0.1' }

local map={}
map.width=love.graphics.getWidth()
map.height=love.graphics.getHeight()
map.zoom=1
map.region={-999, -999, 999, 999} -- minlon, minlat, maxlon, maxlat
map.rules = {
   highway = {
      motorway = {255, 0, 0},
      trunk = {0, 0, 0},
      primary = {0, 0, 0, 0, 200},
      secondary = {0, 0, 0, 150},
      tertiary = {0, 0, 0, 100},
      residential = {0, 0, 0, 80},
      pedestrian = {0, 0, 0, 50},
      track = {0, 0, 0, 30},
      cycleway = {0, 0, 255}
   },
   waterway = {
      river = { 79, 179, 255}
   }
}
map.structures={}

--- Initialize OSM parser
-- @param filename File to parse
-- @param region Region to crop map to, minimum and maximum longitude and latitude coordinates {minlon, minlat, maxlon, maxlat}
-- @param width Width of map to draw
-- @param height Height of map to draw
-- @param zoom Map zoom to apply
function osmlove.init(filename, region, width, height, zoom)
   if filename==nil then love.errhand('*filename* of geoJSON file required!') end
   if region~=nil then map.region=region end
   if width~=nil then map.width=width end
   if height~=nil then map.height=height end
   if zoom~=nil then map.zoom=zoom end
   f=io.open(filename, 'r')
   local content=f:read("*all")
   f:close()
   local items=json.decode(content)
   items=items.features
   local itemslength=#items
   for i=1, itemslength do
      if items[i].properties.highway~=nil then
         local coordlength=#items[i].geometry.coordinates
         local ignore=false
         for o=1, coordlength do
            local coordinates=items[i].geometry.coordinates[o]
            -- check if lon, lat coordinates within requested map region
            if coordinates[1]<map.region[1] or coordinates[1]>map.region[3] or coordinates[2]<map.region[2] or coordinates[2]>map.region[4] then
               ignore=true
            end
         end
         -- object within map region
         if ignore==false then
            map.structures[#map.structures+1]={ properties=items[i].properties, geometry=items[i].geometry }
         end
      end
   end
   local structlength=#map.structures
   for i=1, structlength do
      local coordlength=#map.structures[i].geometry.coordinates
      for o=1, coordlength do
         local coordinates=map.structures[i].geometry.coordinates[o]
         x=(coordinates[1]*map.width)/360
         y=(coordinates[2]*map.height)/180
         if map.minx==nil or x<map.minx then map.minx=x end
         if map.miny==nil or y<map.miny then map.miny=y end
         if map.maxx==nil or x>map.maxx then map.maxx=x end
         if map.maxy==nil or y>map.maxy then map.maxy=y end
         map.structures[i].geometry.coordinates[o].x=x
         map.structures[i].geometry.coordinates[o].y=y
      end
   end
   local difx=map.maxx-map.minx
   local dify=map.maxy-map.miny
   for i=1, structlength do
      local coordlength=#map.structures[i].geometry.coordinates
      for o=1, coordlength do
         local coordinates=map.structures[i].geometry.coordinates[o]
         map.structures[i].geometry.coordinates[o].x=coordinates.x-(map.maxx-difx)
         map.structures[i].geometry.coordinates[o].y=coordinates.y-(map.maxy-dify)
         x=map.structures[i].geometry.coordinates[o].x
         y=map.structures[i].geometry.coordinates[o].y
         if map.bmaxx==nil or x>map.bmaxx then map.bmaxx=x end
         if map.bmaxy==nil or y>map.bmaxy then map.bmaxy=y end
      end
   end
   map.ratiox=map.width/map.bmaxx
   map.ratioy=map.height/map.bmaxy
   for i=1, structlength do
      local coordlength=#map.structures[i].geometry.coordinates
      for o=1, coordlength do
         local coordinates=map.structures[i].geometry.coordinates[o]
         map.structures[i].geometry.coordinates[o].x=coordinates.x*map.zoom*map.ratiox
         map.structures[i].geometry.coordinates[o].y=map.height-(coordinates.y*map.zoom*map.ratioy)
      end
   end
end

local function _setupMap(rules)
   if rules~=nil then map.rules=rules end
   map.cache=love.graphics.newCanvas(map.width, map.height)
   love.graphics.setCanvas(map.cache)
   local structlength=#map.structures
   for i=1, structlength do
      -- set transparent color for structure types without rules set
      love.graphics.setColor(255, 255, 255, 0)
      -- iterate over rules and set color, if match found
      for type, ruletype in pairs(map.rules) do
         if map.structures[i].properties[type]~=nil then
            local color=ruletype[map.structures[i].properties[type]]
            if color~=nil then love.graphics.setColor(color) end
         end
      end
      local coordlength=#map.structures[i].geometry.coordinates
      for o=1, coordlength do
         local coordinates=map.structures[i].geometry.coordinates[o]
         if map.structures[i].geometry.type=='Point' or map.structures[i].geometry.type=='MultiPoint' then
            love.graphics.points(coordinates.x, coordinates.y)
         elseif map.structures[i].geometry.type=='LineString' then
            if o<coordlength then
               love.graphics.line(coordinates.x, coordinates.y, map.structures[i].geometry.coordinates[o+1].x, map.structures[i].geometry.coordinates[o+1].y)
            end
         end
      end
   end
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.setCanvas()
end

--- Draw map
-- @param rules Map rules to apply (colors and in future also other attributes such as line width etc.)
function osmlove.drawMap(rules)
   if map.cache==nil then _setupMap(rules, width, height) end
   love.graphics.setBlendMode('alpha', 'premultiplied')
   love.graphics.draw(map.cache)
end

function print_r (t, indent) -- alt version, abuse to http://richard.warburton.it
  local indent=indent or ''
  if type(t)~='table' then
    print(t)
    return
  end
  for key,value in pairs(t) do
    io.write(indent,'[',tostring(key),']')
    if type(value)=="table" then io.write(':\n') print_r(value,indent..'\t')
    else io.write(' = ',tostring(value),'\n') end
  end
end

return osmlove