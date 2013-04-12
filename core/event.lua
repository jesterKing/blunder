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

module ('event', package.seeall)

require'Class'

VERSION = '0.1'

Event = {}
local Event_mt = Class(Event)

--[[ PUBLIC API ]]

function Event:new(name,win)
	local newevt = setmetatable(
		{
			event_type = 0, -- create different types?
			event = 0, -- put in here event id
			name = name,
			window = win,
			x = win.mx, y = win.my, z = win.mz, -- mouse pos and wheel, calculated for screen
			ox = win.oldmx, oy = win.oldmy, oz = win.oldmz,
			button = win.button, -- mouse button status
			key = -1, -- keycode
			ascii = '\0', -- ascii code
			handler = nil, -- event can be assigned a callback
			target = 0, --[[TODO: figure out how to target from area to area]]
		}, Event_mt
	)
	return newevt
end

function test ()
	print('\tevent registered')
	return true
end

--[[ PRIVATE API ]]


--[[ MODULE INITIALISATION ]]
