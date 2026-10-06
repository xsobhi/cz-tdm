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
AppName=CZ TDM Mod + Optimizer
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
Name: mod; Description: "Install the TDM mod (respawn, keep weapons, HP regen, announcer...)"; GroupDescription: "Mod:"
Name: mod\desktopicons; Description: "Desktop shortcuts: CZ TDM / CZ Normal"; GroupDescription: "Mod:"
Name: opt_mouse; Description: "Raw mouse input (no acceleration or smoothing)"; GroupDescription: "Make the game smoother:"
Name: opt_fps; Description: "Uncap FPS and turn V-Sync off (less input delay)"; GroupDescription: "Make the game smoother:"
Name: opt_net; Description: "Smooth online play (100 updates/s, better rates and interpolation)"; GroupDescription: "Make the game smoother:"
Name: opt_perf; Description: "No muzzle-flash wall lighting (steadier FPS while shooting)"; GroupDescription: "Make the game smoother:"
Name: opt_server; Description: "Smooth hosting for friends (server rates and lag compensation)"; GroupDescription: "Make the game smoother:"
Name: opt_gpu; Description: "Run CZ on the high-performance GPU (laptops with 2 GPUs)"; GroupDescription: "Make the game smoother:"
Name: opt_netgraph; Description: "Show FPS / ping / packet loss in the corner"; GroupDescription: "Make the game smoother:"; Flags: unchecked

[Files]
Source: "{#Src}\czero\dlls\cstdm.dll"; DestDir: "{app}\czero\dlls"; Flags: ignoreversion; Tasks: mod
Source: "{#Src}\czero\tdm.cfg"; DestDir: "{app}\czero"; Flags: ignoreversion; Tasks: mod
Source: "{#Src}\czero\sound\tdm\*.wav"; DestDir: "{app}\czero\sound\tdm"; Flags: ignoreversion; Tasks: mod
Source: "{#Src}\czero\sound\tdm\CREDITS.txt"; DestDir: "{app}\czero\sound\tdm"; Flags: ignoreversion; Tasks: mod
Source: "{#Src}\czero\tdm-mod\*"; DestDir: "{app}\czero\tdm-mod"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\CZ TDM"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" tdm"; IconFilename: "{app}\czero\game.ico"; Comment: "Counter-Strike: Condition Zero - Team Deathmatch"; Tasks: mod
Name: "{autoprograms}\CZ Normal"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" normal"; IconFilename: "{app}\czero\game.ico"; Comment: "Counter-Strike: Condition Zero - original game"; Tasks: mod
Name: "{autodesktop}\CZ TDM"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" tdm"; IconFilename: "{app}\czero\game.ico"; Tasks: mod\desktopicons
Name: "{autodesktop}\CZ Normal"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" normal"; IconFilename: "{app}\czero\game.ico"; Tasks: mod\desktopicons

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\optimize.ps1"" {code:OptimizeArgs}"; Flags: runhidden; StatusMsg: "Applying optimizations..."

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\optimize.ps1"" -Remove"; Flags: runhidden; RunOnceId: "RemoveOptimizations"
; put the original game back before removing the files
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\czero\tdm-mod\cz-mode.ps1"" normal -NoLaunch"; Flags: runhidden; RunOnceId: "RestoreNormal"

[Code]
function OptimizeArgs(Param: String): String;
begin
  Result := '';
  if WizardIsTaskSelected('opt_mouse') then Result := Result + ' -Mouse';
  if WizardIsTaskSelected('opt_fps') then Result := Result + ' -Fps';
  if WizardIsTaskSelected('opt_net') then Result := Result + ' -Network';
  if WizardIsTaskSelected('opt_perf') then Result := Result + ' -Perf';
  if WizardIsTaskSelected('opt_server') then Result := Result + ' -Server';
  if WizardIsTaskSelected('opt_gpu') then Result := Result + ' -Gpu';
  if WizardIsTaskSelected('opt_netgraph') then Result := Result + ' -NetGraph';
end;

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

function CzFromSteam(SteamPath: String): String;
begin
  Result := '';
  if SteamPath = '' then Exit;
  StringChangeEx(SteamPath, '/', '\', True);
  if IsCzDir(SteamPath + '\steamapps\common\Half-Life') then
    Result := SteamPath + '\steamapps\common\Half-Life'
  else
    Result := FindCzInLibraries(SteamPath);
end;

{ Steam's own location (per-user, then machine-wide), then every library in libraryfolders.vdf }
function GetCzDir(Param: String): String;
var
  SteamPath: String;
begin
  Result := '';
  if RegQueryStringValue(HKCU, 'Software\Valve\Steam', 'SteamPath', SteamPath) then
    Result := CzFromSteam(SteamPath);
  if (Result = '') and RegQueryStringValue(HKLM32, 'SOFTWARE\Valve\Steam', 'InstallPath', SteamPath) then
    Result := CzFromSteam(SteamPath);
  if (Result = '') and IsWin64 and RegQueryStringValue(HKLM64, 'SOFTWARE\Wow6432Node\Valve\Steam', 'InstallPath', SteamPath) then
    Result := CzFromSteam(SteamPath);
  if Result = '' then
    Result := CzFromSteam(ExpandConstant('{commonpf32}\Steam'));
  if Result = '' then
    Result := ExpandConstant('{commonpf32}\Steam\steamapps\common\Half-Life');
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
