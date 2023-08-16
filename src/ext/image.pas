{ Image - SDL }

unit Image;

{$mode ObjFPC}{$H+}

interface

uses
  Engine;



{$I image.inc}



implementation

function Image_Load(filename: string): pimage_t;

var
  img: pimage_t;

begin

  Image_Load := img;

end;

end.
