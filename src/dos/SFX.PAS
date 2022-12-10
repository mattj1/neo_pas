unit SFX;

interface

uses crt, Common;


type TSoundEffect = record
  data: pIntArray;
  size: integer;
  length: integer;
end;

type PSoundEffect = ^TSoundEffect;

function SND_AllocSoundEffect(length: integer) : PSoundEffect;
procedure SND_FreeSoundEffect(soundEffect: PSoundEffect);
procedure SND_PlaySound(snd: PSoundEffect);
procedure SND_Update;
function SND_IsPlaying : boolean;

implementation


var curSound: PSoundEffect;

var curSoundSample: integer;
procedure SND_Update;
	  var freq: integer;
begin
	if curSound <> nil then begin
	  inc(curSoundSample, 1);

	  if curSoundSample = curSound^.length - 1 then begin
	    curSound := nil;
	    NoSound;
	  end else begin
	    freq := curSound^.data^[curSoundSample];
	    if freq = 0 then begin
	      NoSound;
	    end else begin
	      Sound(freq);
	    end;
	  end;
	end;
end;

function SND_AllocSoundEffect(length: integer) : PSoundEffect;
  var soundEffect: PSoundEffect;
begin
  GetMem(soundEffect, sizeof(TSoundEffect));
  GetMem(soundEffect^.data, length * sizeof(integer));

  { Allocated size }
  soundEffect^.size := length;
  
  { Length of sound. Shouldn't exceed size. }
  soundEffect^.length := length;

  SND_AllocSoundEffect := soundEffect;
end;

procedure SND_FreeSoundEffect(soundEffect: PSoundEffect);
begin
  FreeMem(soundEffect^.data, soundEffect^.size);
  FreeMem(soundEffect, sizeof(TSoundEffect));
end;

procedure SND_PlaySound(snd: PSoundEffect);
begin
  curSound := snd;
  curSoundSample := -1;
end;

function SND_IsPlaying : boolean;
begin
	SND_IsPlaying := curSound <> nil;
end;

begin
	curSound := nil;
end.