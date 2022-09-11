unit Entity;

interface

uses
  common, g_common, res_enum, objtypes;

var
  { Object Registry }
  entityTypes: array[0..63] of EntityType;

  { Entity instances }
  entities2: array[0..63] of PEntity;
  


function AllocEntity(clz: Pointer): PEntity;
procedure RegisterEntity(clz: Pointer; objectSize, entitySize: integer;
  updateProc: EntityUpdateProc);
procedure Entity_SetState(data: Pointer; state: entityState);

implementation

var
  current_entity_type: integer;

procedure RegisterEntity(clz: Pointer; objectSize, entitySize: integer;
  updateProc: EntityUpdateProc);
var
  base: ^ObjectBase;
var
  et: ^EntityType;

begin

  if (clz = nil) then begin
    writeln('RegisterEntity: Got null.');
    exit;
  end;

  base := clz;

  if (base^.classID <> 0) then
  begin
    writeln('RegisterEntity: already registered this class. ID:', base^.classID);
    exit;
  end;

  writeln('RegisterEntity. Size of Object:', objectSize, ' Size of Entity:', entitySize, ' type: ', current_entity_type);

  GetMem(clz, objectSize);

  base^.classID := current_entity_type;

  et := @entityTypes[current_entity_type];

   { GetMem(et, sizeof(EntityType)); }

  et^.entitySize := entitySize;
  et^.updateProc := updateProc;

  Inc(current_entity_type);

end;


function AllocEntity(clz: Pointer): PEntity;
var
  base: ^ObjectBase;
  inst: PEntity;
  entity_type: ^EntityType;
  i: integer;
begin

  base := clz;
  entity_type := @EntityTypes[base^.classID];

  writeln('AllocEntity: ', base^.classID, ' size: ', entity_type^.entitySize);

  for i := 0 to MAX_ENT - 1 do
  begin
    if entities2[i] = nil then begin
      GetMem(inst, entity_type^.entitySize);
      FillChar(inst^, entity_type^.entitySize, 0);
      inst^.classID := base^.classID;
      entities2[i] := inst;

      AllocEntity := inst;
      
      exit;
    end;
  end;

  AllocEntity := nil;
end;

procedure Entity_SetState(data: Pointer; state: entityState);
var
  self: PEntity;
begin
  self := PEntity(data);

  self^.stateTime := 0;
  self^.state := state;
end;

begin
  current_entity_type := 1;
end.
end.
