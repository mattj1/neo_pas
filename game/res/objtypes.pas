unit objtypes;

interface
uses vect2d, res_enum, gtypes;
type
  ObjectPlayer = record
    {$i object.inc}
    playerStatic1: integer;
    playerStatic2: integer;
  end;
  EntityPlayer = record
    {$i entity.inc}
    instanceStuff1: integer;
    instanceStuff2: integer;
  end;

  PEntityPlayer = ^EntityPlayer;


type
  ObjectMonster = record
    {$i object.inc}
    monsterStatic1: integer;
    foo: integer;
  end;
  EntityMonster = record
    {$i entity.inc}
    monsterInstance1: integer;
  end;

  PEntityMonster = ^EntityMonster;


  TObjectTypes = record
    Player: ObjectPlayer;
    Monster: ObjectMonster;
  end;
var
  ObjectTypes: TObjectTypes;
implementation
begin
  writeln('objtypes.pas');
  FillChar(ObjectTypes, sizeof(TObjectTypes), 0);
end.
end.
