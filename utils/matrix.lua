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

module('matrix', package.seeall)

function mat4one(m)
	--print("mat4one",m)
	for i=0, 3 do
		for j=0, 3 do
			m[i+j*4] = 0.0
			if i == j then
				m[i+j*4] = 1.0
				--print("mat create: " .. i .. " = ".. j .. "("..(i+j*4)..")")
			end
			--io.stdout:write(m[i*j])
			--io.stdout:write(" ")
		end
		--io.stdout:write("\n")
	end
	--io.stdout:write("\n")
	--io.stdout:flush()
	--mat4print(m)
end

function mat4translate(m, t)

	--print("before translate",m,t)
	--mat4print(m)
	--print("--")
	--vec4print(t)
	--print(m[12], t[0])
	m[12] = m[12] + t[0]
	m[13] = m[13] + t[1]
	m[14] = m[14] + t[2]
	--m[15] = m[15] + t[3]
	
	--print(m[12], t[0])
	
	--print("after translate")
	--mat4print(m)
	

--[[
	m[3] = t[0]
	m[7] = t[1]
	m[11] = t[2]
	m[15] = t[3]
]]
end

function vec4print(v)
	for i=0,3 do
		io.stdout:write(v[i])
		io.stdout:write(" ")
	end
	io.stdout:write("\n")
	io.stdout:flush()
end

function mat4print(m)
	for i=0, 3 do
		for j=0, 3 do
			io.stdout:write(m[i+j*4])
			io.stdout:write(" ")
		end
		io.stdout:write("\n")
	end
	io.stdout:write("\n")
	io.stdout:flush()
end

