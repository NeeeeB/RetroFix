program RetroFix;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  BiosDetails in 'Forms\BiosDetails.pas' {frmBiosDetails},
  GamelistDetails in 'Forms\GamelistDetails.pas' {frmGamelistDetails},
  Main in 'Forms\Main.pas' {frmMain},
  Settings in 'Forms\Settings.pas' {frmSettings},
  BiosChecker in 'Logic\BiosChecker.pas',
  BiosExport in 'Logic\BiosExport.pas',
  BiosExtractor in 'Logic\BiosExtractor.pas',
  BiosParser in 'Logic\BiosParser.pas',
  EsSettingsReader in 'Logic\EsSettingsReader.pas',
  GamelistChecker in 'Logic\GamelistChecker.pas',
  GamelistParser in 'Logic\GamelistParser.pas',
  ScreenScraperApi in 'Network\ScreenScraperApi.pas',
  Constantes in 'Shared\Constantes.pas',
  HashUtils in 'Shared\HashUtils.pas',
  RomUtils in 'Shared\RomUtils.pas',
  Types in 'Shared\Types.pas',
  ConfirmDelete in 'Forms\ConfirmDelete.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  TStyleManager.TrySetStyle('Windows11 Impressive Dark SE');
  Application.Run;
end.
