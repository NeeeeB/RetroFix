unit ConfirmDelete;

interface

uses
   System.Classes,
   Vcl.Controls,
   Vcl.Forms,
   Vcl.StdCtrls;

type
   TfrmConfirmDelete = class( TForm )
      lblMessage: TLabel;
      chkDeleteOrphans: TCheckBox;
      chkDeleteRpcs3Data: TCheckBox;
      btnOK: TButton;
      btnCancel: TButton;
      procedure FormShow( Sender: TObject );
   public
      class function Execute( const aMessage: string;
                              const aHasPs3Games: Boolean;
                              out aDeleteOrphans: Boolean;
                              out aDeleteRpcs3Data: Boolean ): Boolean;
   end;

implementation

{$R *.dfm}

class function TfrmConfirmDelete.Execute( const aMessage: string;
                                          const aHasPs3Games: Boolean;
                                          out aDeleteOrphans: Boolean;
                                          out aDeleteRpcs3Data: Boolean ): Boolean;
begin
   var _frm:= TfrmConfirmDelete.Create( nil );
   try
      _frm.lblMessage.Caption:= aMessage;
      _frm.chkDeleteRpcs3Data.Visible:= aHasPs3Games;
      if ( aHasPs3Games ) then
         _frm.ClientHeight:= 140
      else
         _frm.ClientHeight:= 120;
      Result:= ( _frm.ShowModal = mrOK );
      aDeleteOrphans:= Result and
                       ( _frm.chkDeleteOrphans.Checked );
      aDeleteRpcs3Data:= Result and
                         ( aHasPs3Games ) and
                         ( _frm.chkDeleteRpcs3Data.Checked );
   finally
      _frm.Free;
   end;
end;

procedure TfrmConfirmDelete.FormShow( Sender: TObject );
begin
   btnOK.SetFocus;
end;

end.
