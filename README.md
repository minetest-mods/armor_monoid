#The Armor Monoid

This mod provides a monoidal_effects monoid for handling armor groups. It
provides the ```"armor"``` monoid, and a way to register new damage types
for players. It is also compatible with 3d_armor.

Using the monoid
================
The values in the monoid are tables mapping armor group names to damage
multipliers. For example, if I wanted to register an effect granting arcane
damage resistance but fleshy damage vulnerability, I could do <br/>
```
monoidal_effects.register_effect_type("magic_barrier", {
  disp_name = "Magic Barrier",
  tags = { magical = 1 },
  monoids = { armor = true },
  cancel_on_death = true,
  values = { armor = { fleshy = 1.5, arcane = 0.3 } },
  icon = "magic_barrier.png",
})
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