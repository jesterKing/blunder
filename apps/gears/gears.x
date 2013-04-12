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

--[[
Luafied version of GHOST gears test program
]]

print('_VERSION = ' .. _VERSION)

print('luagl.VERSION = '   .. luagl.VERSION)
print('luaghost.VERSION = ' .. luaghost.VERSION)

require 'blunder'

blunder.test()

print('Blunder.VERSION = ' .. blunder.VERSION)

hep = {}

local function set_cb(func)
	if type(func)=="function" then
		hep['callback'] = func
	end
end

local function cbtest() print("printed from callback") end
set_cb(cbtest)
hep.callback()



local inbusiness = true
local syshandle
local winhandle
local fullhandle
local consumer
local succ = 0
local cheat = 0
local view_rotx=20.0
local view_roty=30.0
local view_rotz=0.0
local fAngle = 0.0
local fps = 0
local current_cursor = GHOST_kStandardCursorFirstCursor

local function gearGL(inner_radius, outer_radius, width, teeth, tooth_depth)

	local i
	local r0, r1, r2
	local angle, da
	local u, v, len
	local pi = 3.14159264
	
	r0 = inner_radius
	r1 = (outer_radius - tooth_depth/2.0)
	r2 = (outer_radius + tooth_depth/2.0)
	
	da = (2.0*pi / teeth / 4.0)
	
	glShadeModel(GL_FLAT)
	glNormal3d(0.0, 0.0, 1.0)
	
	-- draw front face
	glBegin(GL_QUAD_STRIP)
	for i=0,teeth,1 do
		angle = (i * 2.0*pi / teeth)
		glVertex3d((r0*math.cos(angle)), (r0*math.sin(angle)), (width*0.5))
		glVertex3d((r1*math.cos(angle)), (r1*math.sin(angle)), (width*0.5))
		glVertex3d((r0*math.cos(angle)), (r0*math.sin(angle)), (width*0.5))
		glVertex3d((r1*math.cos(angle+3*da)), (r1*math.sin(angle+3*da)), (width*0.5))
	end
	glEnd()
	
	-- draw front sides of teeth
	glBegin(GL_QUADS)
	da = (2.0*pi / teeth / 4.0)
	for i=0,teeth-1,1 do
		angle = (i * 2.0*pi / teeth)
		glVertex3d((r1*math.cos(angle)), (r1*math.sin(angle)), (width*0.5))
		glVertex3d((r2*math.cos(angle+da)), (r2*math.sin(angle+da)), (width*0.5))
		glVertex3d((r2*math.cos(angle+2*da)), (r2*math.sin(angle+2*da)), (width*0.5))
		glVertex3d((r1*math.cos(angle+3*da)), (r1*math.sin(angle+3*da)), (width*0.5))
	end
	glEnd()
	
	glNormal3d(0.0, 0.0, -1.0)
	
	-- draw back face
	glBegin(GL_QUAD_STRIP)
	for i=0,teeth,1 do
		angle = (i * 2.0*pi / teeth)
		glVertex3d((r1*math.cos(angle)), (r1*math.sin(angle)), (-width*0.5))
		glVertex3d((r0*math.cos(angle)), (r0*math.sin(angle)), (-width*0.5))
		glVertex3d((r1*math.cos(angle+3*da)), (r1*math.sin(angle+3*da)), (-width*0.5))
		glVertex3d((r0*math.cos(angle)), (r0*math.sin(angle)), (-width*0.5))
	end
	glEnd()
	
	-- draw back sides of teeth
	glBegin(GL_QUADS)
	da = (2.0*pi / teeth / 4.0)
	for i=0,teeth-1,1 do
		angle = (i * 2.0*pi / teeth)
		glVertex3d((r1*math.cos(angle+3*da)), (r1*math.sin(angle+3*da)), (-width*0.5))
		glVertex3d((r2*math.cos(angle+2*da)), (r2*math.sin(angle+2*da)), (-width*0.5))
		glVertex3d((r2*math.cos(angle+da)), (r2*math.sin(angle+da)), (-width*0.5))
		glVertex3d((r1*math.cos(angle)), (r1*math.sin(angle)), (-width*0.5))
	end
	glEnd()
	
	-- draw outward faces of teeth
	glBegin(GL_QUAD_STRIP)
	for i=0,teeth-1,1 do
		angle = (i * 2.0*pi / teeth)
		glVertex3d((r1*math.cos(angle)), (r1*math.sin(angle)), (width*0.5))
		glVertex3d((r1*math.cos(angle)), (r1*math.sin(angle)), (-width*0.5))
		u = (r2*math.cos(angle+da) - r1*math.cos(angle))
		v = (r2*math.sin(angle+da) - r1*math.sin(angle))
		len = (math.sqrt(u*u + v*v))
		u = u/len
		v = v/len
		glNormal3d(v, -u, 0.0)
		glVertex3d((r2*math.cos(angle+da)), (r2*math.sin(angle+da)), (width*0.5))
		glVertex3d((r2*math.cos(angle+da)), (r2*math.sin(angle+da)), (-width*0.5))
		glNormal3d((math.cos(angle)), (math.sin(angle)), 0.0)
		glVertex3d((r2*math.cos(angle+2*da)), (r2*math.sin(angle+2*da)), (width*0.5))
		glVertex3d((r2*math.cos(angle+2*da)), (r2*math.sin(angle+2*da)), (-width*0.5))
		u = (r1*math.cos(angle+3*da) - r2*math.cos(angle+2*da))
		v = (r1*math.sin(angle+3*da) - r2*math.sin(angle+2*da))
		glNormal3d(v, -u, 0.0)
		glVertex3d((r1*math.cos(angle+3*da)), (r1*math.sin(angle+3*da)), (width*0.5))
		glVertex3d((r1*math.cos(angle+3*da)), (r1*math.sin(angle+3*da)), (-width*0.5))
		glNormal3d((math.cos(angle)), (math.sin(angle)), 0.0)
	end
	glVertex3d((r1*math.cos(0.0)), (r1*math.sin(0.0)), (width*0.5))
	glVertex3d((r1*math.cos(0.0)), (r1*math.sin(0.0)), (-width*0.5))
	glEnd()
	
	glShadeModel(GL_SMOOTH)
	
	-- draw inside radius cylinder
	glBegin(GL_QUAD_STRIP)
	for i=0,teeth,1 do
		angle = (i * 2.0*pi / teeth)
		glNormal3d((-math.cos(angle)), (-math.sin(angle)), 0.0)
		glVertex3d((r0*math.cos(angle)), (r0*math.sin(angle)), (-width*0.5))
		glVertex3d((r0*math.cos(angle)), (r0*math.sin(angle)), (width*0.5))
	end
	glEnd()
end

local function drawGearGL(id)
	local pos = { 5.0, 5.0, 10.0, 1.0 }
	local ared = { 0.8, 0.1, 0.0, 1.0 }
	local agreen = { 0.0, 0.8, 0.2, 1.0 }
	local ablue = { 0.2, 0.2, 1.0, 1.0 }
	
	glLightfv(GL_LIGHT0, GL_POSITION, pos);
	glEnable(GL_CULL_FACE);
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST);
	
	if id == 1 then
		glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, ared)
		gearGL(1.0, 4.0, 1.0, 20, 0.7)
	elseif id == 2 then
		glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, agreen)
		gearGL(0.5, 2.0, 2.0, 10, 0.7)
	elseif id == 3 then
		glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, ablue)
		gearGL(1.3, 2.0, 0.5, 10, 0.7)
	end

	glEnable(GL_NORMALIZE)
end

local function drawGL()
	glClear(GL_COLOR_BUFFER_BIT + GL_DEPTH_BUFFER_BIT)
	
	glPushMatrix()
	
	glRotated(view_rotx, 1.0, 0.0, 0.0)
	glRotated(view_roty, 0.0, 1.0, 0.0)
	glRotated(view_rotz, 0.0, 0.0, 1.0)
	
	glPushMatrix()
	glTranslated(-3.0, -2.0, 0.0)
	glRotated(fAngle, 0.0, 0.0, 1.0)
	drawGearGL(1)
	glPopMatrix()
	
	glPushMatrix()
	glTranslated(3.1, -2.0, 0.0)
	glRotated((-2.0*fAngle-9.0), 0.0, 0.0, 1.0)
	drawGearGL(2)
	glPopMatrix()
	
	glPushMatrix()
	glTranslated(-3.1, 2.2, -1.8)
	glRotated(90.0, 1.0, 0.0, 0.0)
	glRotated((2.0*fAngle-2.0), 0.0, 0.0, 1.0)
	drawGearGL(3)
	glPopMatrix()
	
	glPopMatrix()
end


local function setViewPortGL(winh)
	local hRect
	local w
	local h
	
	GHOST_ActivateWindowDrawingContext(winh)
	hRect = GHOST_GetClientBounds(winh)
	
	w = GHOST_GetWidthRectangle(hRect) / GHOST_GetHeightRectangle(hRect)
	h = 1.0
	
	glViewport(0, 0, GHOST_GetWidthRectangle(hRect), GHOST_GetHeightRectangle(hRect))

	glMatrixMode(GL_PROJECTION)
	glLoadIdentity()
	glFrustum(-w, w, -h, h, 5.0, 60.0)
	
	glMatrixMode(GL_MODELVIEW)
	glLoadIdentity()
	glTranslated(0.0, 0.0, -40.0)
	
	glClearColor(.2,0.0,0.0,0.0)
	glClear(GL_COLOR_BUFFER_BIT)

	GHOST_DisposeRectangle(hRect)
end

local function timer_func(timerh, time)
	local winh = GHOST_GetTimerTaskUserData(timerh)
	fAngle = fAngle + 2.0
	view_roty = view_roty + 1.0
	
	if GHOST_GetFullScreen(syshandle) == 1 then
		GHOST_InvalidateWindow(fullhandle)
	else
		if GHOST_ValidWindow(syshandle, winh) then
			GHOST_InvalidateWindow(winh)
		end
	end
	fps = fps + 1
end

local function fps_func(timerh, time)
	local winh = GHOST_GetTimerTaskUserData(timerh)
	print("FPS: " .. fps)
	fps = 0
end

local function cursor_changer(timerh, timer)
	local winh = GHOST_GetTimerTaskUserData(timerh)
	current_cursor = current_cursor + 1
	if current_cursor >= GHOST_kStandardCursorNumCursors then
		current_cursor = GHOST_kStandardCursorFirstCursor
	end
	GHOST_SetCursorShape(winh, current_cursor)
end

local function event2_consumer(event, data)
	local handled = 1
	local eventtype = GHOST_GetEventType(event)
	local locwin = GHOST_GetEventWindow(event)
	
	if locwin == winhandle then
		return 0
	end
	
	--[[if eventtype == GHOST_kEventCursorMove then
		GHOST_SetWindowOrder(win2handle, GHOST_kWindowOrderTop)
	end]]
	
	if eventtype == GHOST_kEventWheel then
		local wheelz = GHOST_GetEventData("wheel", event)
		view_rotz = view_rotz + (30*wheelz)
	elseif eventtype == GHOST_kEventKeyDown then
		local key, ascii = GHOST_GetEventData("key", event)
		if key == GHOST_kKeyW then
			local title = GHOST_GetTitle(win2handle)
			title = title .. '+'
			GHOST_SetTitle(win2handle, title)
		elseif key == GHOST_kKeyQ or key == GHOST_kKeyEsc then
			if locwin == win2handle then
				GHOST_DisposeWindow(syshandle, win2handle)
				win2handle = nil
			end
		end
	elseif eventtype == GHOST_kEventWindowClose then
		if locwin == win2handle then
			GHOST_DisposeWindow(syshandle, win2handle)
			win2handle = nil
		end
	elseif eventtype == GHOST_kEventWindowActivate then
		handled = 0
	elseif eventtype == GHOST_kEventWindowDeactivate then
		handled = 0
	elseif eventtype == GHOST_kEventWindowUpdate then
		local window2 = GHOST_GetEventWindow(event)
		if GHOST_ValidWindow(syshandle, window2) then
			setViewPortGL(window2)
			drawGL()
			GHOST_SwapWindowBuffers(window2)
			if winhandle then
				setViewPortGL(winhandle)
				drawGL()
				GHOST_SwapWindowBuffers(winhandle)
			end
		end
	else
		handled = 0
	end
	
	return handled
end

local function event_consumer(event, data)
	local handled = 1
	local eventtype = GHOST_GetEventType(event)
	local locwin = GHOST_GetEventWindow(event)
		
	if locwin == win2handle then
		return 0
	end
	
	--[[if eventtype == GHOST_kEventCursorMove then
		GHOST_SetWindowOrder(winhandle, GHOST_kWindowOrderTop)
	end]]
	
	if eventtype == GHOST_kEventWheel then
		local wheelz = GHOST_GetEventData("wheel", event)
		view_rotz = view_rotz + (10*wheelz)
	elseif eventtype == GHOST_kEventKeyDown then
		local key, ascii = GHOST_GetEventData("key", event)
		if key == GHOST_kKeyW then
			local title = GHOST_GetTitle(winhandle)
			title = title .. '-'
			GHOST_SetTitle(winhandle, title)
		elseif key == GHOST_kKeyQ or key == GHOST_kKeyEsc then
			inbusiness = false
		elseif key == GHOST_kKeyC then
			if GHOST_SetClientSize(locwin, 1000, 1000) == 1 then
				print ("SetClientSize successfull")
			end
		elseif key == GHOST_kKeyF then
			print(GHOST_GetFullScreen(syshandle))
			if GHOST_GetFullScreen(syshandle)==0 and not fullhandle then
				local setting = {} -- for setting fullscreen table must look like follows
				setting["xPixels"] = 800
				setting["yPixels"] = 600
				setting["bpp"] = 24
				setting["frequency"] = 85
				fullhandle = GHOST_BeginFullScreen(syshandle, setting, 1)
			elseif fullhandle then
				GHOST_EndFullScreen(syshandle)
				fullhandle = nil
			end
		end
	elseif eventtype == GHOST_kEventCursorMove then
		local x, y = GHOST_GetEventData("cursor", event)
		--[[print (x, y)
		print ('ScreenToClient winhandle: ',GHOST_ScreenToClient(winhandle, x, y))
		if win2handle then
			print ('ScreenToClient win2handle: ',GHOST_ScreenToClient(win2handle, x, y))
		end]]
	elseif eventtype == GHOST_kEventWindowClose then
		if locwin == winhandle then
			inbusiness = false
		elseif locwin == win2handle then
			GHOST_DisposeWindow(syshandle, win2handle)
			win2handle = nil
		end
	elseif eventtype == GHOST_kEventWindowActivate then
		handled = 0
	elseif eventtype == GHOST_kEventWindowDeactivate then
		handled = 0
	elseif eventtype == GHOST_kEventWindowUpdate then
		if GHOST_ValidWindow(syshandle, locwin) then
			setViewPortGL(locwin)
			drawGL()
			GHOST_SwapWindowBuffers(locwin)
			if win2handle then
				setViewPortGL(win2handle)
				drawGL()
				GHOST_SwapWindowBuffers(win2handle)
			end
		end
	elseif eventtype == GHOST_kEventWindowSize then
		clrect = GHOST_GetClientBounds(locwin)
		winrect = GHOST_GetWindowBounds(locwin)
		local l,t,r,b = GHOST_GetRectangle(clrect)
		--local wl, wt, wr, wb = GHOST_GetRectangle(winrect)
		local scrw, scrh = GHOST_GetMainDisplayDimensions(syshandle)
		print('client resize', GHOST_GetRectangle(clrect))
		--GHOST_UnionPointRectangle(clrect, 1000, 700)
		--print('unionpointrectangle', GHOST_GetRectangle(clrect))
		print('window resize', GHOST_GetRectangle(winrect))
		print('new coords', l, scrh-b-1,r-l,b-t)
		GHOST_DisposeRectangle(clrect)
		GHOST_DisposeRectangle(winrect)
	else
		handled = 0
	end
	
	return handled
end

syshandle = GHOST_CreateSystem()

winhandle = GHOST_CreateWindow(syshandle, "terve", 10, 10, 500, 500, GHOST_kWindowStateNormal, GHOST_kDrawingContextTypeOpenGL)
win2handle = GHOST_CreateWindow(syshandle,
			"morjens",
			520,
			10,
			320,
			200,
			GHOST_kWindowStateNormal,
			GHOST_kDrawingContextTypeOpenGL,
			FALSE)
timerhandle = GHOST_InstallTimer(syshandle, 0, 10, timer_func, winhandle)

timer2handle = GHOST_InstallTimer(syshandle, 1000, 1000, fps_func, win2handle)
cursor_timer = GHOST_InstallTimer(syshandle, 2000, 2000, cursor_changer, winhandle)

consumer = GHOST_CreateEventConsumer(event_consumer, winhandle)
consumer2 = GHOST_CreateEventConsumer(event2_consumer, win2handle)

GHOST_AddEventConsumer(syshandle, consumer)
GHOST_AddEventConsumer(syshandle, consumer2)

GHOST_SetCursorShape(winhandle, current_cursor)
GHOST_SetCursorShape(win2handle, GHOST_kStandardCursorBottomSide)

print('Number of displays = ' .. GHOST_GetNumDisplays(syshandle))
w,h = GHOST_GetMainDisplayDimensions(syshandle)
print('Main display width = ' .. w .. ' main display height = ' .. h)

recth = GHOST_GetWindowBounds(winhandle)
recth2 = GHOST_GetClientBounds(winhandle)
print(">>>", GHOST_GetRectangle(recth))
print(">>>", GHOST_GetRectangle(recth2))


GHOST_SetWindowOrder(winhandle, GHOST_kWindowOrderTop)

while inbusiness do
	if GHOST_ProcessEvents(syshandle, 0) then
		if not GHOST_DispatchEvents(syshandle) then
			print("couldn't dispatch events")
		end
	end
end

if winhandle and GHOST_ValidWindow(syshandle, winhandle) then
	if GHOST_DisposeWindow(syshandle, winhandle) then
		print("Disposed window properly")
	else
		print("Coudn't dispose window")
	end
end

if win2handle and GHOST_ValidWindow(syshandle, win2handle) then
	if GHOST_DisposeWindow(syshandle, win2handle) then
		print("Disposed window properly")
	else
		print("Coudn't dispose window")
	end
end

if fullhandle and GHOST_ValidWindow(syshandle, fullhandle) then
	if GHOST_DisposeWindow(syshandle, fullhandle) then
		print("Disposed window properly")
	else
		print("Coudn't dispose window")
	end
end

succ = GHOST_DisposeSystem(syshandle)
GHOST_DisposeEventConsumer(consumer)

if succ == 1 then
	print("Creating a GHOST system and disposing it was successful")
end
