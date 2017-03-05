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