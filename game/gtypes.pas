unit gtypes;

 {$F+}
interface

uses res_enum, fixedint;

const
  MAX_ENT: integer = 64;


type
  sprite_state_t = record
    sprites: array[0..3] of spriteInfo;
    tileSet: integer;
  end;

  ent_t = record
    origin: Vec2D_f32;
    entity_type: integer;
    stateTime: integer;
    state: entityState;
  end;

  sprite_info_t = record
    offsX, offsY: integer;
    srcX, srcY: integer;
    Width, Height: integer;
  end;

  rect_t = record
    origin: Vec2D_f32;
    size: Vec2D_f32;
  end;


 MapTileLayer = array[0..1024] of integer;
  MapInfoLayer = array[0..1024] of byte;
  PMapTileLayer = ^MapTileLayer;
  PMapInfoLayer = ^MapInfoLayer;

  TLevelMap = record
    width, height: integer;
    fg: PMapTileLayer;
    info: PMapInfoLayer;
  end;

  PLevelMap = ^TLevelMap;

  entityOnStateProc = procedure(var e: ent_t);
  entityOnFrameProc = procedure(var e: ent_t);

  entity_state_t = record
    state: entityState;
    nextState: entityState;
    numFrames: integer;
    onStateProc: entityOnStateProc;
    onFrameProc: entityOnFrameProc;

    spriteState_: spriteState;
  end;

  pent_t = ^ent_t;




implementation

end.
