/*
	KeyMapper by luluco250
	
	Creates a texture with all the available keycodes.
	
	Keycodes taken from https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
	
	Add "#include KeyMapper.fxh" to use KeyMapper in your shader.
	
	To get the state of a key, you must first define an int uniform as such:
	
	uniform int keyToDoThing <ui_type="combo"; ui_items=KeyMapper_Items;> = 0;
	
	This will allow you to have a key selector in the ReShade menu.
	Optionally, you may also create a bool uniform such as:
	
	uniform bool keyIsToggle = false;
	
	To allow the selection of whether to get the hold or toggle state of a key.
	Finally, call KeyMapper::GetKey(keyToDoThing, keyIsToggle) to get the state of the aforementioned key.
	
	If you don't need to switch between toggle or not, you may use 0 (hold) or 1 (toggle) instead of keyIsToggle.
	
	If you wish to get a key directly, you may refer to the list of defines below and use KeyMapper::GetKey(Key_X, keyIsToggle), X being the key name.
	
	Mouse buttons don't seem to work yet.
*/

#include "ReShade.fxh"
#include "KeyMapper.fxh"

//macro for creating key uniforms faster
#define CreateKeyCode(name, code) \
uniform bool name 			<source="key"; keycode=code; toggle=false;>;\
uniform bool name##_Toggle 	<source="key"; keycode=code; toggle=true;>;

//mouse keys use a different source
uniform bool LMouse 		<source="mousebutton"; keycode=0; toggle=false;>;
uniform bool LMouse_Toggle 	<source="mousebutton"; keycode=0; toggle=true;>;
uniform bool RMouse 		<source="mousebutton"; keycode=1; toggle=false;>;
uniform bool RMouse_Toggle 	<source="mousebutton"; keycode=1; toggle=true;>;
uniform bool MMouse 		<source="mousebutton"; keycode=2; toggle=false;>;
uniform bool MMouse_Toggle 	<source="mousebutton"; keycode=2; toggle=true;>;

//regular keys, they all generate uniform bools following the macro above
CreateKeyCode(Tab, 0x09);
CreateKeyCode(Return, 0x0d);
CreateKeyCode(Shift, 0x10);
CreateKeyCode(Control, 0x11);
CreateKeyCode(Alt, 0x12);
CreateKeyCode(Pause, 0x13);
CreateKeyCode(CapsLock, 0x14);
CreateKeyCode(Escape, 0x1b);
CreateKeyCode(Space, 0x20);
CreateKeyCode(PageUp, 0x21);
CreateKeyCode(PageDown, 0x22);
CreateKeyCode(End, 0x23);
CreateKeyCode(Home, 0x24);
CreateKeyCode(Left, 0x25);
CreateKeyCode(Up, 0x26);
CreateKeyCode(Right, 0x27);
CreateKeyCode(Down, 0x28);
CreateKeyCode(PrintScreen, 0x2c);
CreateKeyCode(Insert, 0x2d);
CreateKeyCode(Delete, 0x2e);
CreateKeyCode(Zero, 0x30);
CreateKeyCode(One, 0x31);
CreateKeyCode(Two, 0x32);
CreateKeyCode(Three, 0x33);
CreateKeyCode(Four, 0x34);
CreateKeyCode(Five, 0x35);
CreateKeyCode(Six, 0x36);
CreateKeyCode(Seven, 0x37);
CreateKeyCode(Eight, 0x38);
CreateKeyCode(Nine, 0x39);
CreateKeyCode(A, 0x41);
CreateKeyCode(B, 0x42);
CreateKeyCode(C, 0x43);
CreateKeyCode(D, 0x44);
CreateKeyCode(E, 0x45);
CreateKeyCode(F, 0x46);
CreateKeyCode(G, 0x47);
CreateKeyCode(H, 0x48);
CreateKeyCode(I, 0x49);
CreateKeyCode(J, 0x4a);
CreateKeyCode(K, 0x4b);
CreateKeyCode(L, 0x4c);
CreateKeyCode(M, 0x4d);
CreateKeyCode(N, 0x4e);
CreateKeyCode(O, 0x4f);
CreateKeyCode(P, 0x50);
CreateKeyCode(Q, 0x51);
CreateKeyCode(R, 0x52);
CreateKeyCode(S, 0x53);
CreateKeyCode(T, 0x54);
CreateKeyCode(U, 0x55);
CreateKeyCode(V, 0x56);
CreateKeyCode(W, 0x57);
CreateKeyCode(X, 0x58);
CreateKeyCode(Y, 0x59);
CreateKeyCode(Z, 0x5a);
CreateKeyCode(NumpadZero, 0x60);
CreateKeyCode(NumpadOne, 0x61);
CreateKeyCode(NumpadTwo, 0x62);
CreateKeyCode(NumpadThree, 0x63);
CreateKeyCode(NumpadFour, 0x64);
CreateKeyCode(NumpadFive, 0x65);
CreateKeyCode(NumpadSix, 0x66);
CreateKeyCode(NumpadSeven, 0x67);
CreateKeyCode(NumpadEight, 0x68);
CreateKeyCode(NumpadNine, 0x69);
CreateKeyCode(Multiply, 0x6a);
CreateKeyCode(Add, 0x6b);
CreateKeyCode(Subtract, 0x6d);
CreateKeyCode(Decimal, 0x6e);
CreateKeyCode(Divide, 0x6f);
CreateKeyCode(F1, 0x70);
CreateKeyCode(F2, 0x71);
CreateKeyCode(F3, 0x72);
CreateKeyCode(F4, 0x73);
CreateKeyCode(F5, 0x74);
CreateKeyCode(F6, 0x75);
CreateKeyCode(F7, 0x76);
CreateKeyCode(F8, 0x77);
CreateKeyCode(F9, 0x78);
CreateKeyCode(F10, 0x79);
CreateKeyCode(F11, 0x7a);
CreateKeyCode(F12, 0x7b);
CreateKeyCode(NumLock, 0x90);
CreateKeyCode(ScrollLock, 0x91);
CreateKeyCode(Semicolon, 0xba);
CreateKeyCode(Plus, 0xbb);
CreateKeyCode(Comma, 0xbc);
CreateKeyCode(Minus, 0xbd);
CreateKeyCode(Period, 0xbe);
CreateKeyCode(Backslash, 0xbf);
CreateKeyCode(Tilde, 0xc0);
CreateKeyCode(LeftBracket, 0xdb);
CreateKeyCode(Slash, 0xdc);
CreateKeyCode(RightBracket, 0xdd);
CreateKeyCode(Apostrophe, 0xde);

//shader to create the key map
bool2 CreateMap(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_Target {
	int charPos = uv.x * KeyMapper_KeyAmount;
	return	charPos == 0 ? bool2(LMouse, LMouse_Toggle) :
			charPos == 1 ? bool2(RMouse, RMouse_Toggle) :
			charPos == 2 ? bool2(MMouse, MMouse_Toggle) :
			charPos == 3 ? bool2(Tab, Tab_Toggle) :
			charPos == 4 ? bool2(Return, Return_Toggle) :
			charPos == 5 ? bool2(Shift, Shift_Toggle) :
			charPos == 6 ? bool2(Control, Control_Toggle) :
			charPos == 7 ? bool2(Alt, Alt_Toggle) :
			charPos == 8 ? bool2(Pause, Pause_Toggle) :
			charPos == 9 ? bool2(CapsLock, CapsLock_Toggle) :
			charPos == 10 ? bool2(Escape, Escape_Toggle) :
			charPos == 11 ? bool2(Space, Space_Toggle) :
			charPos == 12 ? bool2(PageUp, PageUp_Toggle) :
			charPos == 13 ? bool2(PageDown, PageDown_Toggle) :
			charPos == 14 ? bool2(End, End_Toggle) :
			charPos == 15 ? bool2(Home, Home_Toggle) :
			charPos == 16 ? bool2(Left, Left_Toggle) :
			charPos == 17 ? bool2(Up, Up_Toggle) :
			charPos == 18 ? bool2(Right, Right_Toggle) :
			charPos == 19 ? bool2(Down, Down_Toggle) :
			charPos == 20 ? bool2(PrintScreen, PrintScreen_Toggle) :
			charPos == 21 ? bool2(Insert, Insert_Toggle) :
			charPos == 22 ? bool2(Delete, Delete_Toggle) :
			charPos == 23 ? bool2(Zero, Zero_Toggle) :
			charPos == 24 ? bool2(One, One_Toggle) :
			charPos == 25 ? bool2(Two, Two_Toggle) :
			charPos == 26 ? bool2(Three, Three_Toggle) :
			charPos == 27 ? bool2(Four, Four_Toggle) :
			charPos == 28 ? bool2(Five, Five_Toggle) :
			charPos == 29 ? bool2(Six, Six_Toggle) :
			charPos == 30 ? bool2(Seven, Seven_Toggle) :
			charPos == 31 ? bool2(Eight, Eight_Toggle) :
			charPos == 32 ? bool2(Nine, Nine_Toggle) :
			charPos == 33 ? bool2(A, A_Toggle) :
			charPos == 34 ? bool2(B, B_Toggle) :
			charPos == 35 ? bool2(C, C_Toggle) :
			charPos == 36 ? bool2(D, D_Toggle) :
			charPos == 37 ? bool2(E, E_Toggle) :
			charPos == 38 ? bool2(F, F_Toggle) :
			charPos == 39 ? bool2(G, G_Toggle) :
			charPos == 40 ? bool2(H, H_Toggle) :
			charPos == 41 ? bool2(I, I_Toggle) :
			charPos == 42 ? bool2(J, J_Toggle) :
			charPos == 43 ? bool2(K, K_Toggle) :
			charPos == 44 ? bool2(L, L_Toggle) :
			charPos == 45 ? bool2(M, M_Toggle) :
			charPos == 46 ? bool2(N, N_Toggle) :
			charPos == 47 ? bool2(O, O_Toggle) :
			charPos == 48 ? bool2(P, P_Toggle) :
			charPos == 49 ? bool2(Q, Q_Toggle) :
			charPos == 50 ? bool2(R, R_Toggle) :
			charPos == 51 ? bool2(S, S_Toggle) :
			charPos == 52 ? bool2(T, T_Toggle) :
			charPos == 53 ? bool2(U, U_Toggle) :
			charPos == 54 ? bool2(V, V_Toggle) :
			charPos == 55 ? bool2(W, W_Toggle) :
			charPos == 56 ? bool2(X, X_Toggle) :
			charPos == 57 ? bool2(Y, Y_Toggle) :
			charPos == 58 ? bool2(Z, Z_Toggle) :
			charPos == 59 ? bool2(NumpadZero, NumpadZero_Toggle) :
			charPos == 60 ? bool2(NumpadOne, NumpadOne_Toggle) :
			charPos == 61 ? bool2(NumpadTwo, NumpadTwo_Toggle) :
			charPos == 62 ? bool2(NumpadThree, NumpadThree_Toggle) :
			charPos == 63 ? bool2(NumpadFour, NumpadFour_Toggle) :
			charPos == 64 ? bool2(NumpadFive, NumpadFive_Toggle) :
			charPos == 65 ? bool2(NumpadSix, NumpadSix_Toggle) :
			charPos == 66 ? bool2(NumpadSeven, NumpadSeven_Toggle) :
			charPos == 67 ? bool2(NumpadEight, NumpadEight_Toggle) :
			charPos == 68 ? bool2(NumpadNine, NumpadNine_Toggle) :
			charPos == 69 ? bool2(Multiply, Multiply_Toggle) :
			charPos == 70 ? bool2(Add, Add_Toggle) :
			charPos == 71 ? bool2(Subtract, Subtract_Toggle) :
			charPos == 72 ? bool2(Decimal, Decimal_Toggle) :
			charPos == 73 ? bool2(Divide, Divide_Toggle) :
			charPos == 74 ? bool2(F1, F1_Toggle) :
			charPos == 75 ? bool2(F2, F2_Toggle) :
			charPos == 76 ? bool2(F3, F3_Toggle) :
			charPos == 77 ? bool2(F4, F4_Toggle) :
			charPos == 78 ? bool2(F5, F5_Toggle) :
			charPos == 79 ? bool2(F6, F6_Toggle) :
			charPos == 80 ? bool2(F7, F7_Toggle) :
			charPos == 81 ? bool2(F8, F8_Toggle) :
			charPos == 82 ? bool2(F9, F9_Toggle) :
			charPos == 83 ? bool2(F10, F10_Toggle) :
			charPos == 84 ? bool2(F11, F11_Toggle) :
			charPos == 85 ? bool2(F12, F12_Toggle) :
			charPos == 86 ? bool2(NumLock, NumLock_Toggle) :
			charPos == 87 ? bool2(ScrollLock, ScrollLock_Toggle) :
			charPos == 88 ? bool2(Semicolon, Semicolon_Toggle) :
			charPos == 89 ? bool2(Plus, Plus_Toggle) :
			charPos == 90 ? bool2(Comma, Comma_Toggle) :
			charPos == 91 ? bool2(Minus, Minus_Toggle) :
			charPos == 92 ? bool2(Period, Period_Toggle) :
			charPos == 93 ? bool2(Backslash, Backslash_Toggle) :
			charPos == 94 ? bool2(Tilde, Tilde_Toggle) :
			charPos == 95 ? bool2(LeftBracket, LeftBracket_Toggle) :
			charPos == 96 ? bool2(Slash, Slash_Toggle) :
			charPos == 97 ? bool2(RightBracket, RightBracket_Toggle) :
			charPos == 98 ? bool2(Apostrophe, Apostrophe_Toggle) :
			bool2(false, false);
}

technique KeyMapper {
	pass CreateMap {
		VertexShader=PostProcessVS;
		PixelShader=CreateMap;
		RenderTarget=KeyMapper::tKeyMapper_Map;
	}
}
