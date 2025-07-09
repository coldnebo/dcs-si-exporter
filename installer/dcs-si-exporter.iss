[Setup]
AppName=SayIntentions Exporter
AppVersion=0.9.5
DefaultDirName={code:GetDcsConfigDir}\Mods\Services\SayIntentionsExport
DisableDirPage=no
DisableProgramGroupPage=yes
OutputBaseFilename=SayIntentionsExporterInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "..\SayIntentionsExport\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Registry]
Root: HKCU; Subkey: "Software\SayIntentionsExporter"; ValueType: string; ValueName: "DcsConfigDir"; ValueData: "{code:GetDcsConfigDir}"; Flags: uninsdeletekey

[Code]
var
  dcsConfigDir: string;
  realWeatherDir: string;

function GetDcsConfigDir(Param: string): string;
begin
  if dcsConfigDir <> '' then
    Result := dcsConfigDir
  else
    Result := ExpandConstant('{usersavedgames}\DCS.openbeta');
end;

procedure InitializeWizard;
begin
  // Prompt for DCS config dir
  dcsConfigDir := ExpandConstant('{usersavedgames}\DCS.openbeta');
  BrowseForFolder('Select the DCS Saved Games folder (either DCS or DCS.openbeta)', dcsConfigDir, True);

  realWeatherDir := '{userprograms}\realweather';
  BrowseForFolder('If you use RealWeather, select its install folder', realWeatherDir, False);  
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ExportFile: string;
  LineToAdd: string;
  RWFilePath: string;
  alreadyPatched: Boolean;
  Lines: TArrayOfString;
  i: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    ExportFile := dcsConfigDir + '\Scripts\Export.lua';
    LineToAdd := 'pcall(function() dofile(lfs.writedir()..[[Mods\Services\SayIntentionsExport\SayIntentionsExport.lua]]); end,nil)';

    // Patch or add to Export.lua
    if FileExists(ExportFile) then
    begin
      Log('install script to Export.lua');
      LoadStringsFromFile(ExportFile, Lines);
      Log('mark 1');
      alreadyPatched := False;
      for i := 0 to GetArrayLength(Lines)-1 do
        if Pos(LineToAdd, Lines[i]) > 0 then 
        begin
          Log('Export.lua already patched');
          alreadyPatched := True;
          break;
        end;

      if not alreadyPatched then
      begin 
        Log('mark 2');
        SetArrayLength(Lines, GetArrayLength(Lines)+1);
        Lines[GetArrayLength(Lines)-1] := LineToAdd;
        SaveStringsToFile(ExportFile, Lines, false);
        Log('finished updating Export.lua');
      end
    end
    else
    begin
      SaveStringsToFile(ExportFile, [LineToAdd], false);
    end;

    Log('realWeatherDir: ' + realWeatherDir);
    
    // Patch realweatherapi.lua with selected realweather dir
    if realWeatherDir <> '' then
    begin
      RWFilePath := ExpandConstant('{app}\realweatherapi.lua');
      Log('RWFilePath: ' + RWFilePath);
      if FileExists(RWFilePath) then
      begin
        LoadStringsFromFile(RWFilePath, Lines);
        for i := 0 to GetArrayLength(Lines)-1 do
        begin
          if Pos('local log_path = ', Lines[i]) = 1 then
          begin
            Lines[i] := 'local log_path = [[' + realWeatherDir + '\realweather.log]]';
            break;
          end;
        end;
        SaveStringsToFile(RWFilePath, Lines, False);
      end;
    end;
    
  end;
end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ExportFile, LineToRemove: string;
  Lines, NewLines: TArrayOfString;
  i, j: Integer;
begin
  if CurUninstallStep = usUninstall then
  begin
    RegQueryStringValue(HKEY_CURRENT_USER, 'Software\SayIntentionsExporter', 'DcsConfigDir', dcsConfigDir);
    ExportFile := dcsConfigDir + '\Scripts\Export.lua';
    LineToRemove := 'pcall(function() dofile(lfs.writedir()..[[Mods\Services\SayIntentionsExport\SayIntentionsExport.lua]]); end,nil)';

    if FileExists(ExportFile) then
    begin
      LoadStringsFromFile(ExportFile, Lines);
      j := 0;
      SetArrayLength(NewLines, GetArrayLength(Lines));

      for i := 0 to GetArrayLength(Lines)-1 do
        if Trim(Lines[i]) <> LineToRemove then
        begin
          NewLines[j] := Lines[i];
          j := j + 1;
        end;

      SetArrayLength(NewLines, j);
      SaveStringsToFile(ExportFile, NewLines, False);
    end;
  end;
end;
