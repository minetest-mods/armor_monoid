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

The `fall_damage_add_percent` armor group controls how much additional damage
that a player will incur when falling from a high height. The armor monoid
handles this group exactly like normal armor groups that have a base value of
100.

The armor monoid uses the following range of values for the
`fall_damage_add_percent` armor group:

- `value = 100`: player takes normal fall damage (100%)
- `value = 0`: player takes no fall damage (0%)
- `value = X`: player takes X% less fall damage (1%-99%)
- default value: 100

To grant a player fall damage reduction, use the `fall_damage_add_percent` group
as you would any normal armor group:

```lua
armor_monoid.monoid:add_change(player,{fall_damage_add_percent=0.5},"mymod:half_fall_damage")
```

`immortal`
----------

The `immortal` armor group controls whether or not a player can suffer damage
and experience drowning. Due to limitations of this monoid, the values of this
armor group are handled differently than most armor groups.

The armor monoid uses the following values for the `immortal` armor group:

- `value <= 1`: player is not immortal, subject to damage and drowning
- `value > 1`: player is immortal, will not suffer damage and cannot drown
- default value: 1

To grant a player immortality, set this group to a value greater than 1 like so:

```lua
armor_monoid.monoid:add_change(player,{immortal=2},"mymod:immortality")
```