{ Image - DOS }

unit image;
interface
uses common;


type
  BITMAPFILEHEADER = record
    bfType: word;
    bfSize: longint;
    bfReserved1: word;
    bfReserved2: word;
    bfOffBits: longint;
  end;

  BITMAPINFOHEADER = record
    biSize: longint;
    biWidth: longint;
    biHeight: longint;
    biPlanes: word;
    biBitCount: word;
    biCompression: longint;
    biSizeImage: longint;
    biXPelsPerMeter: longint;
    biYPelsPerMeter: longint;
    biClrUsed: longint;
    biClrImportant: longint;
  end;

  BITMAPPALENTRY = record
    c: array[0..3] of byte;
  end;

type
  Image_T = record
    Width: word;
    Height: word;
    data: byte_ptr;
  end;

{$I image.inc}

procedure LoadBMP(filename: string; var image: Image_t);
procedure Image_New(var image: image_t; width, height: integer);
procedure Image_Free(var image: Image_t);
procedure Image_LoadRaw(var f: file; var image: Image_T);

implementation

procedure LoadBMP(filename: string; var image: Image_T);
var
  f: file;
var
  bfh: BITMAPFILEHEADER;
var
  bih: BITMAPINFOHEADER;
var
  pe: BITMAPPALENTRY;
var
  i, j: integer;
var
  p: byte_ptr;
begin
  Assign(f, filename);
  Reset(f, 1);
  BlockRead(f, bfh, sizeof(BITMAPFILEHEADER));
  BlockRead(f, bih, sizeof(BITMAPINFOHEADER));

  writeln(bfh.bfSize, ' ', bfh.bfType, ' ', bfh.bfOffBits);
  writeln(bih.biSize, ' ', bih.biWidth, ' ', bih.biHeight);
 
  Image_New(image, bih.biWidth, bih.biHeight);

  {biSize must be 40}

  for i := 0 to 255 do
  begin
    BlockRead(f, pe, sizeof(BITMAPPALENTRY));
         
    if i < 10 then writeln(pe.c[0], ' ', pe.c[1], ' ', pe.c[2], ' ', pe.c[3]);

      end;


  for j := 0 to image.Height - 1 do
  begin
    writeln('load ', j, ' ', FilePos(f), ' read ', bih.biWidth);
    p := image.Data;
    Inc(p, (bih.biHeight - 1 - j) * bih.biWidth);
    BlockRead(f, p^, bih.biWidth);
  end;

  Close(f);
end;


function Image_Load(filename: string): pimage_t;

var
  img: pimage_t;
begin

  GetMem(img, SizeOf(image_t));

  LoadBMP(filename, img^);

  Image_Load := img;
end;


procedure Image_LoadRaw(var f: file; var image: Image_T);
  var width, height: integer; 
begin
  BlockRead(f, width, sizeof(integer));
  BlockRead(f, height, sizeof(integer));

  Image_New(image, width, height);

  BlockRead(f, image.data^, width * height);
end;

procedure Image_New(var image: image_t; width, height: integer);
begin
  image.Width := width;
  image.Height := height;

  writeln('allocate ', width, ' ', height);

  GetMem(image.Data, image.Width * image.Height);
end;

procedure Image_Free(var image: Image_T);
begin
  FreeMem(image.Data, image.Width * image.Height);
end;

begin
end.
