--[[
/*
 * Copyright (C) 2007, Nathan Letwory
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 59 Temple Place,
 * Suite 330, Boston
 * MA 02111-1307 USA
 *
 * Contributors: Nathan Letwory.
 */
]]

module ('screen', package.seeall)

require'Class'
require'area'
require'matrix'

VERSION = '0.1'

local _screens = {}
local _screenid = 0

Screen = {}
local bScreen_mt = Class(Screen)


--[[ PUBLIC API ]]

function Screen:select_area(x, y)
	local selected_area = nil
	for i, area in ipairs(self.areas) do
		selected_area = area:select(x, y) -- return the selected area
		if selected_area then return selected_area end
	end
	return selected_area
end

function Screen:test_areas()
	for i,v in ipairs(self.areas) do
		v:calc_rcts()
	end
end

function Screen:add_area(ar)
	local nextareaid = 1
	for i,v in ipairs(self.areas) do
		nextareaid = nextareaid +1
	end
	
	self.areas[nextareaid] = ar
	
	self:test_areas()
end

function Screen:resize_areas(oldw, oldh)
	local facx, facy
	
	facx = self.w / oldw
	facy = self.h / oldh
	
	for i, v in ipairs(self.areas) do
		v:scale(facx, facy)
	end
	
	self:test_areas()
end

function Screen:new(winid,x,y,w,h)
	local newscr = setmetatable(
		{
			winid=winid,
			x=x,
			y=y,
			w=w,
			h=h,
			areas={},
			id=0,
			winmat = memarray('float', 4*4),
			viewmat = memarray('float', 4*4)
		}, bScreen_mt)
	_screenid = _screenid + 1
	newscr.id = _screenid
	matrix.mat4one(newscr.winmat)
	matrix.mat4one(newscr.viewmat)
	
	local newarea = area.Area:new(0,0,w,h,newscr)
	newscr:add_area(newarea)
	
	return newscr
end

function Screen:attach(winid)
	self.winid = winid
end

function Screen:has_mouse(x,y)
	if x>self.x and x<self.w and y>self.y and y<self.h then
		return true
	else
		return false
	end
end

function test ()
	print('\tscreen registered.')--[[ Following functions for Screen are available')
	for i,v in pairs(Screen) do
		print('\t\t'..i,v)
	end]]
	return true
end

function add_default_screen()
	scr = Screen:new(12,10,10,500,500)
	--print(scr:has_mouse(1000,300))
	--print(scr:has_mouse(300,300))
end

function new(winid, x, y, w, h)
	local scr = Screen:new(winid, x, y, w, h)
	
	_screens[scr.id] = {}
	_screens[scr.id].screen = scr
	return scr
end

--[[ PRIVATE API ]]


--[[ MODULE INITIALISATION ]]
