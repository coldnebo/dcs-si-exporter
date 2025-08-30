#define MyAppName "SayIntentionsExport"
#define MyAppVersion "0.9.7"
#define MyAppPublisher "coldnebo"
#define MyAppURL "https://github.com/coldnebo/dcs-si-exporter"

[Setup]
AppId={{12345678-1234-1234-1234-123456789ABC}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
DisableDirPage=yes
; LicenseFile=..\License.txt
PrivilegesRequired=lowest
; OutputDir=..\Output
OutputBaseFilename=SayIntentionsExport_Setup_{#MyAppVersion}
; SetupIconFile=..\icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\unins000.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Registry]
Root: HKCU; Subkey: "Software\SayIntentionsExporter"; ValueType: string; ValueName: "DcsConfigDir"; ValueData: "{code:GetDCSConfigDir}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\SayIntentionsExporter"; ValueType: string; ValueName: "SayIntentionsDir"; ValueData: "{code:GetSayIntentionsPath}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\SayIntentionsExporter"; ValueType: string; ValueName: "RealWeatherDir"; ValueData: "{code:GetRealWeatherPath}"; Flags: uninsdeletekey

[Files]
Source: "..\SayIntentionsExport\*"; DestDir: "{code:GetDCSConfigDir}\Mods\Services\SayIntentionsExport"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "si_config.lua"

[Code]
var
  SayIntentionsPathPage: TInputDirWizardPage;
  RealWeatherPathPage: TInputQueryWizardPage;
  DCSConfigPathPage: TInputDirWizardPage;
  SayIntentionsPath: string;
  RealWeatherPath: string;
  DCSConfigPath: string;
  RealWeatherBrowseButton: TNewButton;

const
  ExportLuaLine = 'pcall(function() local silfs=require(''lfs'');dofile(silfs.writedir()..[[Mods\Services\SayIntentionsExport\SayIntentionsExport.lua]]); end,nil)';

procedure RealWeatherBrowseButtonClick(Sender: TObject);
var
  DirName: string;
begin
  DirName := RealWeatherPathPage.Values[0];
  if BrowseForFolder('Select RealWeather Directory:', DirName, False) then
  begin
    RealWeatherPathPage.Values[0] := DirName;
  end;
end;

procedure InitializeWizard;
begin
  // Create custom pages for directory selection
  
  // DCS Config directory page (first)
  DCSConfigPathPage := CreateInputDirPage(wpSelectDir,
    'Select DCS Config Directory', 'Where is your DCS configuration stored?',
    'Select your DCS configuration directory (e.g., DCS.openbeta folder in Saved Games), then click Next.',
    False, '');
  DCSConfigPathPage.Add('DCS Config directory:');
  DCSConfigPathPage.Values[0] := ExpandConstant('{usersavedgames}\DCS.openbeta');

  // SayIntentionsAI directory page (second)
  SayIntentionsPathPage := CreateInputDirPage(DCSConfigPathPage.ID,
    'Select SayIntentionsAI Directory', 'Where is SayIntentionsAI installed?',
    'Select the folder where SayIntentionsAI is installed, then click Next.',
    False, '');
  SayIntentionsPathPage.Add('SayIntentionsAI install directory:');
  SayIntentionsPathPage.Values[0] := ExpandConstant('{localappdata}\SayIntentionsAI');

  // RealWeather directory page (third, optional) - using InputQuery instead of InputDir to avoid validation
  RealWeatherPathPage := CreateInputQueryPage(SayIntentionsPathPage.ID,
    'Select RealWeather Directory (Optional)', 'Where is RealWeather installed?',
    'Enter the full path where RealWeather is installed, or leave blank to skip. Then click Next.');
  RealWeatherPathPage.Add('RealWeather install directory (leave blank if not installed):', False);
  RealWeatherPathPage.Values[0] := '';
  
  // Add Browse button for RealWeather directory
  RealWeatherBrowseButton := TNewButton.Create(RealWeatherPathPage);
  RealWeatherBrowseButton.Parent := RealWeatherPathPage.Surface;
  RealWeatherBrowseButton.Left := RealWeatherPathPage.Edits[0].Left + RealWeatherPathPage.Edits[0].Width + ScaleX(8);
  RealWeatherBrowseButton.Top := RealWeatherPathPage.Edits[0].Top;
  RealWeatherBrowseButton.Width := ScaleX(75);
  RealWeatherBrowseButton.Height := RealWeatherPathPage.Edits[0].Height;
  RealWeatherBrowseButton.Caption := 'Browse...';
  RealWeatherBrowseButton.OnClick := @RealWeatherBrowseButtonClick;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  
  if CurPageID = DCSConfigPathPage.ID then
  begin
    DCSConfigPath := DCSConfigPathPage.Values[0];
    if (DCSConfigPath = '') then
    begin
      MsgBox('Please select the DCS Config directory.', mbError, MB_OK);
      Result := False;
    end
    else if not DirExists(DCSConfigPath) then
    begin
      MsgBox('The specified DCS Config directory does not exist. Please select a valid directory.', mbError, MB_OK);
      Result := False;
    end;
  end
  
  else if CurPageID = SayIntentionsPathPage.ID then
  begin
    SayIntentionsPath := SayIntentionsPathPage.Values[0];
    if (SayIntentionsPath = '') then
    begin
      MsgBox('Please select the SayIntentionsAI directory.', mbError, MB_OK);
      Result := False;
    end
    else if not DirExists(SayIntentionsPath) then
    begin
      MsgBox('The specified SayIntentionsAI directory does not exist. Please select a valid directory.', mbError, MB_OK);
      Result := False;
    end;
  end
  
  else if CurPageID = RealWeatherPathPage.ID then
  begin
    RealWeatherPath := RealWeatherPathPage.Values[0];
    // RealWeather is optional - skip all validation if empty
    if (RealWeatherPath = '') then
    begin
      // Empty is fine, just continue
      Result := True;
    end
    else if not DirExists(RealWeatherPath) then
    begin
      if MsgBox('The specified RealWeather directory does not exist. Do you want to continue without RealWeather integration?', mbConfirmation, MB_YESNO) = IDNO then
      begin
        Result := False;
      end
      else
      begin
        RealWeatherPath := ''; // Clear invalid path
      end;
    end;
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // Don't skip any pages
  Result := False;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  S: String;
begin
  S := '';
  S := S + 'DCS Config Directory:' + NewLine + Space + DCSConfigPath + NewLine + NewLine;
  S := S + 'SayIntentionsAI Directory:' + NewLine + Space + SayIntentionsPath + NewLine + NewLine;
  
  if RealWeatherPath <> '' then
    S := S + 'RealWeather Directory:' + NewLine + Space + RealWeatherPath + NewLine + NewLine
  else
    S := S + 'RealWeather Directory:' + NewLine + Space + '(Not installed)' + NewLine + NewLine;
    
  Result := S;
end;

function GetDCSConfigDir(Param: string): string;
begin
  Result := DCSConfigPath;
end;

function GetSayIntentionsPath(Param: string): string;
begin
  Result := SayIntentionsPath;
end;

function GetRealWeatherPath(Param: string): string;
begin
  Result := RealWeatherPath;
end;

procedure CreateConfigFile;
var
  ConfigFile: string;
  ConfigContent: TArrayOfString;
  RealWeatherLine: string;
begin
  ConfigFile := DCSConfigPath + '\Mods\Services\SayIntentionsExport\si_config.lua';
  
  SetArrayLength(ConfigContent, 7);
  ConfigContent[0] := '-- Auto-generated by Inno Setup on install.';
  ConfigContent[1] := 'return {';
  ConfigContent[2] := '  app_version = "' + '{#MyAppVersion}' + '",';
  ConfigContent[3] := '  mod_path = [[Mods\Services\SayIntentionsExport]],';
  ConfigContent[4] := '  sayintentions_path = [[' + SayIntentionsPath + ']],';
  
  if RealWeatherPath <> '' then
    RealWeatherLine := '  realweather_path = [[' + RealWeatherPath + ']]'
  else
    RealWeatherLine := '  realweather_path = nil';
  
  ConfigContent[5] := RealWeatherLine;
  ConfigContent[6] := '}';
  
  SaveStringsToFile(ConfigFile, ConfigContent, False);
end;

procedure ModifyExportLua;
var
  ExportLuaFile: string;
  Lines: TArrayOfString;
  i: Integer;
  Found: Boolean;
begin
  ExportLuaFile := DCSConfigPath + '\Scripts\Export.lua';
  
  // Create Scripts directory if it doesn't exist
  ForceDirectories(ExtractFileDir(ExportLuaFile));
  
  Found := False;
  
  // Check if file exists and if the line is already present
  if FileExists(ExportLuaFile) then
  begin
    LoadStringsFromFile(ExportLuaFile, Lines);
    
    // Check if the line already exists
    for i := 0 to GetArrayLength(Lines) - 1 do
    begin
      if Pos('SayIntentionsExport.lua', Lines[i]) > 0 then
      begin
        Found := True;
        break;
      end;
    end;
  end
  else
  begin
    // File doesn't exist, create empty array
    SetArrayLength(Lines, 0);
  end;
  
  // Add the line if not found
  if not Found then
  begin
    SetArrayLength(Lines, GetArrayLength(Lines) + 1);
    Lines[GetArrayLength(Lines) - 1] := ExportLuaLine;
    SaveStringsToFile(ExportLuaFile, Lines, False);
  end;
end;

procedure RemoveFromExportLua;
var
  ExportLuaFile: string;
  Lines: TArrayOfString;
  NewLines: TArrayOfString;
  i: Integer;
begin
  ExportLuaFile := DCSConfigPath + '\Scripts\Export.lua';
  
  if FileExists(ExportLuaFile) then
  begin
    LoadStringsFromFile(ExportLuaFile, Lines);
    SetArrayLength(NewLines, 0);
    
    // Copy all lines except the SayIntentionsExport line
    for i := 0 to GetArrayLength(Lines) - 1 do
    begin
      if (Lines[i] <> ExportLuaLine) and (Pos('SayIntentionsExport.lua', Lines[i]) = 0) then
      begin
        SetArrayLength(NewLines, GetArrayLength(NewLines) + 1);
        NewLines[GetArrayLength(NewLines) - 1] := Lines[i];
      end;
    end;
    
    // Save the modified file
    SaveStringsToFile(ExportLuaFile, NewLines, False);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Create the config file
    CreateConfigFile;
    
    // Modify Export.lua
    ModifyExportLua;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DCSConfigDir: string;
  SayIntentionsDir: string;
  RealWeatherDir: string;
  RegFound: Boolean;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    RegFound := False;
    
    // Try to read the DCS config directory from registry
    if RegQueryStringValue(HKCU, 'Software\SayIntentionsExporter', 'DcsConfigDir', DCSConfigDir) then
    begin
      RegFound := True;
      DCSConfigPath := DCSConfigDir;
      
      // Also read the other paths for potential future use
      RegQueryStringValue(HKCU, 'Software\SayIntentionsExporter', 'SayIntentionsDir', SayIntentionsDir);
      RegQueryStringValue(HKCU, 'Software\SayIntentionsExporter', 'RealWeatherDir', RealWeatherDir);
      
      // Remove the line from Export.lua
      RemoveFromExportLua;
      
      // Remove the entire SayIntentionsExport directory
      if DirExists(DCSConfigDir + '\Mods\Services\SayIntentionsExport') then
      begin
        DelTree(DCSConfigDir + '\Mods\Services\SayIntentionsExport', True, True, True);
      end;
    end;
    
    if not RegFound then
    begin
      // Try some common DCS paths as fallback
      if DirExists(ExpandConstant('{usersavedgames}\DCS.openbeta')) then
      begin
        DCSConfigPath := ExpandConstant('{usersavedgames}\DCS.openbeta');
        RemoveFromExportLua;
        if DirExists(DCSConfigPath + '\Mods\Services\SayIntentionsExport') then
        begin
          DelTree(DCSConfigPath + '\Mods\Services\SayIntentionsExport', True, True, True);
        end;
      end
      else if DirExists(ExpandConstant('{usersavedgames}\DCS')) then
      begin
        DCSConfigPath := ExpandConstant('{usersavedgames}\DCS');
        RemoveFromExportLua;
        if DirExists(DCSConfigPath + '\Mods\Services\SayIntentionsExport') then
        begin
          DelTree(DCSConfigPath + '\Mods\Services\SayIntentionsExport', True, True, True);
        end;
      end
      else
      begin
        // Show message only if we couldn't find any common paths
        MsgBox('Could not automatically locate DCS configuration. You may need to manually remove:' + #13#10 +
               '- Line from Scripts\Export.lua containing "SayIntentionsExport"' + #13#10 +
               '- Folder: Mods\Services\SayIntentionsExport', mbInformation, MB_OK);
      end;
    end;
  end;
end;