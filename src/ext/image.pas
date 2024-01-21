{ Image - SDL }

unit Image;

{$H+}

interface

uses
  Engine;



  {$I image.inc}


function Image_LoadFromMemory(fileType: PChar; Data: Pointer;
  dataSize: integer): pimage_t;

implementation

uses raylib, sys;

function _ProcessRaylibImage(var raylibImage: TImage): pimage_t;
var
  img: pimage_t;
begin
  _ProcessRaylibImage := nil;
  if not assigned(raylibImage.data) then begin

    writeln('Did not load Raylib image properly');
    Exit;
  end;
  GetMem(img, SizeOf(image_t));
  img^.Width := raylibImage.Width;
  img^.Height := raylibImage.Height;

  GetMem(img^.Data, sizeof(TImage));

  Move(raylibImage, img^.Data^, sizeof(TImage));
  _ProcessRaylibImage := img;
end;

function Image_Load(filename: string): pimage_t;
var
  i: TImage;
begin
  i := LoadImage(StrToPChar(filename));
  Image_Load := _ProcessRaylibImage(i);
end;

function Image_LoadFromMemory(fileType: PChar; Data: Pointer;
  dataSize: integer): pimage_t;
var
  i: TImage;
begin
  i := LoadImageFromMemory(fileType, Data, dataSize);
  Image_LoadFromMemory := _ProcessRaylibImage(i);
end;

begin

end.
