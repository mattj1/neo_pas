unit sfx;
interface

uses engine;

type TSoundEffect = record
  data: pIntArray;
  size: integer;
  length: integer;
end;

type PSoundEffect = ^TSoundEffect;

procedure SND_PlaySound(snd: PSoundEffect);
function SND_LoadSoundEffect(filename: string): PSoundEffect;
procedure SND_Init;
implementation

procedure SND_PlaySound(snd: PSoundEffect);
begin
end;


function SND_LoadSoundEffect(filename: string): PSoundEffect;
begin
  SND_LoadSoundEffect := nil;
end;

procedure SND_Init;
begin
end;

begin
end.