unit gtypes;

 {$F+}
interface

uses res_enum, fixedint, Vect2D, rect;

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

  pent_t = ^ent_t;

  sprite_info_t = record
    offsX, offsY: integer;
    srcX, srcY: integer;
    Width, Height: integer;
  end;

type
  CollisionType = (kCollisionTypeNone, kCollisionTypeTile, kCollisionTypeEntity);

  TCollisionItem = record
    collisionType: CollisionType;
    entity: pent_t;
    tileIndex: integer;
  end;

const
  MAX_COLLISION_ITEMS = 32;

type
  TMoveInfo = record
    rect: rect_t;     { The rectangle being moved }
    delta: Vec2D_f32;
    numItems: integer;
    collisionSet: array[0..MAX_COLLISION_ITEMS - 1] of TCollisionItem;
  end;



  MapTileLayer = array[0..1024] of integer;
  MapInfoLayer = array[0..1024] of byte;
  PMapTileLayer = ^MapTileLayer;
  PMapInfoLayer = ^MapInfoLayer;

  TLevelMap = record
    Width, Height: integer;
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




implementation

end.
