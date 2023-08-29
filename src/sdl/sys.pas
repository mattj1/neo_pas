unit Sys;

{$mode ObjFPC}

interface

{$I sys.inc}

procedure ConsoleLog(s: string);

implementation

uses Engine, Event, GFX_SDL, Text, SDL2;

procedure ConsoleLog(s: string);
begin
  writeln(s);
end;

function sdl_to_scancode(code: TSDL_KeyCode): scanCode;
begin
  case (code) of
    SDLK_RETURN: Result := kEnter;
    SDLK_UP: Result := kUp;
    SDLK_DOWN: Result := kDn;
    SDLK_LEFT: Result := kLf;
    SDLK_RIGHT: Result := kRt;
    SDLK_SPACE: Result := kSpace;

    SDLK_ESCAPE: Result := kEsc;
    SDLK_Q: Result := kQ;
    SDLK_W: Result := kW;
    SDLK_E: Result := kE;
    SDLK_I: Result := kI;
    SDLK_P: Result := kP;
    SDLK_A: Result := kA;
    SDLK_S: Result := kS;
    SDLK_D: Result := kD;
    SDLK_L: Result := kL;
    SDLK_Z: Result := kZ;
    SDLK_1: Result := k1;
    SDLK_2: Result := k2;

    SDLK_BACKSPACE: Result := kBack;

    else
      writeln('did not translate SDL scan code ', code);
      Result := kNone;
  end;
end;

procedure SYS_PollEvents;

var
  event: TSDL_Event;

var
  sc: scanCode;

begin
  while SDL_PollEvent(@event) <> 0 do
  begin

    //writeln('event ', event.type_);
    case (event.type_) of
      SDL_WINDOWEVENT:

      begin
        case (event.window.event) of
          SDL_WINDOWEVENT_CLOSE:

          begin
            shouldQuit := True;

          end;

        end;

      end;
      SDL_KEYDOWN:
      begin

        sc := sdl_to_scancode(event.key.keysym.sym);

        if (sc <> kNone) then
        begin
          if event.key._repeat = 0 then
          begin
            Event_Add(SE_KEYDOWN, Ord(sc), 0);
            { writeln('Adding SE_KEYDOWN ', Ord(sc)); }
          end;

          { We want key repeat for these keys }
          if (sc = kBack) or (sc = kEnter) or (sc = kEsc) then
          begin
            Event_Add(SE_KEYCHAR, ord(sc), 0);
          end;
        end;


        if event.key.keysym.sym = SDLK_F4 then
        begin
          Text_ToggleFullscreen;
        end;

        //writeln('key down... ', Ord(sc));
      end;

      SDL_KEYUP:
      begin
        sc := sdl_to_scancode(event.key.keysym.sym);

        if sc <> kNone then
        begin
          Event_Add(SE_KEYUP, Ord(sc), 0);
        end;
        //writeln('key up... ', Ord(sc));
      end;
      SDL_TEXTINPUT:
      begin
        {writeln('Adding SE_KEYCHAR ', event.Text.Text[0], ' ',
          Ord(event.Text.Text[0]));}
        Event_Add(SE_KEYCHAR, 0, Ord(event.Text.Text[0]));
      end;

      SDL_QUITEV:
      begin
        shouldQuit := true;
        SDL_Quit();
      end;
      {else
           writeln('Unhandled SDL event:', event.type_);}
    end;

  end;

  prevKeys := keys;
end;

procedure SYS_InitGraphicsDriver(driverType: integer);
begin
  GFX_SDL.InitDriver;
end;



procedure Timer_Init;
begin

end;

procedure Timer_Close;
begin

end;

function Timer_GetTicks: longint;
begin
  Timer_GetTicks := SDL_GetTicks;
end;

procedure Timer_Delay(ms: longint);
begin
  SDL_Delay(ms);
end;

end.
