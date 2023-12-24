unit Sys;

{$H+}

interface

uses Event, Engine, raylib;

{$I sys.inc}

// procedure FillChar(var x;count : {$ifdef FILLCHAR_HAS_SIZEUINT_COUNT}SizeUInt{$else}SizeInt{$endif};value : byte );

implementation

uses Text;

// procedure FillChar(var x;count : {$ifdef FILLCHAR_HAS_SIZEUINT_COUNT}SizeUInt{$else}SizeInt{$endif};value : byte );
// begin
// end;

function to_scancode(code: integer): scanCode;
begin
  case (code) of
    // SDLK_RETURN: Result := kEnter;
    265: to_scancode := kUp;
    264: to_scancode := kDn;
    263: to_scancode := kLf;
    262: to_scancode := kRt;

    256: to_scancode := kEsc;
    257: to_scanCode := kEnter;
    259: to_scancode := kBack;


    32: to_scancode := kSpace;
    49: to_scancode := k1;
    50: to_scancode := k2;

    // SDLK_W: Result := kW;
    // SDLK_E: Result := kE;
    // SDLK_I: Result := kI;
    // SDLK_P: Result := kP;
    65: to_scancode := kA;
    // SDLK_S: Result := kS;
    68: to_scancode := kD;
    69: to_scancode := kE;
    // SDLK_L: Result := kL;
    // SDLK_Z: Result := kZ;
    // SDLK_1: Result := k1;
    // SDLK_2: Result := k2;
    73: to_scancode := kI;
    80: to_scancode := kP;
    81: to_scancode := kQ;
    83: to_scancode := kS;
    87: to_scancode := kW;
    96: to_scancode := kTilde;


      // SDLK_BACKSPACE: Result := kBack;

    else
      writeln('did not translate raylib scan code ', code);
      to_scancode := kNone;
  end;
end;

function from_scancode(code: scanCode): integer;
begin
  case (code) of
    k1: from_scancode := 49;
    k2: from_scancode := 50;
    kEnter: from_scancode := 257;
    kBack: from_scancode := 259;
    kUp: from_scancode := 265;
    kDn: from_scancode := 264;
    kLf: from_scancode := 263;
    kRt: from_scancode := 262;
    kSpace: from_scancode := 32;
    kA: from_scancode := 65;
    kD: from_scancode := 68;
    kE: from_scancode := 69;
    kI: from_scancode := 73;
    kP: from_scancode := 80;
    kQ: from_scancode := 81;
    kS: from_scancode := 83;
    kW: from_scancode := 87;
    kTilde: from_scancode := 96;

    kEsc: from_scancode := 256;

    else
      from_scancode := 0;
  end;
end;

procedure SYS_PollEvents;

var
  sc: scanCode;
  k: integer;
begin
  // Check for released keys - TODO, use set features?
  for sc := kNone to kF12 do
  begin
    if (sc in keys) then
    begin
      k := from_scancode(sc);
      if (k <> 0) and not IsKeyDown(from_scancode(sc)) then
      begin
        // writeln('key released ', Ord(sc));
        Event_Add(SE_KEYUP, Ord(sc), 0);
      end;
    end;
  end;

  repeat
    k := GetKeyPressed;
    if k = 0 then break;

    sc := to_scancode(k);
    if sc <> kNone then
    begin
      Event_Add(SE_KEYDOWN, Ord(sc), 0);
      // writeln('key pressed: ', Ord(sc));
    end;
  until False;

  repeat
    k := GetCharPressed;
    if k = 0 then break;

    Event_Add(SE_KEYCHAR, 0, k);
{    writeln('SE_KEYCHAR ', Chr(k)); }
  until False;

  // prevKeys := keys;
end;

procedure SYS_InitGraphicsDriver(driverType: integer);
begin

end;


procedure Timer_Init;
begin

end;

procedure Timer_Close;
begin

end;

function Timer_GetTicks: longint;
begin
  Timer_GetTicks := round(GetTime * 1000);
end;

procedure emscripten_sleep(t: longint); external;

procedure Timer_Delay(ms: longint);
begin
  // SDL_Delay(ms);
  // writeln('Timer_Delay ', ms);
  // emscripten_sleep(ms);
end;


end.
