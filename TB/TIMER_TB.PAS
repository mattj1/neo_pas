uses dos, crt, timer;
   
var
  h, m, s, sec100: word;

var
  t: longint;
begin

     Timer_Init;

     {writeln('test...'); delay(1000); writeln('test 2...'); delay(1000);}

     repeat
           getTime(h, m, s, sec100);
           writeln(time, ' ', m, ' ', s, ' ', sec100);
           delay(100);
     until KeyPressed;
     readln;

     Timer_Close;
   {  writeln('test...'); delay(1000); writeln('test 2...'); delay(1000);}
       NoSound;
end.
