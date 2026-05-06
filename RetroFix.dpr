program RetroFix;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles,
  Constantes in 'Constantes.pas',
  Types in 'Types.pas',
  BiosExtractor in 'BiosExtractor.pas',
  BiosParser in 'BiosParser.pas',
  BiosChecker in 'BiosChecker.pas',
  HashUtils in 'HashUtils.pas',
  BiosDetails in 'BiosDetails.pas' {Form1},
  BiosExport in 'BiosExport.pas',
  BiosUtils in 'BiosUtils.pas',
  GamelistParser in 'GamelistParser.pas',
  GamelistChecker in 'GamelistChecker.pas',
  GamelistDetails in 'GamelistDetails.pas' {Form2},
  ScreenScraperApi in 'ScreenScraperApi.pas',
  EsSettingsReader in 'EsSettingsReader.pas',
  Settings in 'Settings.pas' {Form3},
  RomUtils in 'RomUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
