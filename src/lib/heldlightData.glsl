#ifdef DYNAMIC_LIGHTS
	heldLightColor = calcHeldLightColor(float(heldBlockLightValue),  heldItemId);
	heldLightDistModifier = far / sqrt(gbufferProjection[1][1]); //held lights get more powerful when zooming in, akin to holding the light out in front of you and pointing it at something.
#else
	heldLightColor = vec4(0.0);
#endif