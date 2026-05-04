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
      procedure btnOKClick( Sender: TObject );
      procedure btnCancelClick( Sender: TObject );
   private
      FSettings: TSettings;
   public
      procedure loadSettings( aSettings: TSettings );
      procedure saveSettings( aSettings: TSettings );
   end;

implementation

{$R *.dfm}

procedure TfrmSettings.loadSettings( aSettings: TSettings );
begin
   FSettings:= aSettings;
   edtSSUserId.Text:= aSettings.ssUserId;
   edtSSPassword.Text:= aSettings.ssPassword;
end;

procedure TfrmSettings.saveSettings( aSettings: TSettings );
begin
   aSettings.ssUserId:= edtSSUserId.Text;
   aSettings.ssPassword:= edtSSPassword.Text;
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
