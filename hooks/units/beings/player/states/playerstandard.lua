

-- Not fun to mess with, repeating interactions are for another day maybe.
--[[


function PlayerStandard:_start_action_interact(t, input, timer, interact_object)
	log("PlayerStandard:_start_action_interact()")
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local final_timer = timer
	final_timer = managers.modifiers:modify_value("PlayerStandard:OnStartInteraction", final_timer, interact_object)
	self._interact_expire_t = final_timer
	local start_timer = 0
	self._interact_params = {
		t = t,
		input = input,
		object = interact_object,
		timer = final_timer,
		tweak_data = interact_object:interaction().tweak_data
	}

	self:_play_unequip_animation()
	managers.hud:show_interaction_bar(start_timer, final_timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, final_timer, false)
	self._unit:network():send("sync_interaction_anim", true, self._interact_params.tweak_data)
end

-- Interaction restarts if its restartable
function PlayerStandard:_restart_action_interact(t, input, timer, interact_object)
	log("PlayerStandard:_restart_action_interact()")

	local final_timer = timer
	final_timer = managers.modifiers:modify_value("PlayerStandard:OnStartInteraction", final_timer, interact_object)
	self._interact_expire_t = final_timer
	local start_timer = 0
	self._interact_params = {
		t = t,
		input = input,
		object = interact_object,
		timer = final_timer,
		tweak_data = interact_object:interaction().tweak_data
	}

	managers.hud:show_interaction_bar(start_timer, final_timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, final_timer, false)
	self._unit:network():send("sync_interaction_anim", true, self._interact_params.tweak_data)
end

-- Interaction finishes, interrupt after end
function PlayerStandard:_end_action_interact()
	log("PlayerStandard:_end_action_interact()")
	
	-- Breaks the UI circle stuff, tells the unit its been interacted with?
	self:_interupt_action_interact(nil, nil, true)
	self._interaction:end_action_interact(self._unit)
end

function PlayerStandard:_interupt_action_interact(t, input, complete) -- no t or input on interaction complete
	log("PlayerStandard:_interupt_action_interact()")
	_G.PrintTable(self._interact_params or {})
	if self._interact_expire_t then
		self._interact_expire_t = nil

		if alive(self._interact_params.object) then
			self._interact_params.object:interaction():interact_interupt(self._unit, complete)
		end


		local carry_id = self._interact_params.object:carry_data() and self._interact_params.object:carry_data()._carry_id
		log(tostring(self._interact_params.tweak_data))
		
		local can_restart_interaction = tweak_data.carry[carry_id] and tweak_data.carry[carry_id].multi_id
		
		if complete and can_restart_interaction then
			log("PLAYER STANDARD SHOULD INTERACT AGAIN ON MULTI LOOT")
			self:_restart_action_interact(
					self._interact_params.t + self._interact_params.timer,
					self._interact_params.input,
					self._interact_params.timer,
					self._interact_params.object
			)
			
		else -- behave normally
			self._ext_camera:camera_unit():base():remove_limits()
			self._interaction:interupt_action_interact(self._unit)
			managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, false, self._interact_params.tweak_data, 0, complete and true or false)
		
			self._interact_params = nil
			
			self:_play_equip_animation()
			managers.hud:hide_interaction_bar(complete)
			self._unit:network():send("sync_interaction_anim", false, "")
		end
	end
end
]]--