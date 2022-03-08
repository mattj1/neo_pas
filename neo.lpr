program test;

{$F+}

{$ifdef fpc}
        {$I neo_sdl.inc}
{$else}
        {$I neo_dos.inc}
{$endif}

var
  img: pimage_t;
var
  x, lastTime: integer;

  procedure Update(deltaTime: integer);
  begin
    Inc(x, 2);

    {$IfNDef fpc}
    if KeyPressed then Loop_Cancel;
    {$else}
           writeln('Update ', deltaTime);
    {$endif}
  end;

  procedure Draw;
  begin
    DrawSprite(x * 2, x * 2, img^);

  end;

begin
  writeln('--- Init ---');
  GFX_Init;
  Timer_Init;

  img := Image_Load('test2.bmp');

  {$ifdef fpc}
  Loop_SetUpdateProc(@Update);
  Loop_SetDrawProc(@Draw);
  {$else}
  Loop_SetUpdateProc(Update);
  Loop_SetDrawProc(Draw);
  {$endif}

  Loop_Run;

  Timer_Close;
  GFX_Close;

end.
