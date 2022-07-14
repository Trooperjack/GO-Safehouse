
HUDTemp.USE_PERCENT = true

-- Swaps the string to the proper new type.
Hooks:PostHook(HUDTemp, "show_carry_bag", "show_carry_bag__bf", function(self, carry_id, value)
	local bag_panel = self._temp_panel:child("bag_panel")
	local carry_data = tweak_data.carry[carry_id]
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local bag_text = bag_panel:child("bag_text")
	
	if bag_text and carry_data.multi_value and carry_data.multi_max then
		local is_at_max = carry_data.multi_value >= carry_data.multi_max
		
		local val = self:get_multi_carry_value_string(carry_id)
		
		-- popup
		type_text = type_text .. " " .. val
		bag_text:set_text(utf8.to_upper(type_text .. " \n " .. managers.experience:cash_string(value)))
		
		-- corner
		local carrying_text = managers.localization:text("hud_carrying")
		self._bg_box:child("bag_text"):set_text(utf8.to_upper(carrying_text .. "\n" .. type_text))
	end
end)



-- custom (ORGANISE CALLBACK VARS... MAYBE)
function HUDTemp:show_new_carry_bag(carry_id, old_carry_id, value)
	local carry_data = tweak_data.carry[carry_id]
	local carry_data_old = tweak_data.carry[old_carry_id]
	
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)

	local my_carry_bag_text = self._bg_box:child("bag_text")
	
	if my_carry_bag_text and carry_data.multi_value and carry_data.multi_max then
		local is_at_max = carry_data.multi_value >= carry_data.multi_max
		
		local carrying_text = managers.localization:text("hud_carrying")
		
		local val_old = self:get_multi_carry_value_percent_int(old_carry_id)
		local val_new = self:get_multi_carry_value_percent_int(carry_id)
		
		my_carry_bag_text:stop()
		my_carry_bag_text:animate(callback(self, self, "_animate_show_new_carry_bag_panel", {val_old, val_new, type_text}))
	end
end

function HUDTemp:_animate_show_new_carry_bag_panel(VARS, new_carry_bag_panel)
	local val_old = VARS[1]
	local val_new = VARS[2]
	local type_text = VARS[3]
	local carrying_text = managers.localization:text("hud_carrying")
	
	-- anim timer
	local TOTAL_T = 0.5
	local t = TOTAL_T
	
	-- animate
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		
		-- flashing (*3 times)
		local alpha = math.round(math.abs(math.sin(t * 360 * 3)))
		new_carry_bag_panel:set_alpha(alpha)
		
		-- fill number
		local val = math.floor(math.lerp(val_old, val_new, 1 - t / TOTAL_T))
		local anim_type_text = type_text .. " " .. tostring(val) .. "%"
		new_carry_bag_panel:set_text(utf8.to_upper(carrying_text .. "\n" .. anim_type_text))
	end
	
	new_carry_bag_panel:set_alpha(1)
	
	type_text = type_text .. " " .. self:get_multi_carry_value_string(carry_id)
	new_carry_bag_panel:set_text(utf8.to_upper(carrying_text .. "\n" .. type_text))
end


-- custom
function HUDTemp:get_multi_carry_value_string(carry_id)
	local val = ""
	
	local carry_data = tweak_data.carry[carry_id]
	
	if carry_data.multi_value and carry_data.multi_max then
		local is_at_max = carry_data.multi_value >= carry_data.multi_max
		
		if HUDTemp.USE_PERCENT then
			val = tostring(math.floor(carry_data.multi_value / carry_data.multi_max * 100)) .. "%"
		else
			local carry_level_max = managers.localization:text("hud_carry_level_max")
			val = is_at_max and carry_level_max or (tostring(carry_data.multi_value) .. "x")
		end
	end
	
	return val
end

function HUDTemp:get_multi_carry_value_percent_int(carry_id)
	local val = 0
	
	local carry_data = tweak_data.carry[carry_id]
	
	if carry_data.multi_value and carry_data.multi_max then
		val = math.floor(carry_data.multi_value / carry_data.multi_max * 100)
	end
	
	return val
end


