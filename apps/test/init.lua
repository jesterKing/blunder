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
init.lua for test
]]

module('test', package.seeall)

require'test.mysub'
require'test.tools.tooltest'

is_app = true
view_type = '3d'

local xyz = memarray('float', 4)
local rxyz = memarray('float', 4)
xyz[0], xyz[1], xyz[2], xyz[3] = 0.0, 0.0, 0.0, 1.0
rxyz[0], rxyz[1], rxyz[2], rxyz[3] = 0.0, 0.0, 0.0, 1.0

local function register_events()
end

local function register_handlers()
end

--[[ public API for Blunder applications ]]

--TODO: figure out how to mimic Blender area code properly
function draw(area)

    local fov = (180*(2.0 * math.atan2(area.vtrans.z/2.0, 10.0)))/3.1415926535
    glClear(GL_COLOR_BUFFER_BIT + GL_DEPTH_BUFFER_BIT)
    --glMatrixMode(GL_PROJECTION)
    --glPushMatrix()
    --glLoadIdentity()
    bwin.frustum(area, area.totrct.xmin, area.totrct.xmax, area.totrct.ymin, area.totrct.ymax, .000001, 10000)
    --print(fov)
    --gluPerspective(fov, 1.0, -100, 100)
    --glFrustum(-1,1,-1, 1, -100, 100)
    --glTranslated(0, 0, area.vtrans.z)
    --glPopMatrix()
    
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    
    -- viewing transforms
    if false then --area.first==true then
        area.vtrans.z = 10000.0
        area.vtrans.x = 0
        area.vtrans.y = 0
        area.first = false
        gluLookAt(area.vtrans.x, area.vtrans.y, area.vtrans.z, area.vtrans.x, area.vtrans.y, 0.0, 0.0, 1.0, 0.0)
    else
        --gluLookAt(area.vtrans.x, area.vtrans.y, area.vtrans.z, area.vtrans.x, area.vtrans.y, 0.0, 0.0, 1.0, 0.0)
        glTranslated(area.vtrans.x, area.vtrans.y, 0) --area.vtrans.z)
        
        --if not(area.vrot.ax==0) then
        glRotated(area.vrot.ax, 1, 0, 0)
        --end
        --if not(area.vrot.ay==0) then
        glRotated(area.vrot.ay, 0, 1, 0)
        --end
        --if not area.vrot.az==0 then
        glRotated(area.vrot.az, 0, 0, 1)
        --end
        
        --if not(area.vscale.sz==0) then
        --glScaled(area.vscale.sx*10, area.vscale.sy*10, area.vscale.sz*10)
    end

    glBegin(GL_QUADS)
        glColor3d(1,1,0)
        glVertex3d( -10, 10, -10)
        glColor3d(0,1,0)
        glVertex3d( 10, 10, -10)
        glColor3d(0,1,1)
        glVertex3d( 10, -10, -10)
        glColor3d(1,0,0)
        glVertex3d( -10, -10, -10)
        
        glColor3d(1,1,0)
        glVertex3d( -10, 10, 10.0)
        glColor3d(0,1,0)
        glVertex3d( 10, 10, 10.0)
        glColor3d(0,1,1)
        glVertex3d( 10, -10, 10.0)
        glColor3d(1,0,0)
        glVertex3d( -10, -10, 10.0)
        
        glColor3d(1,1,0)
        glVertex3d( -10, 10, -10.0)
        glColor3d(0,1,1)
        glVertex3d( -10, 10, 10.0)
        glColor3d(1,0,0)
        glVertex3d( 10, 10, 10.0)
        glColor3d(0,1,0)
        glVertex3d( 10, 10, -10.0)
        
        glColor3d(1,1,0)
        glVertex3d( 10, -10, -10.0)
        glColor3d(0,1,1)
        glVertex3d( 10, -10, 10.0)
        glColor3d(1,0,0)
        glVertex3d( 10, 10, 10.0)
        glColor3d(0,1,0)
        glVertex3d( 10, 10, -10.0)
        
    glEnd()
    glFlush()
end

function handle_event(area, evt)
    if area == evt.window.active_area then
        if evt.name == 'MOUSEMOVE' and bit.band(evt.button, 4) == 4 then
            xyz[0] = (evt.ox - evt.x)/-1.2
            xyz[1] = (evt.oy - evt.y)/-1.2
            area.vtrans.x = area.vtrans.x + xyz[0]
            area.vtrans.y = area.vtrans.y + xyz[1]
        end
        if evt.name == 'MOUSEMOVE' and bit.band(evt.button, 2) == 2 then
            rxyz[0] = (evt.x - evt.ox) * 10 / 16
            rxyz[1] = (evt.y - evt.oy) * 10 / 16
            area.vrot.ax = area.vrot.ax + rxyz[0]
            area.vrot.ay = area.vrot.ay + rxyz[1]
            area.vrot.az = area.vrot.az + rxyz[2]
        end
        if evt.name == 'MOUSEMOVE' and bit.band(evt.button, 1) == 1 then
            --area.first = true
        end
        if evt.name == 'WHEEL' then
            --io.stdout:write(".")
            --area.vscale.sz = area.vscale.sz + evt.z
            --io.stdout:write(area.vscale.sz)
            --io.stdout:write(" ")
            area.vtrans.z = area.vtrans.z + evt.z
            --[[io.stdout:write(area.vtrans.z)
            io.stdout:write(" ")]]
            --area.vrot.az = area.vrot.az + evt.z*100/16
        end
    end
    return true
end

function initialise()
    print("Init for apps/test", test._NAME)
end
