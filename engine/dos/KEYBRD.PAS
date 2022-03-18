unit keybrd;

interface
uses common, com_kb, crt, dos, event;

procedure Init;
procedure Close;

implementation

var
  oldKeyInt : Pointer;
  ExitSave: Pointer;
 { keyTable: array [0..127] of boolean;
}
procedure keyISR; interrupt;
var
 k: scanCode;
 b: byte;
begin
     asm
     in al, $60
     mov b, al
     and al, $7F
     mov k, al
     pushF
     call [oldKeyInt]

     end;

     memW[$40 : $1A] := memW[$40 : $1C];

     {writeln('got ', k, ' ', b, ' ', (b and 128) = 0);
}
     {keyTable[k] := ;}
     if (b and $80) = 0 then begin
          Event_Add(SE_KEYDOWN, ord(k));  
          {Include(com_kb.keys, k);}
     end else begin
          Event_Add(SE_KEYUP, ord(k)); 
          {Exclude(com_kb.keys, k);}
     end;
end;


procedure Init;
var i: integer;
begin
     writeln('--- Keyboard Init ---');
     com_kb.keys := [];

     getIntVec(9, oldKeyInt);
     setIntVec(9, @keyISR);
end;

procedure Close;
begin
     setIntVec(9, oldKeyInt);
end;

begin
end.
