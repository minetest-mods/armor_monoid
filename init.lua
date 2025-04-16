
armor_monoid = {}

local armor_groups = {
	fleshy = 100,
	fall_damage_add_percent = 100,
	immortal = 1,
}

armor_monoid.registered_groups = armor_groups

local join_handled = {}

local function copy_tab(tab)
	local copy = {}

	for k, v in pairs(tab) do
		copy[k] = v
	end

	return copy
end


-- The values in this monoid are not armor group values, but damage multipliers.
-- For example { fleshy = 0.5, fire = 1.2 } would mean that a player takes
-- half fleshy damage and 120% fire damage. Nil values are the same as putting
-- 1. The final multipliers are multiplied to the base damage for the group.
armor_monoid.monoid = player_monoids.make_monoid({
	combine = function(tab1, tab2)
		local res = {}
		
		for k, v in pairs(armor_groups) do
			local v1 = tab1[k]
			local v2 = tab2[k]
			
			if not v1 then
				res[k] = v2
			elseif not v2 then
				res[k] = v1
			else
				res[k] = v1 * v2
			end
		end

		return res
	end,
	fold = function(elems)
		local res = {}

		for k, tab in pairs(elems) do
			for k, v in pairs(armor_groups) do
				local vres = res[k]
				local v_other = tab[k]

				if not vres then
					res[k] = v_other
				elseif v_other then
					res[k] = vres * v_other
				end

				-- If not v_other, res[k] remains the same.
			end
		end

		return res
	end,
	identity = {},
	apply = function(multipliers, player)
		local final = copy_tab(armor_groups)

		for k, v in pairs(multipliers) do
			if final[k] then -- Make sure it is a registered armor group
				final[k] = final[k] * v
			end
		end

		-- fall_damage_add_percent is a special armor group that has an inherent
		-- value of 0 rather than 100, so its final value is offset by -100 here
		final.fall_damage_add_percent = final.fall_damage_add_percent - 100

		-- immortal is a special armor group that must be either 0 or 1 to indicate
		-- mortality or immortality, respectively, so its final value is constrained
		-- here
		final.immortal = final.immortal > 1 and 1 or 0

		join_handled[player:get_player_name()] = true

		player:set_armor_groups(final)
	end,
})


-- If the monoid has not fired yet (or won't fire)
minetest.register_on_joinplayer(function(player)
	if not join_handled[player:get_player_name()] then
		player:set_armor_groups(armor_groups)
	end
end)


minetest.register_on_leaveplayer(function(player)
		join_handled[player:get_player_name()] = nil
end)


-- armor_monoid.register_armor_group("name", x) creates an armor group called name
-- with a default armor value of x.
function armor_monoid.register_armor_group(name, def)
	armor_groups[name] = def
end
