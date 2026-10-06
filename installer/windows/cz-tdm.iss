; Inno Setup script for the CZ TDM mod (Windows).
; Built by GitHub Actions: iscc /DAppVersion=x.y.z /DSrc=<staging dir> cz-tdm.iss

#ifndef AppVersion
  #define AppVersion "dev"
#endif
#ifndef Src
  #define Src "..\..\stage-windows"
#endif

[Setup]
AppId={{6C1E3E0B-7F43-4C55-9A1D-2E6A3C0B5D11}
AppName=CZ TDM Mod
AppVersion={#AppVersion}
AppPublisher=cz-tdm
DefaultDirName={code:GetCzDir}
DirExistsWarning=no
AppendDefaultDirName=no
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputBaseFilename=CZ-TDM-Setup-{#AppVersion}
OutputDir=..\..\out
Compression=lzma2
SolidCompression=yes
UninstallDisplayName=CZ TDM Mod
WizardStyle=modern
UsePreviousAppDir=yes

[Messages]
SelectDirLabel3=Select your Half-Life folder (the one that contains the "czero" folder).%nIt is usually ...\Steam\steamapps\common\Half-Life
SelectDirBrowseLabel=Setup found the folder below. If it is wrong, click Browse.

[Tasks]
Name: desktopicons; Description: "Create desktop shortcuts (CZ TDM / CZ Normal)"

[Files]
Source: "{#Src}\czero\dlls\cstdm.dll"; DestDir: "{app}\czero\dlls"; Flags: ignoreversion
Source: "{#Src}\czero\tdm.cfg"; DestDir: "{app}\czero"; Flags: ignoreversion
Source: "{#Src}\czero\sound\tdm\*.wav"; DestDir: "{app}\czero\sound\tdm"; Flags: ignoreversion
Source: "{#Src}\czero\tdm-mod\*"; DestDir: "{app}\czero\tdm-mod"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\CZ TDM"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" tdm"; IconFilename: "{app}\czero\game.ico"; Comment: "Counter-Strike: Condition Zero - Team Deathmatch"
Name: "{autoprograms}\CZ Normal"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" normal"; IconFilename: "{app}\czero\game.ico"; Comment: "Counter-Strike: Condition Zero - original game"
Name: "{autodesktop}\CZ TDM"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" tdm"; IconFilename: "{app}\czero\game.ico"; Tasks: desktopicons
Name: "{autodesktop}\CZ Normal"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" normal"; IconFilename: "{app}\czero\game.ico"; Tasks: desktopicons

[UninstallRun]
; put the original game back before removing the files
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" normal -NoLaunch"; Flags: runhidden; RunOnceId: "RestoreNormal"

[Code]
function IsCzDir(Dir: String): Boolean;
begin
  Result := FileExists(AddBackslash(Dir) + 'czero\liblist.gam');
end;

{ Looks through every Steam library listed in libraryfolders.vdf }
function FindCzInLibraries(SteamPath: String): String;
var
  Lines: TArrayOfString;
  I, P: Integer;
  Line, LibPath: String;
begin
  Result := '';
  if not LoadStringsFromFile(SteamPath + '\steamapps\libraryfolders.vdf', Lines) then
    Exit;
  for I := 0 to GetArrayLength(Lines) - 1 do
  begin
    Line := Trim(Lines[I]);
    if Pos('"path"', Line) = 1 then
    begin
      LibPath := Copy(Line, 7, Length(Line));
      P := Pos('"', LibPath);
      LibPath := Copy(LibPath, P + 1, Length(LibPath));
      P := Pos('"', LibPath);
      LibPath := Copy(LibPath, 1, P - 1);
      StringChangeEx(LibPath, '\\', '\', True);
      if IsCzDir(LibPath + '\steamapps\common\Half-Life') then
      begin
        Result := LibPath + '\steamapps\common\Half-Life';
        Exit;
      end;
    end;
  end;
end;

function GetCzDir(Param: String): String;
var
  SteamPath: String;
begin
  Result := ExpandConstant('{commonpf32}\Steam\steamapps\common\Half-Life');
  if RegQueryStringValue(HKCU, 'Software\Valve\Steam', 'SteamPath', SteamPath) then
  begin
    StringChangeEx(SteamPath, '/', '\', True);
    if IsCzDir(SteamPath + '\steamapps\common\Half-Life') then
      Result := SteamPath + '\steamapps\common\Half-Life'
    else if FindCzInLibraries(SteamPath) <> '' then
      Result := FindCzInLibraries(SteamPath);
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID = wpSelectDir) and not IsCzDir(WizardDirValue) then
  begin
    MsgBox('Counter-Strike: Condition Zero was not found here (no czero\liblist.gam).' + #13#10 +
           'Pick the Half-Life folder inside steamapps\common.', mbError, MB_OK);
    Result := False;
  end;
end;
