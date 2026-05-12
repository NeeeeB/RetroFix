unit ConfirmDelete;

interface

uses
   System.Classes,
   Vcl.Controls,
   Vcl.Forms,
   Vcl.StdCtrls,
   Vcl.ExtCtrls;

type
   TfrmConfirmDelete = class( TForm )
      lblMessage: TLabel;
      chkDeleteOrphans: TCheckBox;
      btnOK: TButton;
      btnCancel: TButton;
      procedure FormShow(Sender: TObject);
   public
      class function Execute( const aMessage: string;
                              out aDeleteOrphans: Boolean ): Boolean;
   end;

implementation

{$R *.dfm}

class function TfrmConfirmDelete.Execute( const aMessage: string;
                                          out aDeleteOrphans: Boolean ): Boolean;
begin
   var _frm:= TfrmConfirmDelete.Create( nil );
   try
      _frm.lblMessage.Caption:= aMessage;
      Result:= ( _frm.ShowModal = mrOK );
      aDeleteOrphans:= ( Result ) and
                       ( _frm.chkDeleteOrphans.Checked );
   finally
      _frm.Free;
   end;
end;

procedure TfrmConfirmDelete.FormShow(Sender: TObject);
begin
   btnOK.SetFocus;
end;

end.
