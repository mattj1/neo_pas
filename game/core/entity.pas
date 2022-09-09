unit Entity;

interface

uses
  common, gtypes, res_enum, objtypes;

var
  entities: array[0..63] of ent_t;
  entities2: array[0..63] of PEntity;

  entityTypes: array[0..63] of EntityType;


function AllocEntity(var clz: Pointer): PEntity;
procedure RegisterEntity(var clz: Pointer; objectSize, entitySize: integer;
  updateProc: EntityUpdateProc);
function Entity_Alloc(entity_type: integer): pent_t;
procedure Entity_SetState(var e: ent_t; state: entityState);

implementation

var
  current_entity_type: integer;

procedure RegisterEntity(var clz: Pointer; objectSize, entitySize: integer;
  updateProc: EntityUpdateProc);
var
  base: ^ObjectBase;
var
  et: ^EntityType;

begin
  if (clz <> nil) then
  begin
    writeln('RegisterEntity: already registered this class.');
    exit;
  end;

  writeln('RegisterEntity. Size of Object:', objectSize, ' Size of Entity:', entitySize);
  GetMem(clz, objectSize);

  base := clz;
  base^.classID := current_entity_type;

  et := @entityTypes[current_entity_type];

  //GetMem(et, sizeof(EntityType));

  et^.entitySize := entitySize;
  et^.updateProc := updateProc;

  Inc(current_entity_type);

end;


function AllocEntity(var clz: Pointer): PEntity;
var
  base: ^ObjectBase;
var
  inst: PEntity;
var
  entity_type: ^EntityType;
begin
  // AllocEntity(PlayerStatic)


  base := clz;
  entity_type := @EntityTypes[base^.classID];

  writeln('AllocEntity: ', base^.classID);

  GetMem(inst, entity_type^.entitySize);

  inst^.classID := base^.classID;

  AllocEntity := inst;
end;

function Entity_Alloc(entity_type: integer): pent_t;
var
  i: integer;
  e: pent_t;
  p: Pointer;
begin
  for i := 0 to MAX_ENT - 1 do
  begin
    e := @entities[i];
    if e^.entity_type = 0 then
    begin

      Entity_Alloc := e;
      e^.entity_type := entity_type;
      Exit;
    end;
  end;
end;

procedure Entity_SetState(var e: ent_t; state: entityState);
begin
  e.stateTime := 0;
  e.state := state;
end;

begin
  current_entity_type := 0;
end.
end.
