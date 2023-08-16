{ Image - SDL }

unit Image;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  SDL2, SDL2_Image, Engine, GFX_SDL_Core;



{$I image.inc}



implementation

function Image_Load(filename: string): pimage_t;

var
  img: pimage_t;
var
  loadedSurface: PSDL_Surface;
begin

  loadedSurface := IMG_Load(PChar(filename));

  if loadedSurface = nil then
  begin
    writeln('IMG_Load error: ', IMG_GetError);
    SDL_Delay(2000);
    Halt;
  end;

  GetMem(img, SizeOf(image_t));
  img^.surface := loadedSurface;
  img^.Width := loadedSurface^.w;
  img^.Height := loadedSurface^.h;
  img^.texture:=Nil;
  //SDL_SetColorKey(img^.surface, SDL_RLEACCEL, $ffffff);

  Image_Load := img;

end;

end.
