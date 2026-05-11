unit Settings;

interface

uses
   System.SysUtils, System.Classes,
   Vcl.Graphics, Vcl.Controls, Vcl.Forms,
   Vcl.StdCtrls, Vcl.ExtCtrls,
   Types;

type
   TfrmSettings = class( TForm )
      pnlMain: TPanel;
      pnlBottom: TPanel;
      btnOK: TButton;
      btnCancel: TButton;
      gbxScreenScraper: TGroupBox;
      lblSSUserId: TLabel;
      edtSSUserId: TEdit;
      lblSSPassword: TLabel;
      edtSSPassword: TEdit;
      lblLanguage: TLabel;
      cbxLanguage: TComboBox;
      gbxScrapeOptions: TGroupBox;
      lblScrapeImage: TLabel;
      cbxScrapeImage: TComboBox;
      lblScrapeThumb: TLabel;
      cbxScrapeThumb: TComboBox;
      lblScrapeLogo: TLabel;
      cbxScrapeLogo: TComboBox;
      lblScrapeRegion: TLabel;
      cbxScrapeRegion: TComboBox;
      chkScrapeVideos: TCheckBox;
      chkScrapeFanart: TCheckBox;
      chkScrapeBoxBack: TCheckBox;
      chkScrapeManual: TCheckBox;
      chkScrapeMap: TCheckBox;
      chkScrapeBezel: TCheckBox;
      procedure btnOKClick( Sender: TObject );
      procedure btnCancelClick( Sender: TObject );
   private
      FSettings: TSettings;
      procedure populateImageSources;
      procedure populateThumbSources;
      procedure populateLogoSources;
      procedure populateRegions;
   public
      procedure loadSettings( aSettings: TSettings );
      procedure saveSettings( aSettings: TSettings );
   end;

implementation

uses
   System.Math,
   Constantes;

{$R *.dfm}

procedure TfrmSettings.populateImageSources;
begin
   cbxScrapeImage.Items.Clear;
   cbxScrapeImage.Items.Add( cstSSMediaSs );        // Image en jeu
   cbxScrapeImage.Items.Add( cstSSMediaSsTitle );   // Image titre
   cbxScrapeImage.Items.Add( cstSSMediaMixV1 );     // Mix V1
   cbxScrapeImage.Items.Add( cstSSMediaMixV2 );     // Mix V2
   cbxScrapeImage.Items.Add( cstSSMediaBox2D );     // Boîte 2D
   cbxScrapeImage.Items.Add( cstSSMediaBox3D );     // Boîte 3D
   cbxScrapeImage.Items.Add( cstSSMediaFanart );    // Fanart
   cbxScrapeImage.Items.Add( cstSSMediaNone );      // Aucun
end;

procedure TfrmSettings.populateThumbSources;
begin
   cbxScrapeThumb.Items.Clear;
   cbxScrapeThumb.Items.Add( cstSSMediaNone );      // Aucun
   cbxScrapeThumb.Items.Add( cstSSMediaBox2D );     // Boîte 2D
   cbxScrapeThumb.Items.Add( cstSSMediaBox3D );     // Boîte 3D
end;

procedure TfrmSettings.populateLogoSources;
begin
   cbxScrapeLogo.Items.Clear;
   cbxScrapeLogo.Items.Add( cstSSMediaNone );          // Aucun
   cbxScrapeLogo.Items.Add( cstSSMediaWheelHD );       // Roue HD
   cbxScrapeLogo.Items.Add( cstSSMediaLogo );          // Logo
   cbxScrapeLogo.Items.Add( cstSSMediaScreenMarquee ); // Bannière
end;

procedure TfrmSettings.populateRegions;
begin
   cbxScrapeRegion.Items.Clear;
   cbxScrapeRegion.Items.Add( 'us' );
   cbxScrapeRegion.Items.Add( 'eu' );
   cbxScrapeRegion.Items.Add( 'fr' );
   cbxScrapeRegion.Items.Add( 'de' );
   cbxScrapeRegion.Items.Add( 'es' );
   cbxScrapeRegion.Items.Add( 'it' );
   cbxScrapeRegion.Items.Add( 'jp' );
   cbxScrapeRegion.Items.Add( 'wor' );
end;

procedure TfrmSettings.loadSettings( aSettings: TSettings );
begin
   FSettings:= aSettings;
   edtSSUserId.Text:= aSettings.ssUserId;
   edtSSPassword.Text:= aSettings.ssPassword;

   // Language
   cbxLanguage.Items.Clear;
   for var _lang:= Low( TScrapeLanguage ) to High( TScrapeLanguage ) do
      cbxLanguage.Items.Add( cstScrapeLanguageCodes[_lang] );
   var _idx:= cbxLanguage.Items.IndexOf( aSettings.scrapeLanguage );
   cbxLanguage.ItemIndex:= IfThen( _idx >= 0, _idx, 0 );

   // Image source
   populateImageSources;
   _idx:= cbxScrapeImage.Items.IndexOf( aSettings.scrapeImageSrc );
   cbxScrapeImage.ItemIndex:= IfThen( _idx >= 0, _idx, 0 );

   // Thumb source
   populateThumbSources;
   _idx:= cbxScrapeThumb.Items.IndexOf( aSettings.scrapeThumbSrc );
   cbxScrapeThumb.ItemIndex:= IfThen( _idx >= 0, _idx, 0 );

   // Logo source
   populateLogoSources;
   _idx:= cbxScrapeLogo.Items.IndexOf( aSettings.scrapeLogoSrc );
   cbxScrapeLogo.ItemIndex:= IfThen( _idx >= 0, _idx, 0 );

   // Region
   populateRegions;
   _idx:= cbxScrapeRegion.Items.IndexOf( aSettings.favRegion );
   cbxScrapeRegion.ItemIndex:= IfThen( _idx >= 0, _idx, 0 );

   // Checkboxes
   chkScrapeVideos.Checked := aSettings.scrapeVideos;
   chkScrapeFanart.Checked := aSettings.scrapeFanart;
   chkScrapeBoxBack.Checked:= aSettings.scrapeBoxBack;
   chkScrapeManual.Checked := aSettings.scrapeManual;
   chkScrapeMap.Checked    := aSettings.scrapeMap;
   chkScrapeBezel.Checked  := aSettings.scrapeBezel;
end;

procedure TfrmSettings.saveSettings( aSettings: TSettings );
begin
   aSettings.ssUserId      := edtSSUserId.Text;
   aSettings.ssPassword    := edtSSPassword.Text;
   aSettings.scrapeLanguage:= cbxLanguage.Items[cbxLanguage.ItemIndex];
   aSettings.scrapeImageSrc:= cbxScrapeImage.Items[cbxScrapeImage.ItemIndex];
   aSettings.scrapeThumbSrc:= cbxScrapeThumb.Items[cbxScrapeThumb.ItemIndex];
   aSettings.scrapeLogoSrc := cbxScrapeLogo.Items[cbxScrapeLogo.ItemIndex];
   aSettings.favRegion     := cbxScrapeRegion.Items[cbxScrapeRegion.ItemIndex];
   aSettings.scrapeVideos  := chkScrapeVideos.Checked;
   aSettings.scrapeFanart  := chkScrapeFanart.Checked;
   aSettings.scrapeBoxBack := chkScrapeBoxBack.Checked;
   aSettings.scrapeManual  := chkScrapeManual.Checked;
   aSettings.scrapeMap     := chkScrapeMap.Checked;
   aSettings.scrapeBezel   := chkScrapeBezel.Checked;
end;

procedure TfrmSettings.btnOKClick( Sender: TObject );
begin
   saveSettings( FSettings );
   ModalResult:= mrOK;
end;

procedure TfrmSettings.btnCancelClick( Sender: TObject );
begin
   ModalResult:= mrCancel;
end;

end.
