procedure SYS_PollEvents;
procedure SYS_InitGraphicsDriver(driverType: integer);

function File_Open(fileName: string; var _file: TFile): boolean;
procedure File_Close(var _file: TFile);
procedure File_BlockRead(_file: TFile; var buf; size: integer);
procedure File_Seek(_file: TFile;Pos:Int64);
function File_Pos(_file: TFile): Int64;

function File_EOF(_file: TFile): boolean;

