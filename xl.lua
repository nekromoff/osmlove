

-- XL: a poor man's XML parser in pure Lua
-- parser stolen from http://lua-users.org/wiki/LuaXml
--
-- example usage:
--
-- require 'xl'
--
-- parser = XL:new()
-- parser:from_file(arg[1])
--
-- find the first 'A' element
-- a = parser:find(parser:root(), 'A')
--
-- Copyright 2009: hans@hpelbers.org
-- This is freeware

XL = {}

function XL:new()
  local x = {}
  setmetatable(x, self)
  self.__index = self
  return x
end

function XL._get_attrs(s)
  local arg = {}
  string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
  end)
  return arg
end

function XL:root()
  for _, v in ipairs(self.xml) do
    if v.tag then return v end
  end
  return nil
end

function XL:find(x, t)
  r = {}
  for _, v in ipairs(x) do
    if v.tag  and v.tag == t then r[#r+1] = v end
  end
  return r
end

function XL:from_file(s)
  local f=io.open(s)
  self:from_string(f:read('*all'))
  f:close()
end

function XL:from_string(s)
  self.xml = nil        -- reset
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,tag,attr, empty
  local i, j = 1, 1
  while true do
    ni,j,c,tag,attr, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {tag=tag, attr=self._get_attrs(attr)})
    elseif c == "" then   -- start tag
      top = {tag=tag, attr=self._get_attrs(attr)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..tag)
      end
      if toclose.tag ~= tag then
        error("trying to close "..toclose.tag.." with "..tag)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[stack.n].tag)
  end
  self.xml = stack[1]
end

return XL