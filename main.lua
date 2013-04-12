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

Entry point of Blunder
]]

-- set the search path for all modules
package.path = ";;./?.lua;./core/?.lua;./utils/?.lua;./apps/?/init.lua;./apps/?.lua"
-- in case we distribute compiled Lua
package.path = package.path .. ";./?.lc;./core/?.lc;./utils/?.lc;./apps/?.lc"

print('_VERSION = ' .. _VERSION)

require'blunder'
require'event'

print('luagl.VERSION = '   .. luagl.VERSION)
print('luaghost.VERSION = ' .. luaghost.VERSION)
print('Blunder.VERSION = ' .. blunder.VERSION)

startdir = "./apps/"
dir = lfs.dir(startdir)

_G.applications = {}

for i in dir do
	if not (i=='.' or i=='..' or i=='.svn') then
		newlib = "require'"..i.."'"
		init = loadstring(newlib)
		init(i)
		_G[i].initialise()
		
		_G.applications[_G[i]._NAME] = _G[i]
	end
end

print("Starting systems...")
if bwin.test() and 
	screen.test() and
	area.test() and
	mouse.test() and
	key.test() and
	blunder.test()
then
	print("Blunder core up and running")
	blunder()
else
	print("Blunder core incomplete. Bailing out")
end

