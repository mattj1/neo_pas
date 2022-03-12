unit com_kb;

interface

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

implementation

function I_IsKeyDown(sc: scanCode) : boolean;
begin
     I_IsKeyDown := sc in keys;
end;

function I_WasKeyReleased(sc: scanCode) : boolean;
begin
     I_WasKeyReleased := (not (sc in keys)) and (sc in prevKeys);
end;

end.
