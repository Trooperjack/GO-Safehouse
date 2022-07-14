Hooks:PostHook(CarryTweakData, "init", "init__bf", function(self, tweak_data)
	local MUL_LIGHT = "light_multi"
	local MUL_LIGHT_NUM = 18
	
	local MUL_MEDIUM = "medium_multi"
	local MUL_MEDIUM_NUM = 18
	
	local MUL_COKE = "coke_multi"
	local MUL_COKE_NUM = 8
	
	local MUL_HEAVY = "heavy_multi"
	local MUL_HEAVY_NUM = 12
	
	local MUL_WEAPONS_BIG = "wpn_heavy_multi"
	local MUL_WEAPONS_BIG_NUM = 6
	
	
	self:create_multi_type_set(self, MUL_LIGHT, MUL_LIGHT_NUM, 1, "light", "medium", 9)
	self:create_multi_loot_item(self, "diamonds", "jewelry_multi", "jewelry_multi", MUL_LIGHT_NUM, MUL_LIGHT)
	
	self:create_multi_type_set(self, MUL_MEDIUM, MUL_MEDIUM_NUM, 1, "medium", "heavy", 4)
	self:create_multi_loot_item(self, "money", "money_multi", "money_multi", MUL_MEDIUM_NUM, MUL_MEDIUM)
	
	self:create_multi_type_set(self, MUL_COKE, MUL_COKE_NUM, 1, "coke_light", "medium", 4)
	self:create_multi_loot_item(self, "coke", "cocaine_multi", "cocaine_multi", MUL_COKE_NUM, MUL_COKE)
	
	self:create_multi_type_set(self, MUL_HEAVY, MUL_HEAVY_NUM, 1, "slightly_heavy", "very_heavy", 2)
	self:create_multi_loot_item(self, "gold", "gold_multi", "gold_multi", MUL_HEAVY_NUM, MUL_HEAVY)
	
	self:create_multi_type_set(self, MUL_WEAPONS_BIG, MUL_WEAPONS_BIG_NUM, 1, "slightly_heavy", "very_heavy", 2)
	self:create_multi_loot_item(self, "weapons", "weapon_bag_multi", "weapon_bag_multi", MUL_WEAPONS_BIG_NUM, MUL_WEAPONS_BIG)
end)

-- Higher "amount_multi" means heavier bags
function CarryTweakData:create_multi_type_set(self, type_id, amount, amount_multi, from_type, to_type, can_run_limit)
	local BVMUL = amount_multi / amount
	local ft = self.types[from_type]
	local tt = self.types[to_type]
	for i = 1, amount do
		local tbl = {
			can_run = i <= can_run_limit,
			move_speed_modifier = math.lerp(
				ft.move_speed_modifier or 1,
				tt.move_speed_modifier or 0.5,
				BVMUL*i
			),
			jump_modifier = math.lerp(
				ft.jump_modifier or 1,
				tt.jump_modifier or 0.5,
				BVMUL*i
			),
			throw_distance_multiplier = math.lerp(
				ft.throw_distance_multiplier or 0.5,
				tt.throw_distance_multiplier or 0.1,
				BVMUL*i
			)
		}
		
		self.types[type_id.."_"..tostring(i)] = tbl
	end
end


function CarryTweakData:create_multi_loot_item(self, based_on, carry_id, carry_group_id, amount, type)
	for i = 1, amount do
		local tbl = based_on and deep_clone(self[based_on]) or {}
		local id_idx = carry_id.."_"..tostring(i)
		
		if not tbl.name_id then
			tbl["name_id"] = "hud_carry_"..carry_id
		end
		
		tbl["multi_id"] = carry_group_id or carry_id
		tbl["multi_value"] = i
		tbl["multi_max"] = amount
		tbl["type"] = type.."_"..tostring(i)
		tbl["bag_value"] = id_idx
		
		self[id_idx] = tbl
	end
end