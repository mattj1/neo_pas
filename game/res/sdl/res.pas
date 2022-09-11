{ AUTO-GENERATED }

unit res;

{$F+}
interface

uses g_common, res_enum;

const
	sprite_infos: array[0..23] of sprite_info_t = (
		{ SPRITE_NONE_0 }
		(offsX: 0; offsY: 0; srcX: 0; srcY: 0; Width: 0; Height: 0),
		{ SPRITE_PLAYER_IDLE0_0 }
		(offsX: 8; offsY: 16; srcX: 0; srcY: 0; Width: 16; Height: 16),
		{ SPRITE_PLAYER_IDLE1_0 }
		(offsX: 8; offsY: 16; srcX: 0; srcY: 16; Width: 16; Height: 16),
		{ SPRITE_PLAYER_IDLE2_0 }
		(offsX: 8; offsY: 16; srcX: 0; srcY: 32; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK0_0 }
		(offsX: 8; offsY: 16; srcX: 32; srcY: 0; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK0_1 }
		(offsX: 8; offsY: 16; srcX: 32; srcY: 32; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK0_2 }
		(offsX: 8; offsY: 16; srcX: 32; srcY: 64; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK0_3 }
		(offsX: 8; offsY: 16; srcX: 32; srcY: 96; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK1_0 }
		(offsX: 8; offsY: 16; srcX: 64; srcY: 0; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK1_1 }
		(offsX: 8; offsY: 16; srcX: 64; srcY: 32; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK1_2 }
		(offsX: 8; offsY: 16; srcX: 64; srcY: 64; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK1_3 }
		(offsX: 8; offsY: 16; srcX: 64; srcY: 96; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK2_0 }
		(offsX: 8; offsY: 16; srcX: 96; srcY: 0; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK2_1 }
		(offsX: 8; offsY: 16; srcX: 96; srcY: 32; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK2_2 }
		(offsX: 8; offsY: 16; srcX: 96; srcY: 64; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK2_3 }
		(offsX: 8; offsY: 16; srcX: 96; srcY: 96; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK3_0 }
		(offsX: 8; offsY: 16; srcX: 128; srcY: 0; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK3_1 }
		(offsX: 8; offsY: 16; srcX: 128; srcY: 32; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK3_2 }
		(offsX: 8; offsY: 16; srcX: 128; srcY: 64; Width: 16; Height: 16),
		{ SPRITE_PLAYER_WALK3_3 }
		(offsX: 8; offsY: 16; srcX: 128; srcY: 96; Width: 16; Height: 16),
		{ SPRITE_MONSTER_WALK0_0 }
		(offsX: 8; offsY: 8; srcX: 0; srcY: 96; Width: 16; Height: 16),
		{ SPRITE_MONSTER_WALK0_1 }
		(offsX: 8; offsY: 8; srcX: 0; srcY: 96; Width: 16; Height: 16),
		{ SPRITE_MONSTER_WALK0_2 }
		(offsX: 8; offsY: 8; srcX: 0; srcY: 96; Width: 16; Height: 16),
		{ SPRITE_MONSTER_WALK0_3 }
		(offsX: 8; offsY: 8; srcX: 0; srcY: 96; Width: 16; Height: 16)
	);

	sprite_states: array[0..8] of sprite_state_t = (
		{ SPRITE_NONE }
		( sprites: (SPRITE_NONE_0, SPRITE_NONE_0, SPRITE_NONE_0, SPRITE_NONE_0); tileSet: 0 ),
		{ SPRITE_PLAYER_IDLE0 }
		( sprites: (SPRITE_PLAYER_IDLE0_0, SPRITE_PLAYER_IDLE0_0, SPRITE_PLAYER_IDLE0_0, SPRITE_PLAYER_IDLE0_0); tileSet: 0 ),
		{ SPRITE_PLAYER_IDLE1 }
		( sprites: (SPRITE_PLAYER_IDLE1_0, SPRITE_PLAYER_IDLE1_0, SPRITE_PLAYER_IDLE1_0, SPRITE_PLAYER_IDLE1_0); tileSet: 0 ),
		{ SPRITE_PLAYER_IDLE2 }
		( sprites: (SPRITE_PLAYER_IDLE2_0, SPRITE_PLAYER_IDLE2_0, SPRITE_PLAYER_IDLE2_0, SPRITE_PLAYER_IDLE2_0); tileSet: 0 ),
		{ SPRITE_PLAYER_WALK0 }
		( sprites: (SPRITE_PLAYER_WALK0_0, SPRITE_PLAYER_WALK0_1, SPRITE_PLAYER_WALK0_2, SPRITE_PLAYER_WALK0_3); tileSet: 0 ),
		{ SPRITE_PLAYER_WALK1 }
		( sprites: (SPRITE_PLAYER_WALK1_0, SPRITE_PLAYER_WALK1_1, SPRITE_PLAYER_WALK1_2, SPRITE_PLAYER_WALK1_3); tileSet: 0 ),
		{ SPRITE_PLAYER_WALK2 }
		( sprites: (SPRITE_PLAYER_WALK2_0, SPRITE_PLAYER_WALK2_1, SPRITE_PLAYER_WALK2_2, SPRITE_PLAYER_WALK2_3); tileSet: 0 ),
		{ SPRITE_PLAYER_WALK3 }
		( sprites: (SPRITE_PLAYER_WALK3_0, SPRITE_PLAYER_WALK3_1, SPRITE_PLAYER_WALK3_2, SPRITE_PLAYER_WALK3_3); tileSet: 0 ),
		{ SPRITE_MONSTER_WALK0 }
		( sprites: (SPRITE_MONSTER_WALK0_0, SPRITE_MONSTER_WALK0_1, SPRITE_MONSTER_WALK0_2, SPRITE_MONSTER_WALK0_3); tileSet: 0 )
	);

	entity_states: array[0..9] of entity_state_t = (
		(
		state: STATE_NONE;
		nextState: STATE_NONE;
		numFrames: 60; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_NONE 
		),
		(
		state: STATE_PLAYER_IDLE0;
		nextState: STATE_PLAYER_IDLE1;
		numFrames: 20; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER_WALK0 
		),
		(
		state: STATE_PLAYER_IDLE1;
		nextState: STATE_PLAYER_IDLE2;
		numFrames: 20; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER_WALK0 
		),
		(
		state: STATE_PLAYER_IDLE2;
		nextState: STATE_PLAYER_IDLE3;
		numFrames: 20; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER_WALK0 
		),
		(
		state: STATE_PLAYER_IDLE3;
		nextState: STATE_PLAYER_IDLE0;
		numFrames: 20; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER_WALK0 
		),
		(
		state: STATE_PLAYER_WALK0;
		nextState: STATE_PLAYER_WALK1;
		numFrames: 10; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER_WALK0 
		),
		(
		state: STATE_PLAYER_WALK1;
		nextState: STATE_PLAYER_WALK2;
		numFrames: 10; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER_WALK1 
		),
		(
		state: STATE_PLAYER_WALK2;
		nextState: STATE_PLAYER_WALK3;
		numFrames: 10; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER_WALK2 
		),
		(
		state: STATE_PLAYER_WALK3;
		nextState: STATE_PLAYER_WALK0;
		numFrames: 10; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER_WALK3 
		),
		(
		state: STATE_MONSTER_WALK0;
		nextState: STATE_MONSTER_WALK0;
		numFrames: 10; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_MONSTER_WALK0 
		)
	);
implementation
end.
