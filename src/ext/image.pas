{ Image - SDL }

unit Image;

{$H+}

interface

uses
  Engine;



{$I image.inc}

implementation

uses raylib, sys;

function Image_Load(filename: string): pimage_t;
var
  img: pimage_t;
  i: TImage;

begin

  GetMem(img, SizeOf(image_t));

  i := LoadImage(StrToPChar(filename));
  img^.width := i.width;
  img^.height := i.height;
  
  GetMem(img^.data, sizeof(TImage));
  
  Move(i, img^.data^, sizeof(TImage));

  // writeln('Image_Load: ', filename);

  Image_Load := img;
end;

end.
