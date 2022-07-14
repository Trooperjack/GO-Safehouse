
-- Alternative function specifically for un-dropped loot
function PlayerManager:set_new_carry(old_carry_id, next_carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	local carry_data = tweak_data.carry[next_carry_id]
	local carry_type = carry_data.type

	local title = managers.localization:text("hud_carrying_announcement_title")
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local text = managers.localization:text("hud_carrying_announcement", {
		CARRY_TYPE = type_text
	})
	local icon = nil

	if not dye_initiated then
		dye_initiated = true

		if carry_data.dye then
			local chance = tweak_data.carry.dye.chance * managers.player:upgrade_value("player", "dye_pack_chance_multiplier", 1)

			if false then
				has_dye_pack = true
				dye_value_multiplier = math.round(tweak_data.carry.dye.value_multiplier * managers.player:upgrade_value("player", "dye_pack_cash_loss_multiplier", 1))
			end
		end
	end

	self:update_synced_carry_to_peers(next_carry_id, carry_multiplier or 1, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, next_carry_id, managers.loot:get_real_value(next_carry_id, carry_multiplier or 1))
	
	managers.hud:temp_show_new_carry_bag(next_carry_id, old_carry_id, managers.loot:get_real_value(next_carry_id, carry_multiplier or 1))

	local player = self:player_unit()

	if not player then
		return
	end

	player:movement():current_state():set_tweak_data(carry_type)
	player:sound():play("Play_bag_generic_pickup", nil, false)
end


-- verify_bag(carry_id, pickup)
function PlayerManager:unregister_carry(peer, carry_id)
	if Network:is_client() or not managers.network:session() then
		return true
	end

	if not peer then
		return false
	end

	return peer:verify_bag(carry_id, false)
end

-- LOG
function PlayerManager:log_peer_carry()
	log("PlayerManager:log_peer_carry()")
	log("------------------------------")
	for i,v in ipairs(self._global.synced_carry) do
		log("...")
		log("Peer "..tostring(i))
		_G.PrintTable(v)
	end
	log("------------------------------")
end