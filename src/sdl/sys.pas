unit Sys;

{$mode ObjFPC}{$H-}

interface

uses SDL2, GFX_SDL, Event, Engine;

type TFile = record
  _file: file;
end;

{$I sys.inc}

procedure ConsoleLog(s: string);

implementation

uses Text;

procedure ConsoleLog(s: string);
begin
  writeln(s);
end;

function File_Open(fileName: string; var _file: TFile): boolean;
begin
     Assign(_file._file, fileName);
     Reset(_file._file, 1);
     File_Open := true;
end;

procedure File_Close(var _file: TFile);
begin
  System.Close(_file._file);
end;

procedure File_BlockRead(_file: TFile; var buf; size: integer);
begin
     BlockRead(_file._file, buf, size);
end;

procedure File_Seek(_file: TFile;Pos:Int64);
begin
     Seek(_file._file, Pos);
end;

function File_Pos(_file: TFile): Int64;
begin
     File_Pos := FilePos(_file._file);
end;
function File_EOF(_file: TFile): boolean;
begin
     File_EOF := EOF(_file._file);
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

end.
