unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, System.IOUtils, Winapi.ShellAPI,
  clMailMessage, clSocketUtils, GoogleApis, GoogleApis.Persister, GoogleApis.Gmail, SendGmail;

type
  TMainForm = class(TForm)
    pnlLogo: TPanel;
    imLogoLeft: TImage;
    imLogoMiggle: TImage;
    imLogoRight: TImage;
    pnlMain: TPanel;
    Label5: TLabel;
    edtFrom: TEdit;
    Label6: TLabel;
    edtTo: TEdit;
    Label7: TLabel;
    edtSubject: TEdit;
    memBody: TMemo;
    btnSend: TButton;
    clMailMessage1: TclMailMessage;
    Label1: TLabel;
    lbAttachments: TListBox;
    btnAdd: TButton;
    btnDelete: TButton;
    OpenDialog1: TOpenDialog;
    btnLogout: TButton;
    procedure btnSendClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
  private
    FService: TGmailService;
    function GetService: TGmailService;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FService := nil;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FService.Free();
end;

function TMainForm.GetService: TGmailService;
var
  credential: TGoogleOAuthCredential;
  initializer: TServiceInitializer;
begin
  btnLogout.Enabled := True;

  if (FService = nil) then
  begin
    credential := TGoogleOAuthCredential.Create();
    initializer := TGoogleApisServiceInitializer.Create(credential, 'CleverComponents Gmail example');
    FService := TGmailService.Create(initializer);
    //You need to specify both Client ID and Client Secret of your Google API Project.
    credential.ClientID := '421475025220-6khpgoldbdsi60fegvjdqk2bk4v19ss2.apps.googleusercontent.com';
    credential.ClientSecret := '_4HJyAVUmH_iVrPB8pOJXjR1';

    //The GmailReadonly scope is used to obtain the user's email address.
    //The GmailSend scope is used to send mail.
    //Use space(32) symbols to specify multiple scopes.
    credential.Scope := GmailReadonly + ' ' + GmailSend;

    //Set the user's email address as the message sender.
    edtFrom.Text := GetMyEmailAddress(FService);
  end;
  Result := FService;
end;

procedure TMainForm.btnSendClick(Sender: TObject);
var
  service: TGmailService;
begin
  btnSend.Enabled := False;
  btnSend.Caption := 'Sending...';
  try
    service := GetService();

    //Build a new mail message
    clMailMessage1.BuildMessage(memBody.Text, lbAttachments.Items);
    clMailMessage1.From.FullAddress := edtFrom.Text;
    clMailMessage1.ToList.EmailAddresses := edtTo.Text;
    clMailMessage1.Subject := edtSubject.Text;

    SendMail(service, clMailMessage1);

    ShowMessage('The message was sent successfully.');
  finally
    btnSend.Enabled := True;
    btnSend.Caption := 'Send';
  end;
end;

procedure TMainForm.btnAddClick(Sender: TObject);
begin
  if OpenDialog1.Execute() then
  begin
    lbAttachments.Items.Add(OpenDialog1.FileName);
  end;
end;

procedure TMainForm.btnDeleteClick(Sender: TObject);
begin
  if (lbAttachments.ItemIndex > -1) then
  begin
    lbAttachments.Items.Delete(lbAttachments.ItemIndex);
  end;
end;

procedure TMainForm.btnLogoutClick(Sender: TObject);
begin
  if btnSend.Enabled then
  begin
    FreeAndNil(FService);
    edtFrom.Text := '';
    btnLogout.Enabled := False;
  end else
  begin
    FService.Abort();
  end;
end;

end.
