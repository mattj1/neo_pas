unit Sys;

{$H+}

interface

uses Event, Engine;

{$I sys.inc}

// procedure FillChar(var x;count : {$ifdef FILLCHAR_HAS_SIZEUINT_COUNT}SizeUInt{$else}SizeInt{$endif};value : byte );

implementation

uses Text;

// procedure FillChar(var x;count : {$ifdef FILLCHAR_HAS_SIZEUINT_COUNT}SizeUInt{$else}SizeInt{$endif};value : byte );
// begin
// end;

function GetKeyPressed: integer; external;
function IsKeyDown(key: longint): boolean; external;

function to_scancode(code: integer): scanCode;
begin
  case (code) of
    // SDLK_RETURN: Result := kEnter;
    265: to_scancode := kUp;
    264: to_scancode := kDn;
    263: to_scancode := kLf;
    262: to_scancode := kRt;
    32: to_scancode := kSpace;

    // SDLK_ESCAPE: Result := kEsc;
    // SDLK_Q: Result := kQ;
    // SDLK_W: Result := kW;
    // SDLK_E: Result := kE;
    // SDLK_I: Result := kI;
    // SDLK_P: Result := kP;
    // SDLK_A: Result := kA;
    // SDLK_S: Result := kS;
    // SDLK_D: Result := kD;
    // SDLK_L: Result := kL;
    // SDLK_Z: Result := kZ;
    // SDLK_1: Result := k1;
    // SDLK_2: Result := k2;

    // SDLK_BACKSPACE: Result := kBack;

    else
      writeln('did not translate raylib scan code ', code);
      to_scancode := kNone;
  end;
end;

function from_scancode(code: scanCode): integer;
begin
     case (code) of
          kUp: from_scancode := 265;
          kDn: from_scancode := 264;
          kLf: from_scancode := 263;
          kRt: from_scancode := 262;
          kSpace: from_scancode := 32;
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
     for sc := kNone to kF12 do begin
          if (sc in keys) then begin
               if not IsKeyDown(from_scancode(sc)) then begin
                    // writeln('key released ', Ord(sc));
                    Event_Add(SE_KEYUP, Ord(sc), 0);
               end;
          end;
     end;

  repeat

     k := GetKeyPressed;
     if k = 0 then Exit;

     sc := to_scancode(k);
     if sc <> kNone then begin
          Event_Add(SE_KEYDOWN, Ord(sc), 0);
          // writeln('key pressed: ', Ord(sc));
     end;



  until False;


     prevKeys := keys;
end;

procedure SYS_InitGraphicsDriver(driverType: integer);
begin

end;

end.
