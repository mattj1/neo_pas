unit engine;


interface

{$ifdef fpc}
uses SDL2;
{$H-}
{$else}
{$endif}
type
  byte_ptr = ^byte;
  integer_ptr = ^integer;
  dIntArray = array [0..32760] of integer;
  pIntArray = ^dIntArray;

type
  image_t = record
    Width: word;
    Height: word;
{$ifdef fpc}
    surface: PSDL_Surface;
    texture: PSDL_Texture;
{$else}
    Data: byte_ptr;
{$endif}

  end;

  Palette = record
{$ifdef fpc}
    sdlPalette: PSDL_Palette;
{$else}
    c: array[0..255] of array[0..2] of byte;
{$endif}
  end;

type
  R_FillColorProc = procedure(c: byte);
  R_FillRectProc = procedure(x, y, w, h: integer; color: byte);
  R_DrawSubImageTransparentProc = procedure(var img: image_t;
    dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
  R_DrawSubImageOpaqueProc = procedure(var img: image_t;
    dstX, dstY, srcX, srcY, srcWidth, srcHeight: integer);
  R_DrawSpriteProc = procedure(x, y: integer; var img: image_t);
  R_AllocPaletteProc = procedure(var pal: Palette);

  R_LoadPaletteProc = procedure(filename: string; var pal: Palette);
  R_SetPaletteColorProc = procedure(index: integer; r, g, b: byte);
  R_SetPaletteProc = procedure(var pal: Palette);

  R_SwapBuffersProc = procedure;
  R_InitProc = procedure;
  R_CloseProc = procedure;


{ Keyboard --------------------------------------------------------- }

{ Credit: http://swag.outpostbbs.net/KEYBOARD/0010.PAS.html }

type
  scanCode = (
    kNone, kEsc, k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, kMinus, kEqual,
    kBack, kTab, kQ, kW, kE, kR, kT, kY, kU, kI, kO, kP, kLBracket,
    kRBracket, kEnter, kCtrl, kA, kS, kD, kF, kG, kH, kJ, kK, kL, kColon,
    kQuote, kTilde, kLShift, kBackSlash, kZ, kX, kC, kV, kB, kN, kM, kComma,
    kPeriod, kSlash, kRShift, kPadStar, kAlt, kSpace, kCaps, kF1, kF2, kF3,
    kF4, kF5, kF6, kF7, kF8, kF9, kF10, kNum, kScroll, kHome, kUp, kPgUp,
    kPadMinus, kLf, kPad5, kRt, kPadPlus, kend, kDn, kPgDn, kIns, kDel,
    kSysReq, kUnknown55, kUnknown56, kF11, kF12);

const
  kPad7 = kHome;
  kPad8 = kUp;
  kPad9 = kPgUp;
  kPad4 = kLf;
  kPad6 = kRt;
  kPad1 = kend;
  kPad2 = kDn;
  kPad3 = kPgDn;
  letters = [kQ..kP, kA..kL, kZ..kM];
  numbers = [k1..k0, kPad1..kPad3, kPad4..kPad6, kPad7..kPad9];
  FunctionKeys = [kF1..kF10, kF11..kF12];
  keyPad = [kPadStar, kNum..kDel];

var
  keys: set of scanCode;
  prevKeys: set of ScanCode;
  lastKeyDown: scanCode;


function I_IsKeyDown(sc: scanCode) : boolean;
function I_WasKeyReleased(sc: scanCode) : boolean;
function I_WasKeyPressed(sc: scanCode) : boolean;

function itoa(i: integer): string;

{ Video ----------------------------------------------------------- }

var
  R_FillRect: R_FillRectProc;
  R_FillColor: R_FillColorProc;
  R_DrawSubImageTransparent: R_DrawSubImageTransparentProc;
  R_DrawSubImageOpaque: R_DrawSubImageOpaqueProc;
  R_DrawSprite: R_DrawSpriteProc;
  R_AllocPalette: R_AllocPaletteProc;
  R_LoadPalette: R_LoadPaletteProc;
  R_SetPaletteColor: R_SetPaletteColorProc;
  R_SetPalette: R_SetPaletteProc;
  R_SwapBuffers: R_SwapBuffersProc;
  R_Init: R_InitProc;
  R_Close: R_CloseProc;


var
  shouldQuit: boolean;



implementation

function I_IsKeyDown(sc: scanCode) : boolean;
begin
     I_IsKeyDown := sc in keys;
end;

function I_WasKeyReleased(sc: scanCode) : boolean;
begin
     I_WasKeyReleased := (not (sc in keys)) and (sc in prevKeys);
end;

function I_WasKeyPressed(sc: scanCode) : boolean;
begin
     I_WasKeyPressed := (sc in keys) and (not(sc in prevKeys));
end;

function itoa(i: integer): string;
var s: string;
begin
  str(i, s);
  itoa := s;
end;

begin
end.
