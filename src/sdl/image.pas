{ Image - SDL }

unit Image;

interface

uses Engine;

{$I image.inc}

implementation

uses
  sys, SDL2, SDL2_Image, GFX_SDL_Core;

function Image_Load(filename: string): pimage_t;

var
  img: pimage_t;
  fn: PChar;
var
  loadedSurface: PSDL_Surface;
begin

  loadedSurface := IMG_Load(StrToPChar(filename));

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
  SDL_SetColorKey(img^.surface, SDL_RLEACCEL, $000000);

  Image_Load := img;

end;

end.
