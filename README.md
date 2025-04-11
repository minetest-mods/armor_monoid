#The Armor Monoid

This mod provides a player_monoids monoid for handling armor groups. It
provides a monoid for damage resistance, and a way to register new damage types
for players.

Using the monoid
================
The values in the monoid are tables mapping armor group names to damage
multipliers. For example, if I wanted to apply an effect granting arcane
damage resistance but fleshy damage vulnerability, I could do <br/>
```
local tab = {
  arcane = 0.5,
  fleshy = 1.5,
}

armor_monoid.monoid:add_change(player, tab, "mymod:arcane_boost")
```

Registering damage types
========================
To add a new damage type to players, use armor_monoid.register_armor_group. For
example: <br/>
```
armor_monoid.register_armor_group("arcane", 100)
```
<br/>
As you can see, the argument is not a multiplier, but the base armor group
rating. Calling this would mean players start off with an armor rating in
"arcane" of 100 (no protection).

Special armor groups
====================

Luanti defines a number of [special armor groups](https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md#objectref-armor-groups)
that have an engine-based effect and therefore must be handled uniquely by this
monoid.

`fall_damage_add_percent`
-------------------------

The armor monoid handles this group exactly like normal armor groups that have a
base value of 100, but because its value is multiplicative with built-in fall
damage, its final value is internally offset by -100 to respect this behavior.

To grant a player fall damage reduction, use the `fall_damage_add_percent` group
as you would any normal damage group:

```lua
armor_monoid.monoid:add_change(player,{fall_damage_add_percent=0.5},"mymod:half_fall_damage")
```

`immortal`
----------

The armor monoid treats any value of 1 or less as an indication that a player
can suffer damage. Conversely, any value greater than 1 will make a player
immune to all damage.

To grant a player immortality, set this group to a value greater than 1 like so:

```lua
armor_monoid.monoid:add_change(player,{immortal=2},"mymod:immortality")
```

Note that this is not in line with the typical use of the `immortal` armor
group which usually has a value of 0 (not immortal) or 1 (immortal) due to the
fact that armor monoid changes are multiplicative, so if the group is set to 0
to revoke immortality, then no other changes can ever influence the armor group.

This is largely a technical detail. If you use this mod to manage armor groups,
then use a value of 1 or less to make a player mortal and a value greater than 1
to make a player immortal. The internal implementation will translate these
values to an actual armor group value of 0 or 1.