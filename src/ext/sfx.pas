
unit sfx;

interface

uses engine;

type
  TSoundEffect = record
    Data: pIntArray;
    size: integer;
    length: integer;
  end;

type
  PSoundEffect = ^TSoundEffect;

procedure SND_PlaySound(snd: PSoundEffect);
function SND_LoadSoundEffect(filename: string): PSoundEffect;
procedure SND_Init;

implementation

uses raylib, Math, datafile;

var
  didInit: boolean;
  stream: TAudioStream;
  sineIdx: real;
  curFreq: integer;
  curSound: PSoundEffect;
  curSoundSample: integer;
  SoundTick: uint32;
  RunningSampleIndex: uint32;



const
  frequency: real = 440.0;

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
      // writeln('SND_Update idx ', curSoundSample, ' freq ', curFreq);
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

function SND_LoadSoundEffect(filename: string): PSoundEffect;

var
  f: file;
  length: integer;
  soundEffect: PSoundEffect;
begin
  SND_LoadSoundEffect := nil;
  Datafile_Open(filename, f, 1);

  BlockRead(f, length, 2);
  // writeln(' sound effect len in samples: ', length);

  soundEffect := SND_AllocSoundEffect(length);
  BlockRead(f, soundEffect^.Data^, length * 2);

  Datafile_Close(f);

  SND_LoadSoundEffect := soundEffect;
end;


procedure AudioInputCallback(bufferData: Pointer; frames: longword);

var
  audioFrequency, incr: real;
  d: ^integer;
  i: longword;
  toneHz, toneVolume: uint16;
  squareWavePeriod: uint32;
  halfSquareWavePeriod: uint32;
  SampleValue: integer;
begin
  
  // WriteLn('AudioInputCallback ', ptruint(bufferData), ' ', frames);
  //writeln(IsAudioStreamProcessed(stream));

  audioFrequency := 440.0;
  toneVolume := 3000;

  d := bufferData;

  for i := 1 to frames do
  begin
    toneHz := curFreq;
    if toneHz <> 0 then
    begin
      // writeln( ' playing sound freq ', toneHz);
      squareWavePeriod := 22050 div toneHz;
      halfSquareWavePeriod := squareWavePeriod div 2;


      if ((RunningSampleIndex div HalfSquareWavePeriod) mod 2) = 1 then
      begin
        SampleValue := ToneVolume;
        // floatSampleValue := floatToneVolume;
      end
      else
      begin
        SampleValue := -ToneVolume;
        // floatSampleValue := -floatToneVolume;
      end;
    end
    else
    begin
      // floatSampleValue := 0;
      SampleValue := 0;
    end;

    d^ := SampleValue;

    // if toneHz <> 0 then begin
    //   d^ := round(4000.0 * sin(2 * PI * sineIdx));
    //     incr := toneHz / 22050.0;
    //   sineIdx := sineIdx + incr;
    //   if (sineIdx > 1.0) then sineIdx := sineIdx - 1.0;

    // end else begin

    //   d^ := 0;
    // end;


    Inc(d, 1);

    Inc(RunningSampleIndex);
    Inc(soundTick);

    { TODO: This should not be hardcoded to 200 }
    { 0.006872852233677 sec / sample }
    if (soundTick > 151) then
    begin
      soundTick := 0;
      SND_Update;
    end;
  end;
end;

procedure SND_PlaySound(snd: PSoundEffect);
begin
  if snd = nil then Exit;
  //Exit;
  curSound := snd;
  curSoundSample := -1;
end;

function SND_IsPlaying: boolean;
begin
  SND_IsPlaying := curSound <> nil;
end;

procedure SND_Init;
var
  testSound: TSound;
begin
  sineIdx := 0;
  curSound := nil;
  soundTick := 0;

  InitAudioDevice;
  SetAudioStreamBufferSizeDefault(4096);

  didInit := IsAudioDeviceReady;

  if didInit then
  begin
    writeln('SND_Init: Audio device ready.');

    stream := LoadAudioStream(22050, 16, 1);

    writeln(stream.sampleRate);
    writeln(stream.sampleSize);
    writeln(stream.channels);

    // testSound := LoadSound('Untitled.wav');
    // PlaySound(testSound);
    SetAudioStreamVolume(stream, 1.0);

    if not IsAudioStreamReady(stream) then
    begin
      writeln('not ready?');
    end;


    SetAudioStreamCallback(stream, TAudioCallback(AudioInputCallback));
    PlayAudioStream(stream);
  end
  else
  begin
    writeln('SND_Init: Didn''t init audio.');
  end;

end;

begin
end.
