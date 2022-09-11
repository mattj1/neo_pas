modex_old.pas


   subLeft := 4;
   subRight := 64;

     plane := dstX and 3;

     x1 := dstX;

     for p := 0 to 3 do begin   
        word_out(SC_INDEX, MAP_MASK, 1 shl plane);
        
        o := dstY * 80 + (x1 shr 2);

        for y := 0 to 63 do begin
            for x := 0 to 15 do begin
               Blockread(f, c, 1);

               mem[$A000 : o] := c;
               inc(o);
            end;

            inc(o, 80-16);
        end;

        inc(plane);
        plane := plane and 3;
        if plane = 0 then inc(x1, 4);
     end;





{ Working pascal-only sprite draw routine with transparency}

procedure DrawSpriteSub(dstX, dstY: integer; subLeft, subTop, subRight, subBottom: integer; var img: Image_t);
var numCol, numRow, srcPlane, dstPlane, nc0, nc1, nc2: integer;
var x1: integer;
var x, y, p, o: integer;
var bp: byte_ptr;
var numPlanes: integer;
begin
    numRow := (subBottom - subTop);
    dstPlane := dstX and 3;

    x1 := dstX shr 2; {x1 is X pos in plane}

    numPlanes := (subRight - subLeft);
    if numPlanes > 4 then numPlanes := 4;
    if numPlanes = 0 then Exit;

    srcPlane := subLeft and 3;

    for p := 0 to numPlanes - 1 do begin   
    word_out(SC_INDEX, MAP_MASK, 1 shl dstPlane);

    bp := img.data;
    inc(bp, ((img.width shr 2) * img.height) * srcPlane);            {64 >> 2 = 16 per row * 64 rows}

    { Offset into the image plane }
    { should this be srcPlane + p? }
    inc(bp, (subLeft + p) shr 2 + (subTop * (img.width shr 2)));

    { How many columns are we drawing for this plane? }
    { e.g. how many will be memcpy'd for this row? }

    nc0 := ((subLeft + p) shr 2);
    nc1 := ((subRight - srcPlane - 1) shr 2);

    numCol := (nc1 - nc0) + 1;
    {writeln('srcPlane ', srcPlane, 
    ' leftmost ', nc0,
    ' rightmost ', nc1 , 
    ' numCol: ', numCol);
    }
    o := page_offset + dstY * 80 + x1;

    for y := 0 to numRow-1 do begin
      for x := 0 to numCol - 1 do begin

        if bp^ <> 255 then 
          mem[$A000 : o] := bp^;
        inc(o);
        inc(bp);
      end;

      inc(o, 80-numCol);

      inc(bp, 16 - numCol);
    end;

    inc(dstPlane);
    dstPlane := dstPlane and 3;
    if dstPlane = 0 then inc(x1);

    inc(srcPlane);
    srcPlane := srcPlane and 3;
  end;
end;
