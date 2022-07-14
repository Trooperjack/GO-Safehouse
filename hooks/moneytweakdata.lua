Hooks:PostHook(MoneyTweakData, "init", "init__bf", function(self, tweak_data)
	local BVMUL
	
	-- JEWELRY 18
	BVMUL = (3 / 18) * 2
	for i = 1, 18 do
		self.bag_values["jewelry_multi_"..tostring(i)] = self.bag_values.diamonds * BVMUL * i
	end
	
	-- MONEY 18
	BVMUL = (1 / 18) * 2
	for i = 1, 18 do
		self.bag_values["money_multi_"..tostring(i)] = self.bag_values.money * BVMUL * i
	end
	
	-- COKE 8
	BVMUL = (1 / 8) * 2
	for i = 1, 8 do
		self.bag_values["cocaine_multi_"..tostring(i)] = self.bag_values.coke * BVMUL * i
	end
	
	-- GOLD 12
	BVMUL = (1 / 12) * 2
	for i = 1, 12 do
		self.bag_values["gold_multi_"..tostring(i)] = self.bag_values.gold * BVMUL * i
	end
	
	-- GOLD 6
	BVMUL = (1 / 6) * 2
	for i = 1, 6 do
		self.bag_values["weapon_bag_multi_"..tostring(i)] = self.bag_values.weapons * BVMUL * i
	end
end)