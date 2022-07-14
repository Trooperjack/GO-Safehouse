Hooks:PostHook(InteractionTweakData, "init", "init__bf", function(self, tweak_data)

-- Log sound stuff
--[[
	local ALREADY_LOGGED = {}
	for i,v in pairs(self) do
		if type(v) == "table" then
			if v.sound_start and not ALREADY_LOGGED[v.sound_start] then
				log("SOUND START: " .. i .. ": " .. v.sound_start)
				ALREADY_LOGGED[v.sound_start] = true
			end
			if v.sound_interupt and not ALREADY_LOGGED[v.sound_interupt] then
				log("SOUND INTRR: " .. i .. ": " .. v.sound_interupt)
				ALREADY_LOGGED[v.sound_interupt] = true
			end
			if v.sound_done and not ALREADY_LOGGED[v.sound_done] then
				log("SOUND  DONE: " .. i .. ": " .. v.sound_done)
				ALREADY_LOGGED[v.sound_done] = true
			end
		end
	end
]]--

	local MULTI_TIMER_BAG = 2.0
	local MULTI_TIMER_FILL = 1.25
	local MULTI_TIMER_FILL_SHORT = 0.75
	
	-- fill
	self.bag_multi_fill = {
		text_id = "bag_multi_fill",
		timer = MULTI_TIMER_FILL,
		start_active = true,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.bag_multi_fill_quick = deep_clone(self.bag_multi_fill)
	self.bag_multi_fill_quick.timer = MULTI_TIMER_FILL_SHORT
	
	-- money
	self.money_bag_multi = {
		text_id = "bag_multi_fill",
		timer = MULTI_TIMER_BAG,
		start_active = true,
		sound_start = "bar_bag_pour_money",
		sound_interupt = "bar_bag_pour_money_cancel",
		sound_done = "bar_bag_pour_money_finished" 
	}
	self.money_bag_multi_dynamic = deep_clone(self.money_bag_multi)
	self.money_bag_multi_dynamic.force_update_position = true
	
	-- gold
	self.gold_bag_multi = {
		text_id = "gold_bag_multi",
		timer = MULTI_TIMER_BAG,
		start_active = true,
		sound_start = "bar_bag_armor",
		sound_interupt = "bar_bag_armor_cancel",
		sound_done = "bar_bag_armor_finished" 
	}
	self.gold_bag_multi_dynamic = deep_clone(self.gold_bag_multi)
	self.gold_bag_multi_dynamic.force_update_position = true
	
	-- coke
	self.coke_bag_multi = {
		text_id = "coke_bag_multi",
		timer = MULTI_TIMER_BAG,
		start_active = true,
		sound_start = "bar_bag_money",
		sound_interupt = "bar_bag_money_cancel",
		sound_done = "bar_bag_money_finished"
	}
	self.coke_bag_multi_dynamic = deep_clone(self.coke_bag_multi)
	self.coke_bag_multi_dynamic.force_update_position = true
	
	-- jewel
	self.jewelry_multi = {
		text_id = "jewelry_multi",
		timer = MULTI_TIMER_BAG,
		start_active = true,
		sound_start = "bar_bag_jewelry",
		sound_interupt = "bar_bag_jewelry_cancel",
		sound_done = "bar_bag_jewelry_finished"
	}
	self.jewelry_multi_dynamic = deep_clone(self.jewelry_multi)
	self.jewelry_multi_dynamic.force_update_position = true
	
	-- weapons
	self.weapon_bag_multi = {
		text_id = "weapon_bag_multi",
		timer = MULTI_TIMER_BAG,
		start_active = true,
		sound_start = "bar_bag_armor",
		sound_interupt = "bar_bag_armor_cancel",
		sound_done = "bar_bag_armor_finished" 
	}
	self.weapon_bag_multi_dynamic = deep_clone(self.weapon_bag_multi)
	self.weapon_bag_multi_dynamic.force_update_position = true

end)