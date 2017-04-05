local osmlove = require 'osmlove'

--[[
a = parser:find(parser:root(), 'node')
[2297]:
        [attr]:
                [changeset] = 46690287
                [version] = 1
                [id] = 4724699452
                [visible] = true
                [timestamp] = 2017-03-08T19:41:02Z
                [lat] = -19.9904356
                [uid] = 1208770
                [lon] = 57.6163292
                [user] = dusoft
        [tag] = node


        local parser = XL:new()
   parser:from_file('cap-malhereux-map.osm')
   local xmlitems = parser:find(parser:root(), 'node')
   local xmlstructure={}
   for i=1, #xmlitems do
      local id=xmlitems[i].attr.id
      xmlstructure[id]={ lat=xmlitems[i].attr.lat, lon=xmlitems[i].attr.lon }
   end
   print_r(xmlstructure)

--]]
-- , {17.053010, 48.122055, 17.180565, 48.145509}

function love.load()
  love.graphics.clear(255, 255, 255)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print('loading...', 400, 50)
  love.graphics.present()
  osmlove.init('bratislava_slovakia_osm_line.geojson')
end

function love.update(dt)
   if love.keyboard.isDown('escape') then
      quit()
   end
end

rules = {
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

function love.draw()
   love.graphics.setBackgroundColor(255, 255, 255)
   osmlove.drawMap()
end