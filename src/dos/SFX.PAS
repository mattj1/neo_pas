unit SFX;

interface

uses crt, Engine;


type TSoundEffect = record
  data: pIntArray;
  size: integer;
  length: integer;
end;

type PSoundEffect = ^TSoundEffect;

function SND_AllocSoundEffect(length: integer) : PSoundEffect;
function SND_LoadSoundEffect(filename: string) : PSoundEffect;
procedure SND_FreeSoundEffect(soundEffect: PSoundEffect);
procedure SND_PlaySound(snd: PSoundEffect);
procedure SND_Update;
function SND_IsPlaying : boolean;

procedure SND_Init;
procedure SND_Close;
	
implementation

uses datafile;

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
	if snd = nil then Exit;

  curSound := snd;
  curSoundSample := -1;
end;

function SND_IsPlaying : boolean;
begin
	SND_IsPlaying := curSound <> nil;
end;

function SND_LoadSoundEffect(filename: string) : PSoundEffect;
var f: file;
	length: integer;
	soundEffect: PSoundEffect;
begin
  SND_LoadSoundEffect := nil;
  Datafile_Open(filename, f, 1);

  BlockRead(f, length, 2);

	soundEffect := SND_AllocSoundEffect(length);
	BlockRead(f, soundEffect^.data^, length * 2);

	System.Close(f);

	SND_LoadSoundEffect := soundEffect;
end;

procedure SND_Init;
begin
end;


procedure SND_Close;
begin
end;

begin
	curSound := nil;
end.