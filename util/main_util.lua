function UTM.load_cards(items, path)
    for i = 1, #items do
        SMODS.load_file(path .. "/" .. items[i] .. ".lua")()
    end 
end

local prep_draw_ref = prep_draw
function prep_draw(moveable, scale, rotate, offset, meh, check)
    if check then
        love.graphics.push()
        love.graphics.scale(G.TILESCALE*G.TILESIZE)
        
        -- Calculate the center position for translation
        local centerX = moveable.VT.x + moveable.VT.w / 2
        local centerY = moveable.VT.y + moveable.VT.h / 2
        
        -- Adjust translation to account for scaling
        love.graphics.translate(
            centerX + (offset and offset.x or 0) + ((moveable.layered_parallax and moveable.layered_parallax.x) or ((moveable.parent and moveable.parent.layered_parallax and moveable.parent.layered_parallax.x)) or 0),
            centerY + (offset and offset.y or 0) + ((moveable.layered_parallax and moveable.layered_parallax.y) or ((moveable.parent and moveable.parent.layered_parallax and moveable.parent.layered_parallax.y)) or 0)
        )
        
        if moveable.VT.r ~= 0 or moveable.juice or rotate then 
            love.graphics.rotate(moveable.VT.r + (rotate or 0)) 
        end
        
        love.graphics.translate(
            -scale * moveable.VT.w * (moveable.VT.scale),
            -scale * moveable.VT.h * (moveable.VT.scale)
        )
        love.graphics.scale(moveable.VT.scale * scale)
    else    
        prep_draw_ref(moveable, scale, rotate, offset)
    end 
end

local draw_shader_ref = Sprite.draw_shader
function Sprite:draw_shader(_shader, _shadow_height, _send, _no_tilt, other_obj, ms, mr, mx, my, custom_shader, tilt_shadow, check)
    if (check) then
        if G.SETTINGS.reduced_motion then _no_tilt = true end
        local _draw_major = self.role.draw_major or self
        if _shadow_height then 
            self.VT.y = self.VT.y - _draw_major.shadow_parrallax.y*_shadow_height
            self.VT.x = self.VT.x - _draw_major.shadow_parrallax.x*_shadow_height
            self.VT.scale = self.VT.scale*(1-0.2*_shadow_height)
        end

        if custom_shader then 
            if _send then 
                for k, v in ipairs(_send) do
                    G.SHADERS[_shader]:send(v.name, v.val or (v.func and v.func()) or v.ref_table[v.ref_value])
                end
            end
        elseif _shader == 'vortex' then 
            G.SHADERS['vortex']:send('vortex_amt', G.TIMERS.REAL - (G.vortex_time or 0))
        else
            self.ARGS.prep_shader = self.ARGS.prep_shader or {}
            self.ARGS.prep_shader.cursor_pos = self.ARGS.prep_shader.cursor_pos or {}
            self.ARGS.prep_shader.cursor_pos[1] = _draw_major.tilt_var and _draw_major.tilt_var.mx*G.CANV_SCALE or G.CONTROLLER.cursor_position.x*G.CANV_SCALE
            self.ARGS.prep_shader.cursor_pos[2] = _draw_major.tilt_var and _draw_major.tilt_var.my*G.CANV_SCALE or G.CONTROLLER.cursor_position.y*G.CANV_SCALE

            G.SHADERS[_shader or 'dissolve']:send('mouse_screen_pos', self.ARGS.prep_shader.cursor_pos)
            G.SHADERS[_shader or 'dissolve']:send('screen_scale', G.TILESCALE*G.TILESIZE*(_draw_major.mouse_damping or 1)*G.CANV_SCALE)
            G.SHADERS[_shader or 'dissolve']:send('hovering',((_shadow_height  and not tilt_shadow) or _no_tilt) and 0 or (_draw_major.hover_tilt or 0)*(tilt_shadow or 1))
            G.SHADERS[_shader or 'dissolve']:send("dissolve",math.abs(_draw_major.dissolve or 0))
            G.SHADERS[_shader or 'dissolve']:send("time",123.33412*(_draw_major.ID/1.14212 or 12.5123152)%3000)
            G.SHADERS[_shader or 'dissolve']:send("texture_details",self:get_pos_pixel())
            G.SHADERS[_shader or 'dissolve']:send("image_details",self:get_image_dims())
            G.SHADERS[_shader or 'dissolve']:send("burn_colour_1",_draw_major.dissolve_colours and _draw_major.dissolve_colours[1] or G.C.CLEAR)
            G.SHADERS[_shader or 'dissolve']:send("burn_colour_2",_draw_major.dissolve_colours and _draw_major.dissolve_colours[2] or G.C.CLEAR)
            G.SHADERS[_shader or 'dissolve']:send("shadow",(not not _shadow_height))
            if _send then G.SHADERS[_shader or 'dissolve']:send(_shader,_send) end
        end

        love.graphics.setShader( G.SHADERS[_shader or 'dissolve'],  G.SHADERS[_shader or 'dissolve'])

        if other_obj then 
            self:draw_from(other_obj, ms, mr, mx, my, check)
        else 
            self:draw_self()
        end

        love.graphics.setShader()

        if _shadow_height then 
            self.VT.y = self.VT.y + _draw_major.shadow_parrallax.y*_shadow_height
            self.VT.x = self.VT.x + _draw_major.shadow_parrallax.x*_shadow_height
            self.VT.scale = self.VT.scale/(1-0.2*_shadow_height)
        end
    else
        draw_shader_ref(self, _shader, _shadow_height, _send, _no_tilt, other_obj, ms, mr, mx, my, custom_shader, tilt_shadow)
    end
end

local draw_from_ref = Sprite.draw_from
function Sprite:draw_from(other_obj, ms, mr, mx, my, check)
    if (check) then
        self.ARGS.draw_from_offset = self.ARGS.draw_from_offset or {}
        self.ARGS.draw_from_offset.x = mx or 0
        self.ARGS.draw_from_offset.y = my or 0
        prep_draw(other_obj, (1 + (ms or 0)), (mr or 0), self.ARGS.draw_from_offset, false, check)
        love.graphics.scale(1/(other_obj.scale_mag or other_obj.VT.scale))
        love.graphics.setColor(G.BRUTE_OVERLAY or G.C.WHITE)
        love.graphics.draw(
            self.atlas.image,
            self.sprite,
            -(other_obj.T.w/2 -other_obj.VT.w/2)*10,
            0,
            0,
            other_obj.VT.w/(other_obj.T.w),
            other_obj.VT.h/(other_obj.T.h)
        )
        self:draw_boundingrect()
        love.graphics.pop()
    else
        draw_from_ref(self, other_obj, ms, mr, mx, my)
    end
end