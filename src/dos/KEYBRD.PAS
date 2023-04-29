unit keybrd;

interface
uses Engine, crt, dos, event;

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
 keyChar, scanCode1: byte;
   head : Word Absolute $40 : $1A;
  tail : Word Absolute $40 : $1C;
begin
     keyChar := 0;
     scanCode1 := 0;
     asm
     in al, $60
     mov b, al
     and al, $7F
     mov k, al
     pushF
     call [oldKeyInt]

        { Check if key available }
        mov ax, $0100
        int 16h
        jz @no_key

        mov ax, $0000
        int 16h
        mov scanCode1, ah
        mov keyChar, al       
        
@no_key:
     end;

   { writeln('Keyboard: got ', ord(k), ' ', b, ' ', (b and 128) = 0,  Char(mem[$40 : head])); }

    
     if (b and $80) = 0 then begin
          Event_Add(SE_KEYDOWN, ord(k), 0);
          
          if keyChar <> 0 then begin
               Event_Add(SE_KEYCHAR, 0, keyChar);
          end;

          {Include(com_kb.keys, k);}
     end else begin
          Event_Add(SE_KEYUP, ord(k), 0); 
          {Exclude(com_kb.keys, k);}
     end;

      memW[$40 : $1A] := memW[$40 : $1C];
end;


procedure Init;
var i: integer;
begin
     { writeln('--- Keyboard Init ---'); }
     engine.keys := [];

     getIntVec(9, oldKeyInt);
     setIntVec(9, @keyISR);
end;

procedure Close;
begin
     setIntVec(9, oldKeyInt);
end;

begin
end.
