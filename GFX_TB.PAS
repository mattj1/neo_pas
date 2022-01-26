uses crt, gfx, image, common;
var angle: Real;
var i, j, k, col: integer;
var pal: Palette;
var alpha: integer;
var img: Image_t;
var img2: Image_t;
var bp: byte_ptr;
var msg: string;
var lsfr, start_state, bit: longint;
begin
     msg := 'Hello from Pascal!!!';
     LoadPalette('playpal.pal', pal);
     LoadBMP('test.bmp', img);
     GFX.SetPalette(pal);

     Image_New(img2, 16, 16);
     bp := img2.data;


     for i := 0 to 255 do
     begin
       bp^ := 255; inc(bp);
     end;

     bp := img2.data;

     for j := 0 to 15 do begin
        for i := 0 to 15 do begin

           if (i = 0) or (j = 0) or (i = 15) or (j = 15) then
           begin
            bp^ := 1;
           end else begin
           bp^ := 96 + i;
            end;

            if i = j then bp^ := 255;

            inc(bp);
        end;
     end;


   GFX.InitGFX;
   {GFX.double_buffer := false;}

   GFX.SetPalette(pal);

   DirectVideo:=false;

   alpha := 0;
        FillColor(0);

 for i := 0 to 720 do begin
 {       FillColor(0);}

     angle := i;

   for j := 0 to 19 do
   begin
       for k := 0 to 19 do begin
           col := 32;
           if ((j + k) mod 2 = 0) then col := 64;

           FillRect(k * 16, j * 10, 17, 11, col);
       end;
   end;

  { DrawSprite( 20, 32 - i mod 60, img);}


   for j := 0 to 15 do begin
   angle := ((i + j*5) * 4 * 3.141/180);

 {
   DrawSpriteAlpha( round(140 + cos(angle) * 48),
               round(72 + sin(angle) * 48), j, img2);


   DrawSpriteAlpha(20 + j * 18, 80, j, img2);
}

   end;

   for j := 0 to Length(msg)-1 do begin
       k := ord(msg[j+1]);
           DrawSpriteAlpha(320 - (i) + j * 15,
       100 + round(10 * sin(20 * (i * 0.2 + j) * 3.141/180)),
                           8 * (k mod 16),
                           8 * (k div 16),
                           8, 8,

                           round(7 + 8 * cos(3 * i * 3.141/180)),

                           img);

   end;
(*
      lsfr := 1;
      start_state := lsfr;

   for j := 0 to i * 32 do begin
       bit := lsfr and 1;
       lsfr := lsfr shr 1;
       if bit <> 0 then begin
          lsfr := lsfr xor 777; {B400;}
       end;
        GFX.SetPixel((lsfr mod 32), (lsfr div 32) mod 32, 4);

        if lsfr = start_state then begin
        end
   end;
*)

   SwapBuffers;
   if KeyPressed then break;

 end;

   writeln('Test');
   readln;
   GFX.CloseGFX;
end.
