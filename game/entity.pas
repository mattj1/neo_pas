unit Entity;

interface

uses
  gtypes, res_enum;

var
  entities: array[0..63] of ent_t;

function Entity_Alloc(entity_type: integer): pent_t;
procedure Entity_SetState(var e: ent_t; state: entityState);

implementation

function Entity_Alloc(entity_type: integer): pent_t;
var
  i: integer;
  e: pent_t;
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

end.
