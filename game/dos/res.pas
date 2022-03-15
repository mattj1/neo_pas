{ AUTO-GENERATED }

unit res;

{$F+}
interface

uses gtypes, res_enum;

const
	sprite_infos: array[0..2] of sprite_info_t = (
		{ SPRITE_NONE_0 }
		(offsX: 0; offsY: 0; srcX: 0; srcY: 0; Width: 0; Height: 0),
		{ SPRITE_PLAYER0_0 }
		(offsX: 0; offsY: 0; srcX: 0; srcY: 0; Width: 16; Height: 32),
		{ SPRITE_PLAYER1_0 }
		(offsX: 0; offsY: 0; srcX: 16; srcY: 0; Width: 16; Height: 32)
	);

	sprite_states: array[0..2] of sprite_state_t = (
		{ SPRITE_NONE }
		( sprites: (SPRITE_NONE_0, SPRITE_NONE_0, SPRITE_NONE_0, SPRITE_NONE_0); tileSet: 0 ),
		{ SPRITE_PLAYER0 }
		( sprites: (SPRITE_PLAYER0_0, SPRITE_PLAYER0_0, SPRITE_PLAYER0_0, SPRITE_PLAYER0_0); tileSet: 0 ),
		{ SPRITE_PLAYER1 }
		( sprites: (SPRITE_PLAYER1_0, SPRITE_PLAYER1_0, SPRITE_PLAYER1_0, SPRITE_PLAYER1_0); tileSet: 0 )
	);

	entity_states: array[0..2] of entity_state_t = (
		(
		state: STATE_NONE;
		nextState: STATE_NONE;
		numFrames: 60; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_NONE 
		),
		(
		state: STATE_PLAYER0;
		nextState: STATE_PLAYER1;
		numFrames: 20; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER0 
		),
		(
		state: STATE_PLAYER1;
		nextState: STATE_PLAYER0;
		numFrames: 20; 
		onStateProc: nil; 
		onFrameProc: nil; 
		spriteState_: SPRITE_PLAYER1 
		)
	);
implementation
end.
