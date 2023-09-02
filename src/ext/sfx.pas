
Unit sfx;

Interface

Uses engine;

Type TSoundEffect = Record
  data: pIntArray;
  size: integer;
  length: integer;
End;

Type PSoundEffect = ^TSoundEffect;

Procedure SND_PlaySound(snd: PSoundEffect);
Function SND_LoadSoundEffect(filename: String): PSoundEffect;
Procedure SND_Init;

Implementation

Uses raylib, math, datafile;

Var 
  didInit: boolean;
  stream: TAudioStream;
  sineIdx: real;
  curFreq: integer;
  curSound: PSoundEffect;
  curSoundSample: integer;
  SoundTick: uint32;
  RunningSampleIndex: uint32;



Const frequency: real = 440.0;

Procedure SND_Update;

Begin
  If curSound <> Nil Then
    Begin
      Inc(curSoundSample, 1);

      If curSoundSample = curSound^.length - 1 Then
        Begin
          curSound := Nil;
          curFreq := 0;
        End
      Else
        Begin
          curFreq := curSound^.Data^[curSoundSample];
        End;
    End;
End;

Function SND_AllocSoundEffect(length: integer): PSoundEffect;

Var 
  soundEffect: PSoundEffect;
Begin
  GetMem(soundEffect, sizeof(TSoundEffect));
  GetMem(soundEffect^.Data, length * sizeof(integer));

  { Allocated size }
  soundEffect^.size := length;

  { Length of sound. Shouldn't exceed size. }
  soundEffect^.length := length;

  SND_AllocSoundEffect := soundEffect;
End;

Procedure SND_FreeSoundEffect(soundEffect: PSoundEffect);
Begin
  FreeMem(soundEffect^.Data, soundEffect^.size);
  FreeMem(soundEffect, sizeof(TSoundEffect));
End;

Function SND_LoadSoundEffect(filename: String): PSoundEffect;

Var 
  f: file;
  length: integer;
  soundEffect: PSoundEffect;
Begin
  SND_LoadSoundEffect := Nil;
  Datafile_Open(filename, f, 1);

  BlockRead(f, length, 2);
  writeln(' sound effect len in samples: ', length);

  soundEffect := SND_AllocSoundEffect(length);
  BlockRead(f, soundEffect^.Data^, length * 2);

  Datafile_Close(f);

  SND_LoadSoundEffect := soundEffect;
End;


Procedure AudioInputCallback(bufferData: Pointer; frames: LongWord);

Var audioFrequency, incr: real;
  d: ^integer;
  i: LongWord;
  toneHz, toneVolume: uint16;
  squareWavePeriod: uint32;
  halfSquareWavePeriod: uint32;
  SampleValue: integer;
Begin
  toneHz := curFreq;

  // WriteLn('AudioInputCallback ', frames);
  audioFrequency := 440.0;
  toneVolume := 3000;

  d := bufferData;

  For i := 1 To frames Do
    Begin

      If toneHz <> 0 Then
        Begin
          squareWavePeriod := 22050 Div toneHz;
          halfSquareWavePeriod := squareWavePeriod Div 2;


          If ((RunningSampleIndex Div HalfSquareWavePeriod) Mod 2) = 1 Then
            Begin
              SampleValue := ToneVolume;
              // floatSampleValue := floatToneVolume;
            End
          Else
            Begin
              SampleValue := -ToneVolume;
              // floatSampleValue := -floatToneVolume;

            End;
        End
      Else
        Begin
          // floatSampleValue := 0;
          SampleValue := 0;
        End;



      d^ := SampleValue;

      // if toneHz <> 0 then begin
      //   d^ := round(4000.0 * sin(2 * PI * sineIdx));
      //     incr := toneHz / 22050.0;
      //   sineIdx := sineIdx + incr;
      //   if (sineIdx > 1.0) then sineIdx := sineIdx - 1.0;

      // end else begin

      //   d^ := 0;
      // end;


      inc(d, 1);

      Inc(RunningSampleIndex);
      Inc(soundTick);

    { TODO: This should not be hardcoded to 200 }
    { 0.006872852233677 sec / sample }
      If (soundTick > 151) Then
        Begin
          soundTick := 0;
          SND_Update;
        End;
    End;
End;

Procedure SND_PlaySound(snd: PSoundEffect);
Begin
  If snd = Nil Then Exit;
  //Exit;
  curSound := snd;
  curSoundSample := -1;
End;

Function SND_IsPlaying: boolean;
Begin
  SND_IsPlaying := curSound <> Nil;
End;

Procedure SND_Init;
Begin
  sineIdx := 0;
  curSound := Nil;
  soundTick := 0;
  InitAudioDevice;

  didInit := IsAudioDeviceReady;

  If didInit Then
    Begin
      writeln('SND_Init: Audio device ready.');
      stream := LoadAudioStream(22050, 16, 1);
      writeln(stream.sampleRate);
      writeln(stream.sampleSize);
      writeln(stream.channels);

      SetAudioStreamCallback(stream, TAudioCallback(AudioInputCallback));
      PlayAudioStream(stream);
    End
  Else
    Begin
      writeln('Didn''t init audio.');
    End;

End;

Begin
End.
