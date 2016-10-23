/*
	Binoculars by luluco250
*/

#include "ReShade.fxh"
#include "KeyMapper.fxh"

//uniforms///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

uniform float fBinoculars_Zoom <
	ui_label = "Zoom Level [Binoculars]";
	ui_type = "drag";
	ui_min = 1.0;
	ui_max = 10.0;
	ui_step = 0.1;
> = 1.0;

uniform float fBinoculars_ZoomSpeed <
	ui_label = "Zoom Speed [Binoculars]";
	ui_type = "drag";
	ui_min = 0.01;
	ui_max = 1.0;
	ui_step = 0.001;
> = 0.1;

uniform int iBinoculars_CenterType <
	ui_label = "Center Type [Binoculars]";
	ui_type = "combo";
	ui_items = "Manual Value\0Mouse Position\0";
> = 0;

uniform float2 f2Binoculars_ZoomCenter <
	ui_label = "Zoom Center [Binoculars]";
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.001;
> = float2(0.5, 0.5);

uniform int iBinoculars_Aesthetics <
	ui_label = "Aesthetics [Binoculars]";
	ui_type = "combo";
	ui_items = "None\0Texture\0Vignette\0";
> = 1;

uniform bool bBinoculars_DoBlur <
	ui_label = "Do Blur [Binoculars]";
> = true;

uniform bool bBinoculars_BlurFollowsCenter <
	ui_label = "Blur Follows Center [Binoculars]";
> = false;

uniform float fBinoculars_BlurIntensity <
	ui_label = "Blur Intensity [Binoculars]";
	ui_type = "drag";
	ui_min = 0.0;
	ui_max = 1.0;
	ui_step = 0.001;
> = 0.07;

uniform int kBinoculars_Key <
	ui_label = "Zoom Key [Binoculars]";
	ui_type = "combo";
	ui_items = KeyMapper_Items;
> = Key_CapsLock;

uniform int iBinoculars_KeyStyle <
	ui_label = "Zoom Key Style [Binoculars]";
	ui_type = "combo";
	ui_items = "Hold\0Toggle\0";
> = true;

uniform bool bBinoculars_DebugZoom <
	ui_label = "Debug Zoom [Binoculars]";
> = false;

uniform int2 i2Binoculars_MousePos <source="mousepoint";>;

//textures///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

texture tBinoculars_ZoomTex <source="Binoculars.png";> { Width=1280; Height=720; };
texture tBinoculars_Zoom { Format=R16F; };
texture tBinoculars_LastZoom { Format=R16F; };

//samplers///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

sampler sBinoculars_ZoomTex { Texture=tBinoculars_ZoomTex; };
sampler sBinoculars_Zoom { Texture=tBinoculars_Zoom; };
sampler sBinoculars_LastZoom { Texture=tBinoculars_LastZoom; };

//functions//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float3 Blur(sampler sp, float2 uv, float2 center, float amount) {
	float3 col = 0;
	int accum = 0;
	
	int samples = 6;
	
	[unroll]
	for (int i = 1; i <= samples; ++i) {
		float2 coord = uv;
		coord -= center;
		coord *= lerp(1.0, float(samples - i) / float(samples), amount);
		coord += center;
		col += tex2D(sp, coord).rgb;
		++accum;
	}
	
	return col / accum;
}

//shaders////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float GetZoom(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
	float zoom = KeyMapper::GetKey(kBinoculars_Key, iBinoculars_KeyStyle) ? fBinoculars_Zoom : 1.0;
	float last = tex2D(sBinoculars_LastZoom, 0).x;
	return lerp(last, zoom, fBinoculars_ZoomSpeed);
}

float SaveZoom(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
	return tex2D(sBinoculars_Zoom, 0).x;
}

float3 Zoom(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
	float zoom = max(1.0, tex2D(sBinoculars_Zoom, 0).x);
	float zoomPercent = lerp(0.0, zoom / fBinoculars_Zoom, saturate(distance(zoom, 1.0)));
	
	float2 center = iBinoculars_CenterType == 1 ? i2Binoculars_MousePos * ReShade::PixelSize : f2Binoculars_ZoomCenter;
	
	float2 coord = uv;
	coord -= center;
	coord /= zoom;
	coord += center;
	
	float3 col = Blur(ReShade::BackBuffer, coord, bBinoculars_BlurFollowsCenter ? center : 0.5, fBinoculars_BlurIntensity * zoomPercent * bBinoculars_DoBlur);
	
	float4 binoculars = tex2D(sBinoculars_ZoomTex, uv);
	
	col = 	iBinoculars_Aesthetics == 1 ? lerp(col, binoculars.rgb, binoculars.a * zoomPercent) :
			iBinoculars_Aesthetics == 2 ? col * lerp(1.0, (1.0 - distance(uv, 0.5)), zoomPercent) :
			col;
	
	if (bBinoculars_DebugZoom) {
		coord = uv * 0.5; //scale up the uv
		col = coord.x <= 0.1 && coord.y <= 0.025 ? coord.x * 10 : col; //create gradient
		float ps = ReShade::PixelSize.x;
		float exp = clamp(zoomPercent * 0.1, ps, 0.1 - ps); //normalize zoomPercent to our scale and clamp it within the gradient bounds
		col = coord.x < exp + ps && coord.x > exp - ps && coord.y <= 0.025 ? float3(1, 0, 0) : col; //create needle
	}
	
	return col;
}

//techniques/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

technique Binoculars {
	pass GetZoom {
		VertexShader=PostProcessVS;
		PixelShader=GetZoom;
		RenderTarget=tBinoculars_Zoom;
	}
	pass SaveZoom {
		VertexShader=PostProcessVS;
		PixelShader=SaveZoom;
		RenderTarget=tBinoculars_LastZoom;
	}
	pass Zoom {
		VertexShader=PostProcessVS;
		PixelShader=Zoom;
	}
}