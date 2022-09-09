unit gtypes;

 {$F+}
interface

uses res_enum, fixedint, Vect2D, rect;

const
  MAX_ENT: integer = 64;


type

  TDirection = (DirectionUp, DirectionDown, DirectionLeft,
    DirectionRight, DirectionNone);

  sprite_state_t = record
    sprites: array[0..3] of spriteInfo;
    tileSet: integer;
  end;

type
  ObjectBase = record
     {$I object.inc}
  end;

  EntityBase = record
    {$I entity.inc}
  end;
  PEntity = ^EntityBase;

  sprite_info_t = record
    offsX, offsY: integer;
    srcX, srcY: integer;
    Width, Height: integer;
  end;

type
  TMapTile = record
    x, y: byte;
    fg: integer;
    info: byte;
    {bounds: rect_t;}
  end;

  PMapTile = ^TMapTile;

  CollisionType = (kCollisionTypeNone, kCollisionTypeTile, kCollisionTypeEntity);

  TCollisionItem = record
    collisionType: CollisionType;
    entity: PEntity;
    tile: PMapTile;
  end;

const
  MAX_COLLISION_ITEMS = 16;

type
  TMoveInfo = record
    rect: rect_t;     { The rectangle being moved }
    delta: Vec2D_f32;
    numItems: integer;
    collisionSet: array[0..MAX_COLLISION_ITEMS - 1] of TCollisionItem;
    allowedSlideDirection: TDirection;

    { Final amount the rectangle moved }
    result_delta: Vec2D_f32;
  end;




  TMapTiles = array[0..1024] of TMapTile;
  PMapTiles = ^TMapTiles;

  TLevelMap = record
    Width, Height: integer;
    tiles: PMapTiles;
  end;

  PLevelMap = ^TLevelMap;

  entityOnStateProc = procedure(data: Pointer);
  entityOnFrameProc = procedure(data: Pointer);


  EntityUpdateProc = procedure(Data: Pointer);

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


procedure DirectionToVec2D(dir: TDirection; fac: fix32; var _out: Vec2D_f32);

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
