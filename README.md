# OSMLOVE
OSM map drawing support for LÖVE engine

OSM Love - library for drawing maps in LOVE game engine

## Info

Use this library to draw a map from geoJSON file.

Only points and lines supported at the moment with set of basic rules (define color only).

Future plans:
* optimize parser speed
* add support for simple and complex polygons
* add support for complex rules (line width, borders etc.)
* add support for OSM XML format

## Code examples

See main.lua for simple example.

Include osmlove modules in your code:
```
local osmlove = require 'osmlove'
```

Initialize map in `love.load`:

```
osmlove.init(filename, region, width, height, zoom)
```

Draw a map to screen in `love.draw`:

```
osmlove.drawMap(rules)
```

## Get geoJSON files

You can quickly get some samples here:
* https://mapzen.com/data/metro-extracts/

## Author, license, dependencies
(c) 2017+ Daniel Duris, dusoft@staznosti.sk

License: GNU GPL v3

### Depends on:
* json.lua (MIT License)
* xl.lua (public domain)