unit Sys;

{$mode ObjFPC}{$H+}

interface

uses SDL2, GFX_SDL, Event, common;

{$I sys.inc}

implementation

function sdl_to_scancode(code: TSDL_KeyCode): scanCode;
begin
  case (code) of
    SDLK_RETURN: Result := kEnter;
    SDLK_UP: Result := kUp;
    SDLK_DOWN: Result := kDn;
    SDLK_LEFT: Result := kLf;
    SDLK_RIGHT: Result := kRt;
    SDLK_SPACE: Result := kSpace;
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

        if (sc <> kNone) and (event.key._repeat = 0) then
        begin
          Event_Add(SE_KEYDOWN, Ord(sc));
        end;

        //writeln('key down... ', Ord(sc));
      end;

      SDL_KEYUP:
      begin
        sc := sdl_to_scancode(event.key.keysym.sym);

        if sc <> kNone then
        begin
          Event_Add(SE_KEYUP, Ord(sc));
        end;
        //writeln('key up... ', Ord(sc));
      end;
    end;

  end;

end;

procedure SYS_InitGraphicsDriver(driverType: integer);
begin
  GFX_SDL.InitDriver;
end;

end.
