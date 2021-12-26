Welcome! If you're reading this, then you probably want to edit my shader pack.
I'm completely cool with this. In fact, to help you get started faster, here's an overview of how stuff works:
If you're on an old version of minecraft and just want to know all the places where you need to change a specific option, you can skip to the options section below.
If on the other hand you want to alter this pack for your own *personal* use, continue reading.

composite.fsh controls rendering for most opaque objects. This includes main light levels, held lights, fog, etc...
It also does some preparations for infinite oceans, which are mostly handled in composite1.fsh.
Speaking of infinite oceans, they're also partially handled in skybasic; as it writes 0% opacity to the gaux1 buffer below the horizon.
This acts as the flag for where composite should fix colors/normal data, so that composite1 has the correct values.
Skybasic also handles most of the sky colors (see calculateSkyColor()). It also handles fancy stars and galaxies.
sunPathRotation is also set there. If you plan on changing this, you'll need to set it in both skybasic.fsh AND vsh.
This is due to a bug in optifine, where sun/moon positions are actually one frame behind where they should be.
I fix this by calculating their positions manually; but to do that, sunPathRotation needs to be the same in the fsh and vsh stages.

A few effects are handled in the gbuffers files, such as:
gbuffers_block handles ender portals
gbuffers_entities handles rainbow XP, circular shadows, and entity coloring (the red tint when an entity take damage)
gbuffers_terrain handles all of the foliage effects, as well as wet dirt, randomized lava brightness, and lava waves (in the nether)
gbuffers_weather handles waving rain

gbuffers_water and hand handle most of the transparent stuff, in the same way that composite handles opaque stuff. This includes lighting/fog/etc...
Both of them write normal data to gnormal, which is used in composite1.fsh for sun/sky reflections.
hand also handles hand sway.

Most of the other fancy effects (like clouds, water refractions, etc...) are handled in composite1.
The only exceptions being ender nebulae/stars and twilight forest auroras, which are handled in world1/composite.fsh and world7/composite.fsh respectively.

Composite2 and final are used for blur effects. 2 programs are needed because I'm using a technique called 2-pass blurring.
First, blur horizontally, then blur vertically. Sounds simple, but is MUCH better on framerate than trying to do both at once.
This is because only doing horizontal blur requires ~(2 * radius) sample points, as does vertical blur.
Therefore, we need ~(4 * radius) sample points total.
If we did it all in one pass, we'd need ~(2 * radius) ^ 2 sample points, which is much larger.

That's all the effects, now for the used buffers:

gcolor: Stores color of opaque objects.
composite: Stores the color of transparent objects, and the opacity of the closest transparent object to the camera.
gnormal: Stores normal vectors of the closest transparent object to the camera (used for refractions and reflections)
gaux1: Red and green store block light and skylight of opaque objects. Blue is always 1.0.
	An opacity of 0.5 flags it as being part of the sky.
	An opacity of 0.0 flags it as being part of the lower half of the sky. (for infinite oceans)
gaux2: Red and green store block light and skylight of the closest transparent object to the camera.
	Used for not doing reflections when underground.
	The blue channel also stores block data, used for block-specific effects like better stained glass, water refractions, ice scattering, etc...
gaux3: Red stores the combined opacity of all transparent objects.

However, after all the composite programs run, these usages change quite drastically.

composite (the program, not the buffer) will first transfer the red channel of gaux3 (combined opacity of all transparent objects) to the alpha channel of gcolor.
	It also updates gnormal and gaux2 data for infinite oceans.
Next, composite1 will store the final color and blur radius in gaux3.
composite2 then applies horizontal blurring to gaux3, and writes the new horizontally blurred color to composite (the buffer, not the program).
Lastly: final will apply vertical blurring to composite, and write the result directly to the screen.

With all this in mind, you should have a fairly decent grasp on where everything is.

The final thing I'd like to point out is that in this download, there's a "shaders" folder, and a "src" folder.
The src folder is what I modify when developing these shaders, and the shaders folder is what my compile script spits out.
The main difference between them is that my compile script automatically collapses all #include's, because the original shaders mod didn't have support for them and I want to maximize compatibility.
It also removes useless code, unused uniforms/constants/methods, etc... and generates this readme file.
As such, if you want to modify my shaders, I'd recommend removing the shaders folder, and renaming the src folder to "shaders" instead.
This is not required, as both folders *should* work identically; but it is recommended since most lib files are used in multiple places.

If you have any other questions about how specific features are implemented, or why I chose the equations I did, you can ask me about it on discord: https://discord.gg/FMghhxk
I'd be happy to help you figure stuff out, and if I like your changes, they might even get implemented officially :)

With all that out of the way, here's all the options you can set, and where to find them: Alphabetized here for convenience.

################################################################################
################################ Config options ################################
################################################################################

Absorption Color (§9blue§r):
	Internal name: WATER_ABSORB_B
	Description: Blue component of the water absorption color
	Default Value: 0.10
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Absorption Color (§agreen§r):
	Internal name: WATER_ABSORB_G
	Description: Green component of the water absorption color
	Default Value: 0.05
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Absorption Color (§cred§r):
	Internal name: WATER_ABSORB_R
	Description: Red component of the water absorption color
	Default Value: 0.20
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

actualSeaLevel (localization missing):
	Description: water source blocks are 8/9'ths of a block tall, so SEA_LEVEL - 1/9.
	Default Value: SEA_LEVEL - 0.1111111111111111
	Recommended values: (no recommended values provided)
	Found in:
		In world0: composite.fsh, composite1.fsh

Ambient End Color (§9blue§r):
	Internal name: AMBIENT_LIGHT_COLOR_END_BLUE
	Description: Blue component of the ambient light color in the end
	Default Value: 0.10
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ambient End Color (§agreen§r):
	Internal name: AMBIENT_LIGHT_COLOR_END_GREEN
	Description: Green component of the ambient light color in the end
	Default Value: 0.10
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ambient End Color (§cred§r):
	Internal name: AMBIENT_LIGHT_COLOR_END_RED
	Description: Red component of the ambient light color in the end
	Default Value: 0.10
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ambient Nether Color (§9blue§r):
	Internal name: AMBIENT_LIGHT_COLOR_NETHER_BLUE
	Description: Blue component of the ambient light color in the nether
	Default Value: 0.05
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ambient Nether Color (§agreen§r):
	Internal name: AMBIENT_LIGHT_COLOR_NETHER_GREEN
	Description: Green component of the ambient light color in the nether
	Default Value: 0.10
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ambient Nether Color (§cred§r):
	Internal name: AMBIENT_LIGHT_COLOR_NETHER_RED
	Description: Red component of the ambient light color in the nether
	Default Value: 0.20
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ambient Occlusion:
	Internal name: GRASS_AO
	Description: Adds ambient occlusion to tallgrass/flowers/etc... Works best with "Remove Y Offset" enabled.
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Average Cloud Density:
	Internal name: CLOUD_DENSITY_AVERAGE
	Description: Average cloud density. Higher value means more clouds
	Default Value: 0.0
	Recommended values: -2.0 ~ 2.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Background:
	Internal name: END_PORTAL_BACKGROUND_END
	Description: 1: Use overworld fog color. 2: Use end background.
	Default Value: 1
	Recommended values: 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Background:
	Internal name: END_PORTAL_BACKGROUND_TF
	Description: 1: Use overworld fog color. 2: Use end background.
	Default Value: 2
	Recommended values: 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Background:
	Internal name: END_PORTAL_BACKGROUND_NETHER
	Description: 1: Use overworld fog color. 2: Use end background.
	Default Value: 2
	Recommended values: 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Background:
	Internal name: END_PORTAL_BACKGROUND_OVERWORLD
	Description: 1: Use overworld fog color. 2: Use end background.
	Default Value: 2
	Recommended values: 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Better Beacon Beams:
	Internal name: FANCY_BEACONS
	Description: Builderb0y's better beacon beams bring big bright beautiful beacon beams to all biomes, bro
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Better Stained Glass:
	Internal name: ALT_GLASS
	Description: Uses alternate blending method for stained glass which looks more like real stained glass
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Blur Samples:
	Internal name: BLUR_QUALITY
	Description: Number of sample points to use for blurring. Higher quality = higher performance impact!
	Default Value: 10
	Recommended values: 5 ~ 25
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Bright Portal Fix:
	Internal name: BRIGHT_PORTAL_FIX
	Description: Enable this if end portals are 16x brighter than they should be
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Bright Water:
	Internal name: BRIGHT_WATER
	Description: Overrides light levels under water to be higher
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Clear Water:
	Internal name: CLEAR_WATER
	Description: Overwrites water texture to be completely transparent
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Cloud Density Variance:
	Internal name: CLOUD_DENSITY_VARIANCE
	Description: How far above or below the average cloud density will go
	Default Value: 1.5
	Recommended values: 0.0 ~ 2.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Cloud Height:
	Internal name: CLOUD_HEIGHT
	Description: Y level of fancy clouds
	Default Value: 256.0
	Recommended values: 128.0 ~ 512.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Cloud Normals:
	Internal name: CLOUD_NORMALS
	Description: Dynamically light clouds based on weather they're facing towards or away from the sun. Mild performance impact!
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Clouds:
	Internal name: END_PORTAL_CLOUDS_END
	Description: 0: No clouds. 1: Use overworld clouds. 2: Use void clouds.
	Default Value: 1
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Clouds:
	Internal name: CLOUDS
	Description: 3D clouds (partially volumetric too). Mild performance impact!
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Clouds:
	Internal name: END_PORTAL_CLOUDS_OVERWORLD
	Description: 0: No clouds. 1: Use overworld clouds. 2: Use void clouds.
	Default Value: 2
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Clouds:
	Internal name: END_PORTAL_CLOUDS_TF
	Description: 0: No clouds. 1: Use overworld clouds. 2: Use void clouds.
	Default Value: 2
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Clouds:
	Internal name: END_PORTAL_CLOUDS_NETHER
	Description: 0: No clouds. 1: Use overworld clouds. 2: Use void clouds.
	Default Value: 2
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Cubic Chunks:
	Internal name: CUBIC_CHUNKS
	Description: Disables black fog/sky colors below Y=0
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Custom Sky Fix:
	Internal name: CUSTOM_SKY_FIX
	Description: Disables sun fadeout near the horizon when infinite oceans are enabled. Enable this if your resource pack's custom skys turn black near the horizon.
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Density Multiplier:
	Internal name: FOG_DISTANCE_MULTIPLIER_NETHER
	Description: How much overall fog there is in the nether
	Default Value: 1.0
	Recommended values: 0.05 ~ 10.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Depth Of Field:
	Internal name: DOF_STRENGTH
	Description: Blurs things that are at a different distance than whatever's in the center of your screen
	Default Value: 0
	Recommended values: 0 ~ 25
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Desaturation:
	Internal name: DESATURATE
	Description: De-saturates the world at night, during rain, and in the end
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Distance Multiplier:
	Internal name: FOG_DISTANCE_MULTIPLIER_END
	Description: How far away fog starts to appear in the end
	Default Value: 0.25
	Recommended values: 0.05 ~ 10.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Distance Multiplier:
	Internal name: FOG_DISTANCE_MULTIPLIER_OVERWORLD
	Description: How far away fog starts to appear in the overworld.
	Default Value: 0.25
	Recommended values: 0.05 ~ 10.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Distance Multiplier:
	Internal name: FOG_DISTANCE_MULTIPLIER_TF
	Description: How far away fog starts to appear in the twilight forest
	Default Value: 0.25
	Recommended values: 0.05 ~ 10.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Dynamic Lights:
	Internal name: DYNAMIC_LIGHTS
	Description: Holding blocks that emit light will light up their surroundings
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Enable Blur:
	Internal name: BLUR_ENABLED
	Description: Is blur enabled at all?
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Enabled:
	Internal name: END_PORTAL_EFFECTS_TF
	Description: Enables fancy effects for end portals
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Enabled:
	Internal name: END_PORTAL_EFFECTS_NETHER
	Description: Enables fancy effects for end portals
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Enabled:
	Internal name: END_PORTAL_EFFECTS_OVERWORLD
	Description: Enables fancy effects for end portals
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Enabled:
	Internal name: END_PORTAL_EFFECTS_END
	Description: Enables fancy effects for end portals
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

End Fog:
	Internal name: FOG_ENABLED_END
	Description: Enables fog in the end
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ender Nebulae:
	Internal name: ENDER_NEBULAE
	Description: Adds animated nebulae to the background of the end dimension
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ender Plasma:
	Internal name: ENDER_ARCS
	Description: Adds bolts of plasma that arc through the nebulae. Requires ender nebulae to be enabled!
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ender Stars:
	Internal name: ENDER_STARS
	Description: Adds blinking stars to the background of the end dimension. Stackable with nebulae/plasma.
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Eye Adjust:
	Internal name: EYE_ADJUST
	Description: Allows your eyes to "adjust" to darkness
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Fancy Stars:
	Internal name: FANCY_STARS
	Description: Improved stars in the overworld
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Foreground:
	Internal name: END_PORTAL_FOREGROUND_END
	Description: 0: No foreground image. 1: Use overworld screenshot. 2: Use end island screenshot.
	Default Value: 1
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Foreground:
	Internal name: END_PORTAL_FOREGROUND_TF
	Description: 0: No foreground image. 1: Use overworld screenshot. 2: Use end island screenshot.
	Default Value: 2
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Foreground:
	Internal name: END_PORTAL_FOREGROUND_NETHER
	Description: 0: No foreground image. 1: Use overworld screenshot. 2: Use end island screenshot.
	Default Value: 2
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Foreground:
	Internal name: END_PORTAL_FOREGROUND_OVERWORLD
	Description: 0: No foreground image. 1: Use overworld screenshot. 2: Use end island screenshot.
	Default Value: 2
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Galaxies:
	Internal name: GALAXIES
	Description: Galaxies visible at night in the overworld, with even more stars inside them
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Glass Blur:
	Internal name: GLASS_BLUR
	Description: Blurs things behind stained glass
	Default Value: 8
	Recommended values: 0 ~ 25
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Glass Border Opacity:
	Internal name: THRESHOLD_ALPHA
	Description: Anything above this opacity counts as part of the border of stained glass, and will not apply blur/reflection effects
	Default Value: 0.6
	Recommended values: 0.15 ~ 0.95
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

goldenOffset0 (localization missing):
	Description: 2.39996322972865332
	Default Value: vec2( 0.675490294261524, -0.73736887807832 )
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset1 (localization missing):
	Description: 4.79992645945731
	Default Value: vec2(-0.996171040864828,  0.087425724716963)
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset2 (localization missing):
	Description: 7.19988968918596
	Default Value: vec2( 0.793600751291696,  0.608438860978863)
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset3 (localization missing):
	Description: 9.59985291891461
	Default Value: vec2(-0.174181950379306, -0.98471348531543 )
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset4 (localization missing):
	Description: 11.9998161486433
	Default Value: vec2(-0.53672805262632,   0.843755294812399)
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset5 (localization missing):
	Description: 14.3997793783719
	Default Value: vec2( 0.965715074375778, -0.259604304901489)
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset6 (localization missing):
	Description: 16.7997426081006
	Default Value: vec2(-0.887448429245268, -0.460907024713344)
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset7 (localization missing):
	Description: 19.1997058378292
	Default Value: vec2( 0.343038630874082,  0.939321296324125)
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset8 (localization missing):
	Description: 21.5996690675579
	Default Value: vec2( 0.38155640847493,  -0.924345556137807)
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

goldenOffset9 (localization missing):
	Description: 23.9996322972865
	Default Value: vec2(-0.905734272555614, -0.04619144594037 )
	Recommended values: (no recommended values provided)
	Found in:
		In world-1: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world0: composite1.fsh/vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world1: composite.fsh, composite1.fsh, composite1.vsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh
		In world7: composite1.fsh, gbuffers_beaconbeam.fsh, gbuffers_block.fsh

Hand Sway:
	Internal name: IDLE_HANDS
	Description: Makes your hands sway back and forth in 1st person, like they do in 3rd person
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Hardcore Darkness:
	Internal name: HARDCORE_DARKNESS
	Description: 0 (Off): Normal visibility at night. 1 (On): Complete darkness at night. 2 (Moon phase) Nighttime brightness is determined by the current phase of the moon.
	Default Value: 0
	Recommended values: 0 1 2
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Humidity Offset:
	Internal name: HUMIDITY_OFFSET
	Description: Higher number = lusher grass. Lower number = dryer grass
	Default Value: 1.1
	Recommended values: 0.5 ~ 1.25
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ice Blur:
	Internal name: ICE_BLUR
	Description: Blurs things behind ice
	Default Value: 4
	Recommended values: 0 ~ 25
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ice Normals:
	Internal name: ICE_NORMALS
	Description: Distorts things reflected by ice. Has no effect when reflections are disabled!
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Ice Refractions:
	Internal name: ICE_REFRACT
	Description: Distorts things behind ice
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Infinite Oceans:
	Internal name: INFINITE_OCEANS
	Description: Simulates water out to the horizon instead of just your render distance.
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Legacy Sugarcane:
	Internal name: LEGACY_SUGARCANE
	Description: Removes biome coloring from sugar cane
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Lunar Fadeout Radius:
	Internal name: EXCLUSION_RADIUS
	Description: Radius around the moon at which fancy stars/galaxies stop rendering
	Default Value: 1.0
	Recommended values: 0.5 ~ 2.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

MOON_GLOW_COLOR (localization missing):
	Description: Mixed with sky color based on distance from moon
	Default Value: vec3(0.075, 0.1,   0.2 )
	Recommended values: (no recommended values provided)
	Found in:
		In world0: composite.fsh, composite1.fsh, gbuffers_skybasic.fsh, gbuffers_water.fsh

Nether Fog:
	Internal name: FOG_ENABLED_NETHER
	Description: Enables fog in the nether
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Nether Lava Waves:
	Internal name: LAVA_WAVE_STRENGTH
	Description: Adds waves to the nether lava oceans
	Default Value: 100
	Recommended values: 0 ~ 100
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

NIGHT_SKY_COLOR (localization missing):
	Description: Added to sky color at night to avoid it being completely black
	Default Value: vec3(0.02,  0.025, 0.05)
	Recommended values: (no recommended values provided)
	Found in:
		In world0: composite.fsh, composite1.fsh, gbuffers_skybasic.fsh, gbuffers_water.fsh

Old Clouds:
	Internal name: OLD_CLOUDS
	Description: Uses old cloud rendering method from earlier versions, for people who don't like pretty things.
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Overworld Fog:
	Internal name: FOG_ENABLED_OVERWORLD
	Description: Enables fog in the overworld. It is recommended to have this enabled if you also have infinite oceans enabled!
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Rain Blur:
	Internal name: RAIN_BLUR
	Description: Blurs the world while raining
	Default Value: 10
	Recommended values: 0 ~ 25
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Rainbow XP:
	Internal name: RAINBOW_XP
	Description: Makes experience orbs have rainbow colors instead of just the standard yellow/green
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Randomize Humidity:
	Internal name: GRASS_PATCHES
	Description: Makes grass less uniform by making patches of it dryer or lusher. Does not affect leaves.
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Randomize Lava Brightness:
	Internal name: LAVA_PATCHES
	Description: Randomizes lava brightness, similar to grass patches
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Refraction:
	Internal name: WATER_REFRACT
	Description: Distorts things behind water
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Remove X/Z offset:
	Internal name: REMOVE_XZ_OFFSET
	Description: Removes random X/Z offset from tallgrass/flowers/etc...
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Remove Y offset:
	Internal name: REMOVE_Y_OFFSET
	Description: Removes random Y offset from tallgrass/flowers/etc...
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Scattering Color (§9blue§r):
	Internal name: WATER_SCATTER_B
	Description: Blue component of the water fog color
	Default Value: 0.50
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Scattering Color (§agreen§r):
	Internal name: WATER_SCATTER_G
	Description: Green component of the water fog color
	Default Value: 0.40
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Scattering Color (§cred§r):
	Internal name: WATER_SCATTER_R
	Description: Red component of the water fog color
	Default Value: 0.05
	Recommended values: 0.00 ~ 1.00
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Sea Level:
	Internal name: SEA_LEVEL
	Description: Sea level for infinite oceans. Change this if you use custom worldgen.
	Default Value: 63
	Recommended values: 0 ~ 256
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Shade Strength:
	Internal name: SHADE_STRENGTH
	Description: How dark surfaces that are facing away from the sun are
	Default Value: 0.35
	Recommended values: 0.00 ~ 0.50
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Sky Reflections:
	Internal name: REFLECT
	Description: Reflects the sun/sky onto reflective surfaces. Does not add reflections of terrain!
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Sun Path Rotation:
	Internal name: sunPathRotation
	Description: Angle that the sun/moon rotate at
	Default Value: 30.0
	Recommended values: -45.0 ~ 45.0
	Found in:
		In world0: gbuffers_skybasic.fsh/vsh

Sun Position Fix:
	Internal name: SUN_POSITION_FIX
	Description: Enable this if the horizon "splits" at sunset when rapidly rotating your camera.
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

SUN_GLOW_COLOR (localization missing):
	Description: Mixed with sky color based on distance from sun
	Default Value: vec3(1.0,   1.0,   1.0 )
	Recommended values: (no recommended values provided)
	Found in:
		In world0: composite.fsh, composite1.fsh, gbuffers_skybasic.fsh, gbuffers_water.fsh

sunRotationData (localization missing):
	Description: Used for manually calculating the sun's position, since the sunPosition uniform is inaccurate in the skybasic stage.
	Default Value: vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994))
	Recommended values: (no recommended values provided)
	Found in:
		In world0: gbuffers_skybasic.vsh

Sunset color (§9blue§r):
	Internal name: SUNSET_COEFFICIENT_BLUE
	Description: Blue sunset coefficient. Higher values will result in the blue color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time.
	Default Value: 6.2
	Recommended values: 6.0 ~ 8.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Sunset Color (§agreen§r):
	Internal name: SUNSET_COEFFICIENT_GREEN
	Description: Green sunset coefficient. Higher values will result in the green color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time.
	Default Value: 6.7
	Recommended values: 6.0 ~ 8.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Sunset Color (§cred§r):
	Internal name: SUNSET_COEFFICIENT_RED
	Description: Red sunset coefficient. Higher values will result in the red color of sunset starting earlier and persisting longer. A change of 0.1 corresponds to about 5 seconds real-world time.
	Default Value: 7.2
	Recommended values: 6.0 ~ 8.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Twilight Forest Auroras:
	Internal name: TF_AURORAS
	Description: Adds auroras to the sky in the twilight forest
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Twilight Forest Fog:
	Internal name: FOG_ENABLED_TF
	Description: Enables fog in the twilight forest
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Twilight Forest Sky Fix:
	Internal name: TF_SKY_FIX
	Description: Enable this if the sky looks wrong in the twilight forest
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Underwater Blur:
	Internal name: UNDERWATER_BLUR
	Description: Blurs the world while underwater
	Default Value: 8
	Recommended values: 0 ~ 25
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Underwater Fog:
	Internal name: UNDERWATER_FOG
	Description: Applies fog to water
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Vanilla Light Colors:
	Internal name: VANILLA_LIGHTMAP
	Description: Uses vanilla light colors instead of custom ones. Requires optifine 1.12.2 HD_U_D1 or later!
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Vibrant Colors:
	Internal name: CROSS_PROCESS
	Description: Opposite of desaturation, makes everything more vibrant and saturated.
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Vignette:
	Internal name: VIGNETTE
	Description: Reduces the brightness of dynamic light around edges the of your screen
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Void Cloud Height:
	Internal name: VOID_CLOUD_HEIGHT
	Description: Y level of void clouds
	Default Value: 128.0
	Recommended values: -64.0 ~ 512.0
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Void Clouds:
	Internal name: VOID_CLOUDS
	Description: Dark ominous clouds in the end
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Water Blur:
	Internal name: WATER_BLUR
	Description: Blurs things behind water
	Default Value: 4
	Recommended values: 0 ~ 25
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Water Wave Strength:
	Internal name: WATER_WAVE_STRENGTH
	Description: Makes overworld oceans move up and down
	Default Value: 50
	Recommended values: 0 ~ 100
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Wave Normals:
	Internal name: WATER_NORMALS
	Description: Distorts things reflected by water. Has no effect when reflections are disabled!
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Waving Grass:
	Internal name: WAVING_GRASS
	Description: Adds wind effects to grass
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Waving Leaves:
	Internal name: WAVING_LEAVES
	Description: Adds wind effects to leaves
	Default Value: false
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Waving Rain:
	Internal name: WAVING_RAIN
	Description: Makes rain not directly vertical by applying "wind" to it.
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

Wet Dirt:
	Internal name: WET_DIRT
	Description: Hydrated hummus. Soggy soil. Drenched dirt. I can't think of a good name for this config option, but it makes dirt darker during rain to simulate being wet.
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh

§cR§6a§ei§an§bb§9o§5w§ds§r:
	Internal name: RAINBOWS
	Description: If enabled, rainbows will appear when the weather changes from rainy to clear
	Default Value: true
	Recommended values: true false
	Found in:
		In world-1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world0: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_block.vsh, gbuffers_entities.fsh, gbuffers_entities.vsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_skybasic.vsh, gbuffers_skytextured.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh, gbuffers_weather.fsh, gbuffers_weather.vsh
		In world1: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh
		In world7: composite.fsh/vsh, composite1.fsh, composite1.vsh, composite2.fsh, final.fsh, gbuffers_armor_glint.vsh, gbuffers_beaconbeam.fsh, gbuffers_beaconbeam.vsh, gbuffers_block.fsh, gbuffers_entities.fsh, gbuffers_hand.fsh, gbuffers_hand.vsh, gbuffers_skybasic.fsh, gbuffers_terrain.fsh, gbuffers_terrain.vsh, gbuffers_water.fsh, gbuffers_water.vsh