program SendMail;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  SendGmail in 'SendGmail.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
