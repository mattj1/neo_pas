unit SFX;

interface

{$H-}
uses Engine,
  Classes, SysUtils, SDL2;

type
  TSoundEffect = record
    Data: pIntArray;
    size: integer;
    length: integer;
  end;

type
  PSoundEffect = ^TSoundEffect;


procedure SND_Init;
function SND_AllocSoundEffect(length: integer): PSoundEffect;
function SND_LoadSoundEffect(filename: string): PSoundEffect;
procedure SND_FreeSoundEffect(soundEffect: PSoundEffect);
procedure SND_PlaySound(snd: PSoundEffect);
procedure SND_Update;
function SND_IsPlaying: boolean;

implementation



var
  curSound: PSoundEffect;
  obtained: TSDL_AudioSpec;
  curSoundSample: integer;
  RunningSampleIndex: uint32;
  SoundTick: uint32;
  bytesPerSample: integer;
  isFloat: integer;
  curFreq: integer;

type
  int_ptr = ^integer;

procedure SND_Update;

begin
  if curSound <> nil then
  begin
    Inc(curSoundSample, 1);

    if curSoundSample = curSound^.length - 1 then
    begin
      curSound := nil;
      curFreq := 0;
    end
    else
    begin
      curFreq := curSound^.Data^[curSoundSample];
    end;
  end;
end;

function SND_AllocSoundEffect(length: integer): PSoundEffect;
var
  soundEffect: PSoundEffect;
begin
  GetMem(soundEffect, sizeof(TSoundEffect));
  GetMem(soundEffect^.Data, length * sizeof(integer));

  { Allocated size }
  soundEffect^.size := length;

  { Length of sound. Shouldn't exceed size. }
  soundEffect^.length := length;

  SND_AllocSoundEffect := soundEffect;
end;

procedure SND_FreeSoundEffect(soundEffect: PSoundEffect);
begin
  FreeMem(soundEffect^.Data, soundEffect^.size);
  FreeMem(soundEffect, sizeof(TSoundEffect));
end;

procedure SND_PlaySound(snd: PSoundEffect);
begin
  if snd = nil then Exit;

  curSound := snd;
  curSoundSample := -1;
end;

function SND_IsPlaying: boolean;
begin
  SND_IsPlaying := curSound <> nil;
end;

function SND_LoadSoundEffect(filename: string): PSoundEffect;
var
  f: file;
  length: integer;
  soundEffect: PSoundEffect;
begin
  SND_LoadSoundEffect := nil;

  Assign(f, filename);
  Reset(f, 2);

  BlockRead(f, length, 1);

  soundEffect := SND_AllocSoundEffect(length);
  BlockRead(f, soundEffect^.Data^, length);

  System.Close(f);

  SND_LoadSoundEffect := soundEffect;
end;

procedure AudioCallback(userdata: Pointer; stream: PUInt8; len: longint); cdecl;
var
  i: longint;
  bp: PUInt8;
  toneHz: uint16;
  toneVolume: uint16;
  numSamples: longint;
  squareWavePeriod: uint32;
  halfSquareWavePeriod: uint32;
  SampleValue: integer;

  floatSampleValue: Float;
  floatToneVolume: Float;

begin

  floatToneVolume := 0.025;
  toneVolume := 3000;
  numSamples := (len div 4) div 2;
  {numSamples := len div 4;}


  bp := stream;

  {writeln('AudioCallback ', len);}
  for i := 0 to numSamples - 1 do
  begin

    toneHz := curFreq;

    if toneHz <> 0 then
    begin
      squareWavePeriod := obtained.freq div toneHz;
      halfSquareWavePeriod := squareWavePeriod div 2;


      if ((RunningSampleIndex div HalfSquareWavePeriod) mod 2) = 1 then
        //SampleValue := ToneVolume
        floatSampleValue := floatToneVolume
      else
        floatSampleValue := -floatToneVolume;
      //SampleValue := -ToneVolume;
    end
    else
    begin
      floatSampleValue := 0;
    end;

    {writeln(i, ' ', Samplevalue);}
    Move(floatSampleValue, bp^, bytesPerSample);
    Inc(bp, bytesPerSample);

    Move(floatSampleValue, bp^, bytesPerSample);
    Inc(bp, bytesPerSample);



    Inc(RunningSampleIndex);
    Inc(soundTick);
    if (soundTick > 200) then
    begin
      soundTick := 0;
      SND_Update;
    end;
  end;
end;

procedure SND_Init;
var
  audioSpec: TSDL_AudioSpec;

begin
  audioSpec.freq := 22050;
  audioSpec.format := AUDIO_S16;
  audioSpec.samples := 1024;
  audioSpec.callback := AudioCallback;
  audioSpec.userdata := nil;
  audioSpec.channels := 1;

  RunningSampleIndex := 0;
  soundTick := 0;
  writeln(SDL_GetAudioDeviceName(0, 0));

  //if SDL_OpenAudioDevice(nil, 0, @audioSpec, @obtained, SDL_AUDIO_ALLOW_ANY_CHANGE) < 0 then
  if SDL_OpenAudio(@audioSpec, @obtained) < 0 then
  begin
    writeln('bad audio spec');
    Exit;
  end;

  writeln('Opened audio ', obtained.freq, ' channels: ', obtained.channels);

  bytesPerSample := SDL_AUDIO_BITSIZE(obtained.format) div 8;
  isFloat := SDL_AUDIO_ISFLOAT(obtained.format);
  //writeln('is float: ',);

  SDL_PauseAudio(0);

end;

begin
  curSound := nil;

end.
