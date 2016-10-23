/*
	KeyMapper debugger by luluco250
	
	Displays inputs at the top of the screen.
	
	Not necessary for using KeyMapper itself, only for testing purposes.
*/

#include "ReShade.fxh"
#include "KeyMapper.fxh"

//shaders/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float3 ShowMap(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
	float3 col = tex2D(ReShade::BackBuffer, uv).rgb;
	bool2 key = tex2D(KeyMapper::sKeyMapper_Map, uv).xy;
	return uv.y < 0.05 ? float3(key.x, 0, 0) : uv.y < 0.1 ? float3(0, key.y, 0) : col;
}

//techniques//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

technique KeyMapper_Debug {
	pass ShowMap {
		VertexShader=PostProcessVS;
		PixelShader=ShowMap;
	}
}
