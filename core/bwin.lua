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

module ('bwin', package.seeall)

require'Class'
require'screen'
require'event'

VERSION = '0.1'

Window = {}
local Window_mt = Class(Window)

local _windows = {}
local _winid = 0
local _active_win = nil

-- ghost stuff
local _syshandle = nil
local _consumer = nil

-- when to break out of main loop
local _inbusiness = true

--[[ PUBLIC API ]]

function test ()
	print('\tbwin registered.')--[[Window has the following API')
	for i,v in pairs(Window) do
		print('\t\t'..i,v)
	end]]
	return true
end

local function create_window(title, x, y, w, h)
	local winh = GHOST_CreateWindow(_syshandle,
			title,
			x,
			y,
			w,
			h,
			GHOST_kWindowStateNormal,
			GHOST_kDrawingContextTypeOpenGL, 0)
	if winh then
		_winid = _winid + 1
		_windows[_winid] = { window = nil, winh = winh, screens = {} }
	end
	
	_active_win = _winid
	
	return _winid
end

function Window:new(title, x, y, w, h)
	local newwin = setmetatable( {
		id = create_window(title,x,y,w,h),
		title = title,
		x = x,
		y = y,
		w = w,
		h = h,
		mx = 0, my = 0, mz = 0, -- mouse coords
		oldmx = 0, oldmy = 0, oldmz = 0,
		button = 0,
		screens = {},
		curscreen = nil,
		active_area = nil
	}, Window_mt)
	local cbounds = GHOST_GetClientBounds(_windows[newwin.id].winh)
	newwin.x, newwin.y, newwin.w, newwin.h = GHOST_GetRectangle(cbounds)
	GHOST_DisposeRectangle(cbounds)

	return newwin   
end

function Window:resize_screens()
	for i, v in ipairs(self.screens) do
		v.x = self.x
		v.y = self.y
		v.w = self.w
		v.h = self.h
	end
end

function Window:add_screen()
	local nextid = 1
	local newscr = screen.new(self.id, self.x, self.y, self.w, self.h)
	for i,v in ipairs(self.screens) do
		nextid = i+1
	end
	--print('Added screen to window ', self.id,'screen id', newscr.id, 'idx', nextid)
	self.screens[nextid] = newscr
	self.curscreen = newscr
end

function Window:print()
	print("Window " .. self.id .. " (" .. self.x .. " " .. self.y .. " " .. self.w .. " " .. self.h .. ")")
end

function destroy_window(id)
	GHOST_DisposeWindow(_syshandle, _windows[id]['winh'])
	_windows[id]['winh'] = nil
	print("destroyed window",id)
end

function destroy_all_windows()
	for i,v in pairs(_windows) do
		if v.winh then
			destroy_window(i)
		end
	end
end

function new(title, x, y, w, h)
	local win = Window:new(title, x, y, w, h)
	--print("new winid", win.id)
	_windows[win.id].window = win
	return win
end

function handle_events()
	for i,win in ipairs(_windows) do
		for j,area in ipairs(win.window.curscreen.areas) do
			area:handle_events()
		end
	end
end

function process_events(waitfor)
	if GHOST_ProcessEvents(_syshandle, waitfor) then
		GHOST_DispatchEvents(_syshandle)
	end
	return _inbusiness
end

function ortho(area, x1, x2, y1, y2, n, f)
	glMatrixMode(GL_PROJECTION)
	glLoadIdentity()
	
	glOrtho(x1, x2, y1, y2, n, f)
	
	glGetFloatv(GL_PROJECTION_MATRIX, area.winmat:ptr())
	glMatrixMode(GL_MODELVIEW)
end

function frustum(area, x1, x2, y1, y2, n, f)
	glMatrixMode(GL_PROJECTION)
	glLoadIdentity()

	glFrustum(x1, x2, y1, y2, n, f)
	glMatrixMode(GL_MODELVIEW)
end

function get_win_id(thewin)
	local win = nil
	
	for i,v in pairs(_windows) do
		if thewin == v.winh then
			win = v.window
			return win.id
		end
	end
	
	return -1
end

function get_window_amount()
	local nr = 0
	for i,v in pairs(_windows) do
		if v.winh then
			nr = nr+1
		end
	end
	return nr
end

function draw(thewin)

	local scr = nil
	local win = nil
	local winh = nil
	
	local winid = get_win_id(thewin)

	v = _windows[winid]
--	for i,v in pairs(_windows) do
		if thewin == v.winh then
			scr = v.window.curscreen
			win = v.window
			winh = v.winh
		end
--	end
	
	assert(scr and win and winh, "Blunder windowing system integrity check failed")	
		
	if winh then
		GHOST_ActivateWindowDrawingContext(winh)
		glViewport(scr.x, scr.y, scr.w, scr.h)
		glScissor(scr.x, scr.y, scr.w, scr.h)

		ortho(scr, -0.375, scr.w-0.375, -0.375, scr.h-0.375, -1000, 1000)
		glClearColor(0.55,0.55,0.55,0.0)
		glClear(GL_COLOR_BUFFER_BIT)
		
		for areai, area in pairs(scr.areas) do
			--if area.dodraw then
				area:draw_edges()
			--end
		end

	   for areai,area in pairs(scr.areas) do
			--if area.dodraw then
				glViewport(area.v1.x, area.v1.y, area.v3.x, area.v3.y)
				glScissor(area.v1.x, area.v1.y, area.v3.x, area.v3.y)
				
				glMatrixMode(GL_PROJECTION)
				glLoadIdentity()
				--glLoadMatrixd(area.winmat:ptr())
				--glTranslated(0, 0, area.vtrans.z)
				glMatrixMode(GL_MODELVIEW)
				glLoadIdentity()
				--glLoadMatrixd(area.viewmat:ptr())
				
				--[[if area.view_type=='2d' then
					print("2d view")
					ortho(area, -0.375, area.v3.x-0.375, -0.375, area.v3.y-0.375, 0.00001, 10000)
				else
					--frustum(area, -10, area.v3.x-0.375, -0.375, area.v3.y-0.375, -10000, 10000)
					frustum(area, area.totrct.xmin, area.totrct.xmax, area.totrct.ymin, area.totrct.ymax, -10000, 10000)
				end
				]]
				
				--glLoadIdentity()
				
				if area.application then
					area.application.draw(area)
				end
				area:draw_emboss()
				
				--area:print("area " .. areai)
	
				glFlush()
			--end
		end
		--print("---")
		glFinish()
		glDisable(GL_SCISSOR_TEST)
		GHOST_SwapWindowBuffers(winh)
		glEnable(GL_SCISSOR_TEST)
	end
end

--[[ PRIVATE API ]]

local function add_event(evt)
	if _windows[_active_win].window.active_area then
		_windows[_active_win].window.active_area:add_event(evt)
	end
end

--[[checking for quit event]]

-- TODO: create event queue and dispatch manager
-- we want dynamic events possible too
-- the core registers event types and applications
-- can register their own
local function bwin_event_proc(procevent, data)
	local handled = 1
	local proceventtype = GHOST_GetEventType(procevent)
	local proceventtime = GHOST_GetEventTime(procevent)
	local winh = GHOST_GetEventWindow(procevent)
	
	local winid = get_win_id(winh)
	
	if proceventtype == GHOST_kEventKeyDown then
		local key, ascii = GHOST_GetEventData("key", procevent)
		--[[TODO: key procevent dispatching ]]
		if ascii == 'q' then 
			_inbusiness = false
		else
			handled = 0
		end
	elseif proceventtype == GHOST_kEventWindowActivate then
		-- set active window
		for i,v in pairs(_windows) do
			if v['winh'] == winh then
				--print("active window: ",i, "at GHOST time", proceventtime, winh)
				_active_win = i
			end
		end
	elseif proceventtype == GHOST_kEventWindowDeactivate then
		local mywin = 0
		for i,v in pairs(_windows) do
			if v['winh'] == winh then
				mywin = i
			end
		end
		
		if mywin > 0 then -- this is to ensure no area is active when window is deactivated
			local scr = _windows[mywin].window.curscreen
			scr:select_area(-100, -100)
			draw(winh)
		end
	elseif proceventtype == GHOST_kEventWindowSize then
		-- do necessary resize stuff...
		local oldw, oldh
		
		if winh == _windows[_active_win].winh then
			oldw = _windows[_active_win].window.w
			oldh = _windows[_active_win].window.h
			
			client_rect= GHOST_GetClientBounds(winh)
			_windows[_active_win].window.x, _windows[_active_win].window.y, _windows[_active_win].window.w, _windows[_active_win].window.h = GHOST_GetRectangle(client_rect)
			GHOST_DisposeRectangle(client_rect)
			
			_windows[_active_win].window:resize_screens()
			_windows[_active_win].window.curscreen:resize_areas(oldw, oldh)
			
			draw(winh)
		end
	elseif proceventtype == GHOST_kEventCursorMove then
		local scr = _windows[_active_win].window.curscreen
		local x, y = GHOST_GetEventData("cursor", procevent)
		local mx,my = GHOST_ScreenToClient(winh, x, y)
		
		my = scr.h - 1 - my
		
		_windows[_active_win].window.oldmx = _windows[_active_win].window.mx
		_windows[_active_win].window.oldmy = _windows[_active_win].window.my
		_windows[_active_win].window.mx = mx
		_windows[_active_win].window.my = my
		_windows[_active_win].window.active_area = scr:select_area(mx, my)

		-- create new mouse procevent and push in procevent_queue of active_area
		local evt = event.Event:new('MOUSEMOVE', _windows[_active_win].window)
		add_event(evt)
		draw(winh)
	elseif proceventtype == GHOST_kEventButtonDown then
		local button = GHOST_GetEventData("button", procevent)

		if button==GHOST_kButtonMaskLeft then
			_windows[_active_win].window.button = bit.bor(_windows[_active_win].window.button, 1)
		end
		if button==GHOST_kButtonMaskMiddle then
			_windows[_active_win].window.button = bit.bor(_windows[_active_win].window.button, 2)
		end
		if button==GHOST_kButtonMaskRight then
			_windows[_active_win].window.button = bit.bor(_windows[_active_win].window.button, 4)
		end
		local evt = event.Event:new('MOUSEDOWN', _windows[_active_win].window)
		add_event(evt)
	elseif proceventtype == GHOST_kEventButtonUp then
		local button = GHOST_GetEventData("button", procevent)

		if button==GHOST_kButtonMaskLeft then
			_windows[_active_win].window.button = bit.bxor(_windows[_active_win].window.button, 1)
		end
		if button==GHOST_kButtonMaskMiddle then
			_windows[_active_win].window.button = bit.bxor(_windows[_active_win].window.button, 2)
		end
		if button==GHOST_kButtonMaskRight then
			_windows[_active_win].window.button = bit.bxor(_windows[_active_win].window.button, 4)
		end
		
		local evt = event.Event:new('MOUSEUP', _windows[_active_win].window)
		add_event(evt)		
	elseif proceventtype == GHOST_kEventWheel then
		_windows[_active_win].window.mz = GHOST_GetEventData("wheel", procevent)
		local evt = event.Event:new('WHEEL', _windows[_active_win].window)
		add_event(evt)
		_windows[_active_win].window.mz = 0
		draw(winh)
	elseif proceventtype == GHOST_kEventWindowUpdate then
		draw(winh)
	elseif proceventtype == GHOST_kEventWindowClose then
		local nrwins = get_window_amount()
		if get_window_amount() == 1 then -- this is last open window, so we quit blunder
			_inbusiness = false
		end
		destroy_window(winid)
	else
		handled = 0
	end
	
	return handled
end

--[[ MODULE INITIALISATION ]]

-- initialise GHOST - done while loading module
if not _syshandle then
	_syshandle = GHOST_CreateSystem()
	assert(_syshandle, "GHOST System could not be created")
	_consumer = GHOST_CreateEventConsumer(bwin_event_proc, nil)
	GHOST_AddEventConsumer(_syshandle, _consumer)
end


