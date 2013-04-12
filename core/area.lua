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

module('area', package.seeall)

require'Class'
require'matrix'
require'bwin'
--require'event'

Area = {}

local Area_mt = Class(Area)

EDGEWIDTH = 1
AREAGRID = 4
AREAMINX = 32
AREAMINY = AREAMINX + EDGEWIDTH
HEADERY = 26

local view_rotx=20.0
local view_roty=30.0
local view_rotz=0.0
local fAngle = 0.0

function draw_line(x1, y1, x2, y2)
	glBegin(GL_LINE_STRIP)
	glVertex2d(x1, y1)
	glVertex2d(x2, y2)
	glEnd()
end

function Area:calc_rcts()
	if self.v1.x>0 then
		self.totrct.xmin= self.v1.x+1
	else
		self.totrct.xmin= self.v1.x
	end
	if self.v4.x<self.screen.w-1 then
		self.totrct.xmax= self.v4.x-1
	else
		self.totrct.xmax= self.v4.x
	end
	
	if self.v1.y>0 then
		self.totrct.ymin= self.v1.y+1
	else
		self.totrct.ymin= self.v1.y
	end
	if self.v2.y<self.screen.h-1 then
		self.totrct.ymax= self.v2.y-1
	else
		self.totrct.ymax= self.v2.y
	end
	
	self.winx= self.totrct.xmax-self.totrct.xmin+1
	self.winy= self.totrct.ymax-self.totrct.ymin+1
end

function Area:scale(facx, facy)
	--self:print("before scale")

	self.v1.x = self.v1.x * facx
	self.v1.y = self.v1.y * facy

	self.v2.x = self.v2.x * facx
	self.v2.y = self.v2.y * facy

	self.v3.x = self.v3.x * facx
	self.v3.y = self.v3.y * facy

	self.v4.x = self.v4.x * facx
	self.v4.y = self.v4.y * facy

	--self:print("after scale")
end

function Area:add_event(evt)
	table.insert(self.event_queue, 1, evt)
end

function Area:handle_events()
	if self.event_queue then
		evt = self.event_queue[#self.event_queue]
		
		if evt and self.application then
			if self.application.handle_event(self, evt) then
				table.remove(self.event_queue)
			end
		end
	end
end

function Area:set_application(app)
	if app and app.is_app then
		self.application = app
		print(self.application._NAME .. ' set as application for area', self)
	if app.view_type then
		self.view_type = app.view_type
	end
	end
end

function Area:new(x,y,w,h,scr)
	assert(scr, 'No valid screen given')
	
	local newarea = setmetatable(
		{
			v1={x=x,y=y,flag=0},
			v2={x=x,y=h,flag=0},
			v3={x=w,y=h,flag=0},
			v4={x=w,y=y,flag=0},
			totrct={xmin=0,xmax=0,ymin=0,ymax=0},
			winx = 0,
			winy = 0,
			flag = 0,
			selected = false,
			dodraw = true,
			first = true,
			screen = scr,
			vrot = {ax = 0, ay = 0, az = 0},
			vtrans = {x = 0, y = 0, z = 0},
			vscale = {sx = 1, sy = 1, sz = 1},
			winmat = memarray('GLfloat', 4*4),
			viewmat = memarray('GLfloat', 4*4),
			application = nil,
		view_type = '2d',
			event_queue = {}
		},
		Area_mt)
	matrix.mat4one(newarea.winmat)
	matrix.mat4one(newarea.viewmat)
	newarea:calc_rcts()
	
	return newarea
end

function Area:print(str)
	print(str..": v1="..self.v1.x..","..self.v1.y..
			", v2="..self.v2.x..","..self.v2.y..
			", v3="..self.v3.x..","..self.v3.y..
			", v4="..self.v4.x..","..self.v4.y)
	print("\t" .. self.winx .. ","..self.winy.."  ",self.selected)
end

function Area:has_mouse(x,y)
	if x>self.totrct.xmin and x<self.totrct.xmax and
		y>self.totrct.ymin and y<self.totrct.ymax then
		return true
	else
		return false
	end
	
end

function Area:select(x, y)
	if self:has_mouse(x, y) then
		if not self.selected then
			--self:print("selecting area ".. x..","..y)
			self.selected = true
			return self
		else
			return self
		end
	else
		if self.selected then
			--self:print("deselecting area ".. x..","..y)
			self.selected = false
			return nil
		end
		return nil
	end
end

-- make private API?
function testsplitpoint(ar, dir, fac)
	local x, y
	
	--print("testsplitpoint", dir, fac)

	if ar.v4.x-ar.v1.x <= 2*AREAMINX then return nil end
	if ar.v2.y-ar.v1.y <= 2*AREAMINY then return nil end
	
	if fac < 0.0 then fac = 0.0 end
	if fac > 1.0 then fac = 1.0 end
	
	if dir=='h' then
		y = ar.v1.y + fac * (ar.v2.y-ar.v1.y)
		if (ar.v2.y==ar.screen.w-1 and ar.v2.y-y < HEADERY) then
			y = ar.v2.y - HEADERY
		elseif (ar.v1.y==0 and y-ar.v1.y < HEADERY) then
			y = ar.v1.y + HEADERY
		elseif y-ar.v1.y < AREAMINY then
			y = ar.v1.y + AREAMINY
		elseif ar.v2.y - y < AREAMINY then
			y = ar.v2.y - AREAMINY
		else
			y = y - (y % AREAGRID)
		end
		
		return y
	else
		x = ar.v1.x + fac * (ar.v4.x-ar.v1.x);
		if x - ar.v1.x < AREAMINX then
			x = ar.v1.x + AREAMINX
		elseif ar.v4.x - x < AREAMINX then
			x = ar.v4.x - AREAMINX
		else
			x = x - (x % AREAGRID)
		end
		
		return x
	end

	return 1
end

function Area:split(dir, fac)
	local split = testsplitpoint(self, dir, fac);
	local newarea = nil
	local nextareaid = 1
	
	if not split then return end
	
	--print(self, dir, fac, split)
	--self:print("area before")
	
	if dir=='h' then
		newarea = area.Area:new(self.v1.x, split, self.v3.x, self.v3.y, self.screen)
		self.v2.y = split
		self.v3.y = split
	else
		newarea = area.Area:new(split, self.v1.y, self.v3.x, self.v3.y, self.screen)
		self.v3.x = split
		self.v4.x = split
	end
	
	--self:print("area after")
	--newarea:print("newarea")
	
	return newarea
end

function Area:draw_edges()
	local x1 = self.v1.x
	local y1 = self.v1.y
	local x2 = self.v3.x
	local y2 = self.v3.y
	
	--[[x1 = 0
	y1 = 0
	x2 = self.winx-1
	y2 = self.winy-1]]
	
	glColor3d(0.55, 0.55, 0.55)
	
	--print(x2,y1,x2,y2)
	draw_line(x2, y1, x2, y2)
	--print(x1, y1, x2, y1)
	draw_line(x1, y1, x2, y1)
	
	glColor3d(0,0,0)
	
	draw_line(x2, y1, x2, y2) -- right border
	
	if x1>0 then
		draw_line(x1, y1, x1, y2) -- left
	end

	draw_line(x1, y2, x2, y2) -- top

	draw_line(x1, y1, x2, y1) -- bottom
end

function Area:draw_emboss()
	bwin.ortho(self, -0.375, self.v3.x-0.375, -0.375, self.v3.y-0.375, 0.00001, 10000)
	glLoadIdentity()
	glEnable( GL_BLEND )
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA )
	
	-- right
	glColor4d(0, 0, 0, 80)
	draw_line(self.winx-1, 0, self.winx-1, self.winy-1)
	
	-- bottom
	glColor4d(0, 0, 0, 128)
	draw_line(0, 0, self.winx-1, 0)
	
	-- top
	glColor4d(255,255,255, 96)
	draw_line(0, self.winy-1,self.winx-1,self.winy-1)
	
	-- left
	glColor4d( 255, 255, 255, 80)
	draw_line(0, 1, 0, self.winy)
	
	if self.selected then
		glColor4d( 0, 12, 0, 10)
		glBegin(GL_QUADS)
			glVertex2d(3, self.winy-8)
			glVertex2d(3, self.winy-3)
			glVertex2d(8, self.winy-3)
			glVertex2d(8, self.winy-8)
		glEnd()
	end
	
	glDisable( GL_BLEND )
end

function test ()
	print('\tarea registered.')--[[ Following functions for Area are available')
	for i,v in pairs(Area) do
		print('\t\t'..i,v)
	end]]
	return true
end
