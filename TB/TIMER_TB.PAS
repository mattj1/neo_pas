program timer_tb;

uses dos, crt, timer2, gfx;
   


var
  t: longint;

procedure tb1;
    var
  h, m, s, sec100: word;
    begin
     repeat
           getTime(h, m, s, sec100);
           writeln(time, ' ', m, ' ', s, ' ', sec100);
           delay(10);
     until KeyPressed;
end;

procedure tb2;
    var t: longint;
    begin
     repeat
            t := time;

           
           WaitForRetrace;
           WaitForRetrace2;
           WaitForRetrace;
           WaitForRetrace2;
           writeln(time, ' ', time - t);
     until KeyPressed;

    end;
begin

     Timer_Init;

     {writeln('test...'); delay(1000); writeln('test 2...'); delay(1000);}

     tb2;

     readln;

     Timer_Close;
   {  writeln('test...'); delay(1000); writeln('test 2...'); delay(1000);}
       NoSound;
end.
