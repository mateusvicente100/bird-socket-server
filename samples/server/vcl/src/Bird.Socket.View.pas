unit Bird.Socket.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxGDIPlusClasses, Vcl.ExtCtrls;

type
  TFrmMainMenu = class(TForm)
    Panel7: TPanel;
    imgHeader: TImage;
    imgClose: TImage;
    procedure imgCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMainMenu: TFrmMainMenu;

implementation

{$R *.dfm}

procedure TFrmMainMenu.imgCloseClick(Sender: TObject);
begin
  Close;
end;

end.
