{ AUTO-GENERATED }

unit res;

interface

uses gtypes, res_enum;

const
	sprite_infos: array[0..2] of sprite_info_t = (
		{ SPRITE_PLAYER0_0 }
		(offsX: 0; offsY: 0; srcX: 0; srcY: 0; Width: 16; Height: 16),
		{ SPRITE_PLAYER0_1 }
		(offsX: 0; offsY: 0; srcX: 0; srcY: 16; Width: 16; Height: 16),
		{ SPRITE_PLAYER1_0 }
		(offsX: 0; offsY: 0; srcX: 16; srcY: 0; Width: 16; Height: 16)
	);

	sprite_states: array[0..1] of sprite_state_t = (
		{ SPRITE_PLAYER0 }
		( sprites: (SPRITE_PLAYER0_0, SPRITE_PLAYER0_1, SPRITE_PLAYER0_0, SPRITE_PLAYER0_0); tileSet: 0 ),
		{ SPRITE_PLAYER1 }
		( sprites: (SPRITE_PLAYER1_0, SPRITE_PLAYER1_0, SPRITE_PLAYER1_0, SPRITE_PLAYER1_0); tileSet: 0 )
	);
implementation
end.
