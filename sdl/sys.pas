unit Sys;

{$mode ObjFPC}{$H+}

interface

uses SDL2, com_kb;

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
    else
      writeln('did not translate SDL scan code ', code);
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
      SDL_KEYDOWN:
      begin
        sc := sdl_to_scancode(event.key.keysym.sym);
        com_kb.keys := com_kb.keys + [sc];
        //writeln('key down... ', Ord(sc));
      end;

      SDL_KEYUP:
      begin
        sc := sdl_to_scancode(event.key.keysym.sym);
        com_kb.keys := com_kb.keys - [sc];
        //writeln('key up... ', Ord(sc));
      end;
    end;

  end;

end;

end.
