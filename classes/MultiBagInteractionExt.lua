MultiBagInteractionExt = MultiBagInteractionExt or class(CarryInteractionExt)

-- To BaseInt
-- [ClassName].super.super.[method](self, ...)

-- To UseInt
-- [ClassName].super.[method](self, ...)

-- Returns that go through Classes need to have an extra super since were based on CarryInt and not UseInt.

function MultiBagInteractionExt:init(unit)
	MultiBagInteractionExt.super.super.init(self, unit)
	self:set_tweak_data_fill(self.tweak_data_fill)
	self._count_int = self._unit:interaction()._object_type == "state" and 1 or 0
	
	
	-- _object_type "single" setup.
	if self._object_graphics_prefix then
		local g_objs = string.split(self._object_graphics_prefix, ";")
		for i,obj in ipairs(g_objs) do
			if self._unit:interaction()._object_type == "single" then
				local idstr = Idstring(obj..tostring(math.random(1,self._random_objects)))
				local u_obj = self._unit:get_object(idstr)
				if u_obj then
					u_obj:set_visibility(true)
				else
					log("missing single object " .. obj .. tostring(self._count_int) .. " -- " .. tostring(idstr))
				end
			end
		end
	end
end


--
function MultiBagInteractionExt:set_tweak_data_fill(id)
	if id then
		self._tweak_data_fill = tweak_data.interaction[id] or tweak_data.interaction.bag_multi_fill
	else
		self._tweak_data_fill = tweak_data.interaction.bag_multi_fill
	end
end


--
function MultiBagInteractionExt:get_text_id(player, locator)
	local text
	
	if locator ~= nil then
		log("Has Locator: "..tostring(locator))
	end
	
	if self:can_take_carry() then
		text = managers.player:is_carrying() and self._tweak_data_fill.text_id or self._tweak_data.text_id
	else
		text = self._tweak_data.text_id .. "_blocked"
	end
	
	return text or alive(self._unit) and self._unit:base().interaction_text_id and self._unit:base():interaction_text_id(player, locator)
end


-- Interaction Timer (Filling should be faster)
function MultiBagInteractionExt:_get_modified_timer()
	local skill_multi = managers.player:has_category_upgrade("carry", "interact_speed_multiplier")
					and managers.player:upgrade_value("carry", "interact_speed_multiplier", 1)
					or 1
	
	-- skill timers suck, this will probs go away
	skill_multi = 1
	
	if self:is_multi_id_identical() then
		if self._tweak_data_fill then
			return self._tweak_data_fill.timer * skill_multi
		else
			log("MultiBagInteractionExt: FILL TWEAKDATA NOT SET!")
			return self._tweak_data.timer * skill_multi
		end
	else
		return self._tweak_data.timer * skill_multi
	end

	return nil
end


-- 
function MultiBagInteractionExt:_interact_blocked(player)
	local silent_block = managers.player:carry_blocked_by_cooldown() or self._unit:carry_data():is_attached_to_zipline_unit()
	log("MultiBagInteractionExt:_interact_blocked: silent_block "..tostring(silent_block)..", can take "..tostring(self:can_take_carry()))
	if not self:can_take_carry() or silent_block then
		return true, false, "carry_block"
	end

	return not managers.player:can_carry(self._unit:carry_data():carry_id())
end


-- 
function MultiBagInteractionExt:can_select(player)
	if managers.player:carry_blocked_by_cooldown() or self._unit:carry_data():is_attached_to_zipline_unit() then
		return false
	end

	return MultiBagInteractionExt.super.super.can_select(self, player)
end


-- 
function MultiBagInteractionExt:selected(player, locator)
	if locator == nil then
		log("LOCATOR IS NIL")
	else
		log(tostring(locator))
	end
	
	log("selected")

	return MultiBagInteractionExt.super.super.selected(self, player)
end


-- Interact Start Sequence
function MultiBagInteractionExt:interact_start(player, data)
	if self._unit:damage() and self:can_take_carry() then
		self._unit:damage():run_sequence_simple("interact_start", {
			unit = player
		})
	end
	
	return MultiBagInteractionExt.super.super.interact_start(self, player, data)
end

-- Interact Interrupt Sequence
function MultiBagInteractionExt:interact_interupt(player, complete)
	MultiBagInteractionExt.super.super.super.interact_interupt(self, player, complete)
	if self._unit:damage() then
		self._unit:damage():run_sequence_simple("interact_interupt", {
			unit = player
		})
	end
end

-- Interact, give bag
function MultiBagInteractionExt:interact(player)
	local local_peer = managers.network:session():local_peer()
	local peer_id = local_peer:id()
	
	log("\n\n--- INTERACT ---")
	
	local unregister_carry_id
	local register_carry_id
	
	if managers.player:is_carrying() then
		-- log("// Modifying Carry")
		local carry_td = tweak_data.carry
		local current_carry_id = managers.player:current_carry_id()
		
		local mul_cur = carry_td[current_carry_id].multi_value
		local mul_max = carry_td[current_carry_id].multi_max
		
		-- Not the safest naming system but works so long as you dont name something money_type1_multi_1
		local next_carry_id = string.gsub(current_carry_id, tostring(mul_cur), tostring(mul_cur+1))
		
		managers.player:set_new_carry(current_carry_id, next_carry_id, self._unit:carry_data():multiplier(), self._unit:carry_data():dye_pack_data())
		
		register_carry_id = next_carry_id
		unregister_carry_id = current_carry_id
	
		if self._tweak_data_fill.sound_done then
			player:sound():play(self._tweak_data_fill.sound_done)
		end
	else
		-- log("// Single Carry")
		managers.player:set_carry(self._unit:carry_data():carry_id(), self._unit:carry_data():multiplier(), self._unit:carry_data():dye_pack_data())
		register_carry_id = self._unit:carry_data():carry_id()
		
		-- Temp fix for always enabled interactions having wrong interaction update
		local string_macros = {}
		self:_add_string_macros(string_macros)
		local text_id = self:get_text_id(player, nil)
		local text = managers.localization:text(text_id, string_macros)
		local icon = self._tweak_data.icon
		managers.hud:show_interact({
			text = text,
			icon = icon
		})
		
		
	end

	-- send to clients
	managers.network:session():send_to_peers_synched_except(peer_id, "sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
	log(">> 'sync_interacted' to peers only")
	self:sync_interacted(nil, player)
	log(">> 'sync_interacted' on player only")
	
	log("\n --- LOCAL REGISTRATION --- \n".. register_carry_id)
	if unregister_carry_id then
		local _reg = managers.player:unregister_carry(local_peer, unregister_carry_id)
		log("\t> un-registered "..unregister_carry_id.." ".. tostring(_reg))
	end
	
	local _reg = managers.player:register_carry(local_peer, register_carry_id)
	log("\t>    registered "..register_carry_id.." ".. tostring(_reg))
	
	if not self.keep_active_after_interaction then
		self:set_active(false)
	end

	if Network:is_client() then
		player:movement():set_carry_restriction(true)
	end

	managers.mission:call_global_event("on_picked_up_carry", self._unit)
	
	return true
end


-- client and do-er, do-er is peer nil
function MultiBagInteractionExt:sync_interacted(peer, player, status)
	log("MultiBagInteractionExt:sync_interacted:\n peer "..tostring(peer).."\n player "..tostring(player).."\n status "..tostring(status))
	
	local no_player = player == nil
	player = player or peer:unit()
	
	-- Counting interactions
	self._count_int = self._count_int and self._count_int + 1 or 1
	
	-- Get a list of prefixes. Eg, "g_thing_;g_box_" will list them in an array so combining objects into single meshes isnt needed.
	local g_objs = self._object_graphics_prefix and string.split(self._object_graphics_prefix, ";")
	local dm_objs = self._object_decal_prefix and string.split(self._object_decal_prefix, ";")
	
	-- ITEM:  Disables individual objects.
	-- STATE: Disables previous state objects, enables next.
	if self._unit:interaction()._object_type == "item" then
		log("item g objs")
		if g_objs then
			for i, obj in ipairs(g_objs) do
				local idstr = Idstring(obj..tostring(self._count_int))
				local u_obj = self._unit:get_object(idstr)
				if u_obj then
					u_obj:set_visibility(false)
				else
					log("missing graphic " .. obj .. tostring(self._count_int) .. " -- " .. tostring(idstr))
				end
			end
		end
		
		log("item dm objs")
		if dm_objs then
			for i, obj in ipairs(dm_objs) do
				local idstr = Idstring(obj..tostring(self._count_int))
				local u_obj = self._unit:get_object(idstr)
				if u_obj then
					self._unit:set_mesh_enabled(u_obj, false)
				else
					log("missing decal " .. obj .. tostring(self._count_int) .. " -- " .. tostring(idstr))
				end
			end
		end
	elseif self._unit:interaction()._object_type == "state" then
		log("state g objs")
		if g_objs then
			for i, obj in ipairs(g_objs) do
				local idstr_old = Idstring(obj..tostring(self._count_int-1))
				local u_obj_old = self._unit:get_object(idstr_old)
				if u_obj_old then
					u_obj_old:set_visibility(false)
				else
					log("missing old graphic " .. obj .. tostring(self._count_int) .. " -- " .. tostring(idstr_old))
				end
				--
				local idstr_new = Idstring(obj..tostring(self._count_int))
				local u_obj_new = self._unit:get_object(idstr_new)
				if u_obj_new then
					u_obj_new:set_visibility(true)
				else
					log("missing new graphic " .. obj .. tostring(self._count_int) .. " -- " .. tostring(u_obj_new))
				end
			end
		end
		
		log("state dm objs")
		if dm_objs then
			for i, obj in ipairs(dm_objs) do
				local idstr_old = Idstring(obj..tostring(self._count_int-1))
				local u_obj_old = self._unit:get_object(idstr_old)
				if idstr_old then
					self._unit:set_mesh_enabled(idstr_old, false)
				else
					log("missing old decal " .. obj .. tostring(self._count_int) .. " -- " .. tostring(idstr_old))
				end
				--
				local idstr_new = Idstring(obj..tostring(self._count_int))
				local u_obj_new = self._unit:get_object(idstr_new)
				if u_obj_new then
					self._unit:set_mesh_enabled(u_obj_new, true)
				else
					log("missing new decal " .. obj .. tostring(self._count_int) .. " -- " .. tostring(u_obj_new))
				end
			end
		end
	end
	
	-- EVERYTHING ABOVE HERE IS THE CLIENT ONLY
	-- EVERYTHING ABOVE HERE IS THE CLIENT ONLY
	-- EVERYTHING ABOVE HERE IS THE CLIENT ONLY
	
	log("\n --- PEER REGISTRATION --- ")
	if peer then
		local peer_carry_id
		local peer_synced_carry = managers.player:get_synced_carry(peer:id())
		local peer_synced_carry_id = peer_synced_carry.carry_id
		
		if peer_synced_carry_id then -- already has bag
			log("\tCURR CARRY: "..tostring(peer_synced_carry_id))
			
			local _splits = string.split(peer_synced_carry_id, "_")
			local _pre_num = tonumber(_splits[#_splits]) - 1
			if _pre_num > 0 then
				local peer_prev_carry_id_from_plrman = string.gsub(peer_synced_carry_id, tostring(_splits[#_splits]), tostring(_pre_num)) -- Yikes
				
				log("\tPREV CARRY: "..tostring(peer_prev_carry_id_from_plrman))
				local _reg = managers.player:unregister_carry(peer, peer_prev_carry_id_from_plrman)
				log("\tUNREG CARRY SUCCESSFUL?: "..tostring(_reg))
			end
			
			peer_carry_id = peer_synced_carry_id
		
		else -- in this case the peer will always be picking up a first bag
			log("\tpeer no carry table")
			peer_carry_id = self._unit:carry_data() and self._unit:carry_data():carry_id()
		end
	
		log("pre-register check is peer...")
		if not managers.player:register_carry(peer, peer_carry_id) then -- Registering carry here is required or clients get kicked when throwing
			log("register check peer not true")
			-- This always returns due to carry ID mismatch from stacking
			return
		end
	end
	
	-- EVERYTHING BELOW HERE IS THE PLAYER ONLY
	-- EVERYTHING BELOW HERE IS THE PLAYER ONLY
	-- EVERYTHING BELOW HERE IS THE PLAYER ONLY
	
	-- sequences
	if self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact", {
			unit = player
		})
	end

	if self._unit:damage():has_sequence("load") then
		self._unit:damage():run_sequence_simple("load", {
			unit = player
		})
	end
	
	-- global event
	if self._global_event then
		managers.mission:call_global_event(self._global_event, player)
	end

	
	-- server sided
	if Network:is_server() then
		if self._remove_on_interact then
			if self._unit == managers.interaction:active_unit() then
				self:interact_interupt(managers.player:player_unit(), false)
			end

			self:remove_interact()
			self:set_active(false, true)

			if alive(player) then
				self._unit:carry_data():trigger_load(player)
			end

			self._unit:set_slot(0)
		end

		if peer then
			log("sync peer carry approved: "..tostring(peer))
			managers.player:set_carry_approved(peer)
			managers.player:log_peer_carry()
		end
	end
	
	if no_player then
		managers.mission:call_global_event("on_picked_up_carry", self._unit)
	end
end


-- custom
function MultiBagInteractionExt:is_multi_carry(carry_id)
	return tweak_data.carry[carry_id].multi_id and true or false
end


-- custom
function MultiBagInteractionExt:can_take_carry()
	local player_carry_id = managers.player:current_carry_id()
	
		
	if managers.player:is_carrying() then
		
		if self:is_multi_id_identical() then
			local carry_td = tweak_data.carry
			local carry_id = self._unit:carry_data():carry_id()
			local mul_cur = carry_td[player_carry_id].multi_value
			local mul_max = carry_td[carry_id].multi_max
			
			return mul_cur < mul_max -- withing carry limit
		end
		return false -- has bag, wrong multi_group
	else
		return true -- no bag at all, just pick it up
	end
end


-- custom
function MultiBagInteractionExt:is_multi_id_identical()
	local ctd = tweak_data.carry

	local players_carry = managers.player:current_carry_id()
	
	local self_carry = self._unit:carry_data():carry_id()
	
	if not players_carry or not self_carry then
		return false
	end
	
	return ctd[players_carry].multi_id == ctd[self_carry].multi_id
end

-- Toggle locators. Something to play with later!
function MultiBagInteractionExt:use_locators()
	return self._unit:interaction()._use_locators == true
end

