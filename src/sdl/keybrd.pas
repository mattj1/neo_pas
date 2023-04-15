unit Keybrd;

{$mode ObjFPC}{$H+}

interface

uses
  SDL2;

{$I keybrd.inc}
implementation

procedure Init;
begin
     SDL_StartTextInput;
end;



procedure Close;
begin

     SDL_StopTextInput;
end;

end.
