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

module ('blunder', package.seeall)

require'mouse'
require'key'
require'bwin'


VERSION = '0.0.6'

-- make the module callable
local mt = getmetatable(_M)
if not mt then
	mt = {}
	setmetatable(_M, mt)
end

mt.__call = function(obj, ...)
	run()
end

function test ()
	print('\tblunder registered')
	return true
end

local function print_matrix(mat,w,h)
	for i = 0,(w*h-1) do
		print(mat[i])
	end
end

local win1 = nil
local win2 = nil
local win3 = nil
local win4 = nil

local function initialise()
	local r = memarray('GLint', 1)
	local g = memarray('GLint', 1)
	local b = memarray('GLint', 1)
	local auxbuf = memarray('GLint', 1)
	
	--local winmat = memarray('float', 4*4)
	--local viewmat = memarray('float', 4*4)
	
	win1 = bwin.new("Blunder", 10, 10, 500, 500)
	--win1:print()
	win1:add_screen()
	win1.screens[1]:add_area(win1.screens[1].areas[1]:split('h',0.32))
	win1.screens[1].areas[1]:set_application(_G.applications['test'])
	--[[win1.screens[1]:add_area(win1.screens[1].areas[1]:split('h',0.32))
	win1.screens[1]:add_area(win1.screens[1].areas[2]:split('v',0.50))]]
	win2 =bwin.new("Blunder2", 518, 10, 300, 300)
	--win2:print()
	win2:add_screen()
	win2.screens[1]:add_area(win2.screens[1].areas[1]:split('v',0.50))
	win2.screens[1]:add_area(win2.screens[1].areas[1]:split('h',0.50))
	win2.screens[1]:add_area(win2.screens[1].areas[2]:split('h',0.50))
	win2.screens[1]:add_area(win2.screens[1].areas[4]:split('v',0.50))
	win2.screens[1]:add_area(win2.screens[1].areas[4]:split('h',0.50))
	win2.screens[1]:add_area(win2.screens[1].areas[1]:split('h',0.50))
	
	win1.screens[1].areas[1]:set_application(_G.applications['test'])
	win1.screens[1].areas[2]:set_application(_G.applications['test'])
	
	win3 = bwin.new("Blunder3", 10, 520, 300, 500)
	--win3:print()
	win3:add_screen()
	win3.screens[1]:add_area(win3.screens[1].areas[1]:split('h',0.32))
	win3.screens[1]:add_area(win3.screens[1].areas[2]:split('v',0.50))
	win3.screens[1].areas[2]:set_application(_G.applications['test'])
	
	win4 = bwin.new("Blunder4", 520, 520, 500, 300)
	--win4:print()
	win4:add_screen()
	win4.screens[1]:add_area(win4.screens[1].areas[1]:split('h',0.32))
	win4.screens[1]:add_area(win4.screens[1].areas[2]:split('v',0.50))
	
	glGetIntegerv(GL_RED_BITS, r:ptr())
	glGetIntegerv(GL_GREEN_BITS, g:ptr())
	glGetIntegerv(GL_BLUE_BITS, b:ptr())
	glGetIntegerv(GL_AUX_BUFFERS, auxbuf:ptr())
	
	--glGetFloatv(GL_PROJECTION_MATRIX, winmat:ptr())
	--glGetFloatv(GL_MODELVIEW_MATRIX, viewmat:ptr())

	print('Color depth: r = ' .. r[0] .. ' g = ' .. g[0] .. ' b = ' .. b[0])
	print('Aux buffers: ' .. auxbuf[0])
end

local function quit()
	bwin.destroy_all_windows()
	print("Blunder shut down")
end

function run()
	initialise()
	while bwin.process_events(0) do bwin.handle_events() end
	quit()
end
