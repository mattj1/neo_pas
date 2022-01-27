program GFXX_TB;

uses GFXCom, GFXX, Image;

var f: file;
var img: Image_t;
var i: integer;
var pal: Palette;
begin
	GFXX_Init;
	GFX_LoadPalette('playpal.pal', pal);
	GFX_SetPalette(pal);

	Assign(f, 'img.raw');
  	Reset(f, 1);
	Image_LoadRaw(f, 64, 64, img);
	Close(f);

    for i := 10 to 70 do begin
      GFX_FillColor(0);
      DrawSprite(i, 15, img);
      GFXX_SwapBuffers;
    end;
  
	readln;

	Image_Free(img);
	GFXX_Close;
end.