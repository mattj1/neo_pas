program GFXX_TB;
{$N+}
{$G+}
uses GFXCom, GFXX, Image, crt;

type star = record
	x, y, z: Real;
end;

var f: file;
var img: Image_t;
var i, j: integer;
var pal: Palette;
var x, y, x2, y2: longint;
var stars: array[0..125] of star;

begin

	Assign(f, 'tile.raw');
  	Reset(f, 1);
		Image_LoadRaw(f, img);
	Close(f);

	GFXX_Init;
	GFX_LoadPalette('playpal.pal', pal);
	GFX_SetPalette(pal);

	for i := 0 to 125 do begin
		stars[i].x := - Random(400);
		stars[i].y := - Random(400);

		stars[i].x := stars[i].x + 200;
		stars[i].y := stars[i].y + 200;

		stars[i].z := Random(500) + 1;
	end;


    for i := 10 to 1000 do begin
       {GFX_FillColor(0);}

      for y := 0 to 14 do begin
    		for x := 0 to 19 do begin
   				DrawSpriteOpaqueFast(x * 16,  y * 16, img);
   			end;
      end;

    	for j := 0 to 125 do begin
    		stars[j].z := stars[j].z - 2.2;
    		if stars[j].z <= 0 then stars[j].z := stars[j].z + 500;

    		if stars[j].z < 2 then continue;

    		x := Round(stars[j].x * 20 / stars[j].z);
    		y := Round(stars[j].y * 20 / stars[j].z);

    		x2 := Round(stars[j].x * 20 / (stars[j].z + 2));
    		y2 := Round(stars[j].y * 20 / (stars[j].z + 2));

    		inc(x, 160);
    		inc(y, 120);

    		inc(x2, 160);
    		inc(y2, 120);
    		if (x < 0) or (x >= 320) or (y < 0) or (y >= 240) then continue;

    		GFX_Line(x, y, x2, y2, 32 + (Round(stars[j].z) shr 4));
    	end;

{ + 30 + Round(20.0 * sin(2 * i * 3.141/180.0)}

      GFXX_SwapBuffers;

      if KeyPressed then break;
    end;
  
	readln;

	Image_Free(img);
	GFXX_Close;
end.