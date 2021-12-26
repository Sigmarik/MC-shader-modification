float glmult = 0.0;
if (night < 0.999) glmult += dot( sunPosNorm, normal) * (1.0 - night);
if (night > 0.001) glmult += dot(-sunPosNorm, normal) * night;
glmult = glmult * 0.375 + 0.625; //0.25 - 1.0
glmult = mix(glmult, 1.0, rainStrength * 0.5); //less shading during rain
glmult = mix(1.0, glmult, lmcoord.y * 0.66666666 + 0.33333333); //0.5 - 1.0 in darkness
glmult = mix(glmult, 1.0, lmcoord.x * lmcoord.x); //increase brightness when block light is high
glcolor.rgb *= glmult;