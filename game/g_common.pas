unit g_common;

interface

uses res_enum, fixedint, vect2d, rect;

const
  MAX_ENT: integer = 64;
  MAX_COLLISION_ITEMS = 16;

type
  entityOnStateProc = procedure(Data: Pointer);
  entityOnFrameProc = procedure(Data: Pointer);

  EntityUpdateProc = procedure(Data: Pointer);

  CollisionType = (kCollisionTypeNone, kCollisionTypeTile, kCollisionTypeEntity);

  TDirection = (DirectionUp, DirectionDown, DirectionLeft,
    DirectionRight, DirectionNone);

  sprite_state_t = record
    sprites: array[0..3] of spriteInfo;
    tileSet: integer;
  end;

  sprite_info_t = record
    offsX, offsY: integer;
    srcX, srcY: integer;
    Width, Height: integer;
  end;

  TMapTile = record
    x, y: byte;
    fg: integer;
    info: byte;
    {bounds: rect_t;}
  end;

  PMapTile = ^TMapTile;

  TMapTiles = array[0..1024] of TMapTile;
  PMapTiles = ^TMapTiles;

  TLevelMap = record
    Width, Height: integer;
    tiles: PMapTiles;
  end;

  PLevelMap = ^TLevelMap;

  ObjectBase = record
     {$I object.inc}
  end;

  EntityBase = record
    {$I entity.inc}
  end;
  PEntity = ^EntityBase;

  EntityType = record
    classID: integer;
    entitySize: integer;

    updateProc: EntityUpdateProc;
  end;

  entity_state_t = record
    state: entityState;
    nextState: entityState;
    numFrames: integer;
    onStateProc: entityOnStateProc;
    onFrameProc: entityOnFrameProc;

    spriteState_: spriteState;
  end;

  TCollisionItem = record
    collisionType: CollisionType;
    entity: PEntity;
    tile: PMapTile;
  end;

  TMoveInfo = record
    rect: rect_t;     { The rectangle being moved }
    delta: Vec2D_f32;
    numItems: integer;
    collisionSet: array[0..MAX_COLLISION_ITEMS - 1] of TCollisionItem;
    allowedSlideDirection: TDirection;

    { Final amount the rectangle moved }
    result_delta: Vec2D_f32;
  end;

  TGlobal = record
    player: PEntity;

  end;

procedure DirectionToVec2D(dir: TDirection; fac: fix32; var _out: Vec2D_f32);

var
  Global: TGlobal;
  map: TLevelMap;
  player_input: integer;


implementation

procedure DirectionToVec2D(dir: TDirection; fac: fix32; var _out: Vec2D_f32);
begin
  case (dir) of
    DirectionUp:
      Vect2D.SetFromInt(_out, 0, -1);
    DirectionDown:
      Vect2D.SetFromInt(_out, 0, 1);
    DirectionLeft:
      Vect2D.SetFromInt(_out, -1, 0);
    DirectionRight:
      Vect2D.SetFromInt(_out, 1, 0);
  end;

  Vect2D.MultFix32(_out, fac, _out);
end;

end.
