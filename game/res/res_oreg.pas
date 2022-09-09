unit res_oreg;

{$mode tp}{$H+}
interface

uses
  objtypes,
  entity,
  Player,
  Monster;

procedure RegisterObjectTypes;

implementation

procedure RegisterObjectTypes;
begin
  RegisterEntity(TPlayer, sizeof(ObjectPlayer), sizeof(EntityPlayer), Player_Stuff);
  RegisterEntity(TMonster, sizeof(ObjectMonster), sizeof(EntityMonster), Monster_Stuff);
end;

begin
end.
