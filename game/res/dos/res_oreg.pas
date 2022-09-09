unit res_oreg;

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
	RegisterEntity(@ObjectTypes.Player, sizeof(ObjectPlayer), sizeof(EntityPlayer), Player_Update);
	RegisterEntity(@ObjectTypes.Monster, sizeof(ObjectMonster), sizeof(EntityMonster), Monster_Update);
end;
begin
end.

