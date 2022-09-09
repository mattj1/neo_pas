unit Monster;

{$mode tp}{$H+}

interface

uses
  Classes, SysUtils;

procedure Monster_Stuff(Data: Pointer);

implementation

procedure Monster_Stuff(Data: Pointer);
begin
  writeln('Monster_Stuff');
end;

end.

