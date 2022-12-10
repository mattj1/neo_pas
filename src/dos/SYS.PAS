unit Sys;

interface
uses GFX13, GFXX;

{$I sys.inc}

implementation

procedure SYS_PollEvents;
begin
end;


procedure SYS_InitGraphicsDriver(driverType: integer);
begin
     case driverType of
      0: GFX13.InitDriver;
      1: GFXX.InitDriver;
     end;
end;  

end.
