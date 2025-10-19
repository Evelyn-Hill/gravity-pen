shader_type canvas_item;

group_uniforms Basicos;
uniform float radio: hint_range(0.0, 2.0, 0.001) = 0.1;
uniform float blur: hint_range(-1.0, 1.0, 0.0001) = 0.0001;
uniform vec2 posicion;
uniform mediump float ratio = 1.7066;
uniform vec2 tiling = vec2(0.0, 0.0);

group_uniforms Animaciones.Elipsis;
uniform float radElipsis: hint_range(-1.0, 1.0, 0.001) = 0.0;
uniform mediump float radVelocidad = 1.0;

group_uniforms Animaciones.Size;
uniform mediump float encoger;
uniform mediump float agrandar;

group_uniforms Animaciones.Colores;
uniform mediump float colorRebote;
uniform mediump float colorGolpe;
uniform float radColor: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform int reboteDe: hint_enum("Ninguna", "Rojo", "Verde", "Azul", "Transparencia") = 0;
uniform int desreboteDe: hint_enum("Ninguna", "Rojo", "Verde", "Azul", "Transparencia") = 0;
uniform int golpeDe: hint_enum("Ninguna", "Rojo", "Verde", "Azul", "Transparencia") = 0;
uniform int ColorRadial: hint_enum("Ninguna", "Rojo", "Verde", "Azul") = 0;

group_uniforms Animaciones.ColoresEnFranjas;
uniform float frecuencia = 5.0;
uniform float velocidad_seno = 5.0;
uniform bool colorIntermitente = false;
uniform vec4 color1: source_color = vec4(1.0);
uniform vec4 color2: source_color;
uniform float color_interior: hint_range(0.1, 10.0) = 1.0;

group_uniforms Animaciones.Movimiento;
uniform mediump float velocidadX;
uniform mediump float amplitudX = 0.1;
uniform mediump float velocidadY;
uniform mediump float amplitudY = 0.1;
uniform mediump float Wululu;
uniform mediump float tardanza;
uniform bool Droppeo;

group_uniforms Animaciones.Blur;
uniform mediump float respirar;
uniform mediump float latido;
uniform bool limite;

group_uniforms Estrella;
uniform bool usar_estrella = false;
uniform int cantidad_puntas : hint_range(3, 20) = 5;
uniform float rotacion_estrella = 0.95;
uniform float velocidad_rotacion = 0.0;
uniform float sharpness = 1.0;

//////////////////////////////////////////////////
// === FUNCIONES ===============================
//////////////////////////////////////////////////

float circulo(vec2 uv, float radioVar, float blurreado) {
	float distancia = length(uv);
	float circunferencia = smoothstep(
		radioVar,
		radioVar + clamp(blurreado, limite ? 0.0 : -1.0, 1.0),
		distancia
	);
	return 1.0 - circunferencia;
}

float polarStar(in vec2 p) {
	float pi_n = PI / float(cantidad_puntas);
	float m2 = mod(atan(p.y, p.x) / pi_n + 1.0, 2.0);
	float adjust = -sharpness;
	return length(p) * cos((pi_n * adjust) * (m2 - 4.0 * step(1.0, m2) + 1.0)) - 1.0;
}

//////////////////////////////////////////////////
// === FRAGMENT ================================
//////////////////////////////////////////////////

void fragment() {
	vec2 uv = (UV - 0.5) * (2.0 + tiling);
	uv.x *= ratio;
	vec2 p = posicion / 100.0;

	float ss = encoger == 0.0 ? 1.0 : sin(TIME * encoger);
	float ts = agrandar == 0.0 ? 1.0 : tan(TIME * agrandar);
	float sc = sin(TIME * colorRebote);
	float tc = tan(TIME * colorGolpe);
	float senB = respirar == 0.0 ? 0.0 : sin(TIME * respirar);
	float tanB = latido == 0.0 ? 1.0 : sin(TIME * latido);
	float sp2 = Wululu == 0.0 ? 1.0 : sin(TIME * Wululu);

	float radioAnimado = radio * ss * ts;
	float blurAnimado = (blur + senB) * tanB;

	float angulo = TIME * radVelocidad - tardanza;
	vec2 offset = vec2(cos(angulo), sin(angulo)) * radElipsis;
	vec2 offsetColor = vec2(cos(angulo), sin(angulo)) * radColor;

	vec2 AnimacionPosicion = vec2(
		sin(velocidadX * (TIME - tardanza)) * amplitudX,
		sin(velocidadY * (TIME - tardanza)) * amplitudY
	);
	if (Droppeo) {
		AnimacionPosicion = vec2(
			tan(velocidadX * (TIME - tardanza)) * amplitudX,
			tan(velocidadY * (TIME - tardanza)) * amplitudY
		);
	}

	vec2 base_uv = uv + offset + p + AnimacionPosicion * sp2;

	float rotacion_total = rotacion_estrella + TIME * velocidad_rotacion;
	mat2 rot = mat2(vec2(cos(rotacion_total), -sin(rotacion_total)), vec2(sin(rotacion_total), cos(rotacion_total)));

	float c03;
	if (usar_estrella) {
		vec2 rotated_uv = rot * base_uv / radioAnimado;
		c03 = 1.0 - smoothstep(
			1.0,
			1.0 + clamp(blurAnimado, limite ? 0.0 : -1.0, 1.0),
			abs(polarStar(rotated_uv))
		);
	} else {
		c03 = circulo(base_uv, radioAnimado, blurAnimado);
	}

	vec4 Seno[5] = {
		vec4(0.0),
		vec4(float(sc), 0.0, 0.0, 0.0),
		vec4(0.0, float(sc), 0.0, 0.0),
		vec4(0.0, 0.0, float(sc), 0.0),
		vec4(0.0, 0.0, 0.0, float(sc))
	};

	vec4 Coseno[5] = {
		vec4(0.0),
		vec4(float(-sc), 0.0, 0.0, 0.0),
		vec4(0.0, float(-sc), 0.0, 0.0),
		vec4(0.0, 0.0, float(-sc), 0.0),
		vec4(0.0, 0.0, 0.0, float(-sc))
	};

	vec4 Tangente[5] = {
		vec4(0.0),
		vec4(float(tc), 0.0, 0.0, 0.0),
		vec4(0.0, float(tc), 0.0, 0.0),
		vec4(0.0, 0.0, float(tc), 0.0),
		vec4(0.0, 0.0, 0.0, float(tc))
	};

	vec4 Radial[4] = {
		vec4(0.0),
		vec4(offsetColor, 0.0, 0.0),
		vec4(0.0, offsetColor, 0.0),
		vec4(0.0, 0.0, offsetColor)
	};

	vec3 ColoresLocos = Seno[reboteDe].rgb + Coseno[desreboteDe].rgb + Tangente[golpeDe].rgb + Radial[ColorRadial].rgb;
	float Transparencias = Seno[reboteDe].a + Coseno[desreboteDe].a + Tangente[golpeDe].a;

	// === PATRÓN INTERIOR CON ALFA DE COLOR1 y COLOR2 ===
	vec2 uv_pattern = rot * base_uv / radioAnimado;
	float pattern_value = usar_estrella ? polarStar(uv_pattern) : length(uv_pattern);
	float d = sin(pattern_value * frecuencia + TIME * velocidad_seno) / 10.0;
	d = smoothstep(0.0, 0.0, d);

	float clip = usar_estrella
		? polarStar(uv_pattern * color_interior)
		: length(uv_pattern * color_interior) - 1.0;

	clip = smoothstep(1.0, 1.0, clip);
	d -= clip;

	// 🎯 Aquí se usa color1.a y color2.a
	vec4 white_col = vec4(color1.rgb * d, color1.a * d);
	vec4 black_col = vec4(color2.rgb * (1.0 - (d + clip)), color2.a * (1.0 - (d + clip)));
	vec4 decorativo = colorIntermitente ? (white_col + black_col) : vec4(0.0);

	// === COLOR FINAL ===
	vec4 finalColor = vec4(COLOR.rgb + ColoresLocos, (COLOR.a + Transparencias) * c03);
	if (colorIntermitente) {
		finalColor.rgb = mix(finalColor.rgb, decorativo.rgb, c03);
		finalColor.a = mix(finalColor.a, decorativo.a, c03);
	} else {
		finalColor.a *= c03;
}


	COLOR = finalColor;
}
