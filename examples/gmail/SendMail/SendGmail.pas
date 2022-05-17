unit SendGmail;

interface

uses
  System.Classes, clMailMessage, GoogleApis, GoogleApis.Persister, GoogleApis.Gmail, GoogleApis.Gmail.Data,
  GoogleApis.Gmail.Users, GoogleApis.Gmail.Messages;

function GetMyEmailAddress(AService: TGmailService): string;

procedure SendMail(AService: TGmailService; AMessage: TclMailMessage);

implementation

function GetMyEmailAddress(AService: TGmailService): string;
var
  request: TUsersGetProfileRequest;
  response: TProfile;
begin
  request := nil;
  response := nil;
  try
    request := AService.Users.GetProfile('me');
    response := request.Execute();
    Result := response.EmailAddress;
  finally
    response.Free();
    request.Free();
  end;
end;

procedure SendMail(AService: TGmailService; AMessage: TclMailMessage);
var
  request: TMessagesSendRequest;
  content, response: TMessage;
begin
  request := nil;
  response := nil;
  try
    content := TMessage.Create();
    request := AService.Users.Messages.Send('me', content);

    content.Raw := TBase64UrlEncoder.Encode(AMessage.MessageSource.Text);
    response := request.Execute();
  finally
    response.Free();
    request.Free();
  end;
end;

end.
