{ Image - SDL }

unit Image;

{$mode ObjFPC}{$H+}

interface

uses
  Engine;



{$I image.inc}

implementation

procedure Image_Load_Impl(filename: PChar; img: Pointer); external;

function Image_Load(filename: string): pimage_t;

var
  img: pimage_t;

begin

  GetMem(img, SizeOf(image_t));
  // writeln('Image_Load: ', filename);

  Image_Load_Impl(PChar(filename), img);

  Image_Load := img;


end;

end.
