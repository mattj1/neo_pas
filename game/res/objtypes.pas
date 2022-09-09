unit objtypes;
{$mode tp}{$H+}
interface
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

var
  TPlayer: ^ObjectPlayer;

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

var
  TMonster: ^ObjectMonster;

implementation
end.
