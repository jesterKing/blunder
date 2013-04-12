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
function Class(members)
	members = members or {}
	local mt = {
		__metatable = members;
		__index		 = members;
	}
	local function new(_, init)
		return setmetatable(init or {}, mt)
	end
	local function copy(obj, ...)
		local newobj = obj:new(unpack(arg))
		for n,v in pairs(obj) do newobj[n] = v end
		return newobj
	end
	members.new	= members.new	or new
	members.copy = members.copy or copy
	return mt
end
