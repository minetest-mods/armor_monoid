
armor_monoid = {}

local armor_groups = { fleshy = 100 }

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


if not minetest.global_exists("armor") then return end


-- Armor override
armor.set_player_armor = function(self, player)
	local name, player_inv = armor:get_valid_player(player, "[set_player_armor]")
	if not name then
		return
	end
	local armor_texture = "3d_armor_trans.png"
	local armor_level = 0
	local armor_heal = 0
	local armor_fire = 0
	local armor_water = 0
	local state = 0
	local items = 0
	local elements = {}
	local textures = {}
	local physics_o = {speed=1,gravity=1,jump=1}
	local material = {type=nil, count=1}
	local preview = armor:get_preview(name) or "character_preview.png"
	for _,v in ipairs(self.elements) do
		elements[v] = false
	end
	for i=1, 6 do
		local stack = player_inv:get_stack("armor", i)
		local item = stack:get_name()
		if stack:get_count() == 1 then
			local def = stack:get_definition()
			for k, v in pairs(elements) do
				if v == false then
					local level = def.groups["armor_"..k]
					if level then
						local texture = def.texture or item:gsub("%:", "_")
						table.insert(textures, texture..".png")
						preview = preview.."^"..texture.."_preview.png"
						armor_level = armor_level + level
						state = state + stack:get_wear()
						items = items + 1
						armor_heal = armor_heal + (def.groups["armor_heal"] or 0)
						armor_fire = armor_fire + (def.groups["armor_fire"] or 0)
						armor_water = armor_water + (def.groups["armor_water"] or 0)
						for kk,vv in ipairs(self.physics) do
							local o_value = def.groups["physics_"..vv]
							if o_value then
								physics_o[vv] = physics_o[vv] + o_value
							end
						end
						local mat = string.match(item, "%:.+_(.+)$")
						if material.type then
							if material.type == mat then
								material.count = material.count + 1
							end
						else
							material.type = mat
						end
						elements[k] = true
					end
				end
			end
		end
	end
	if minetest.get_modpath("shields") then
		armor_level = armor_level * 0.9
	end
	if material.type and material.count == #self.elements then
		armor_level = armor_level * 1.1
	end
	armor_level = armor_level * ARMOR_LEVEL_MULTIPLIER
	armor_heal = armor_heal * ARMOR_HEAL_MULTIPLIER
	if #textures > 0 then
		armor_texture = table.concat(textures, "^")
	end
	local armor_groups = {fleshy=100}
	if armor_level > 0 then
		armor_groups.level = math.floor(armor_level / 20)
		armor_groups.fleshy = 100 - armor_level
	end

	armor_monoid.monoid:del_change(player, "armor_monoid:compat")
	player_monoids.speed:del_change(player, "armor_monoid:compat")
	player_monoids.jump:del_change(player, "armor_monoid:compat")
	player_monoids.gravity:del_change(player, "armor_monoid:compat")
	
	armor_monoid.add_change(player, { fleshy = armor_groups.fleshy / 100 },
		"armor_monoid:compat")
	player_monoids.speed:add_change(player, physics_o.speed,
		"armor_monoid:compat")
	player_monoids.jump:add_change(player, physics_o.jump,
		"armor_monoid:compat")
	player_monoids.gravity:add_change(player, physics_o.gravity,
		"armor_monoid:compat")

	self.textures[name].armor = armor_texture
	self.textures[name].preview = preview
	self.def[name].state = state
	self.def[name].count = items
	self.def[name].level = armor_level
	self.def[name].heal = armor_heal
	self.def[name].jump = physics_o.jump
	self.def[name].speed = physics_o.speed
	self.def[name].gravity = physics_o.gravity
	self.def[name].fire = armor_fire
	self.def[name].water = armor_water
	self:update_player_visuals(player)
end
