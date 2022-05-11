{
  Copyright (C) 2022 by Clever Components

  Author: Sergey Shirokov <admin@clevercomponents.com>

  Website: www.CleverComponents.com

  This file is part of Google API Client Library for Delphi.

  Google API Client Library for Delphi is free software:
  you can redistribute it and/or modify it under the terms of
  the GNU Lesser General Public License version 3
  as published by the Free Software Foundation and appearing in the
  included file COPYING.LESSER.

  Google API Client Library for Delphi is distributed in the hope
  that it will be useful, but WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with Json Serializer. If not, see <http://www.gnu.org/licenses/>.

  The current version of Google API Client Library for Delphi needs for
  the non-free library Clever Internet Suite. This is a drawback,
  and we suggest the task of changing
  the program so that it does the same job without the non-free library.
  Anyone who thinks of doing substantial further work on the program,
  first may free it from dependence on the non-free library.
}

unit GoogleApis.Gmail.Tests;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  System.Generics.Defaults, TestFramework,
  GoogleApis, GoogleApis.Persister, GoogleApis.Gmail, GoogleApis.Gmail.Data,
  GoogleApis.Gmail.Users, GoogleApis.Gmail.Labels, GoogleApis.Gmail.Messages,
  GoogleApis.Gmail.Drafts;

type
  TUsersTests = class(TTestCase)
  published
    procedure TestGetProfile;
  end;

  TLabelsTests = class(TTestCase)
  published
    procedure TestList;
    procedure TestGet;
    procedure TestModify;
  end;

  TMessagesTests = class(TTestCase)
  public
    class function GetMessageId(const ASubject: string = ''): string;
    class function GetMyEmail: string;
  published
    procedure TestList;
    procedure TestGet;
    procedure TestSend;
    procedure TestTrash;
    procedure TestModify;
    procedure TestInsert;
    procedure TestImport;
    procedure TestBatchDelete;
    procedure TestBatchModify;
  end;

  TDraftsTests = class(TTestCase)
  strict private
    function CreateDraft(const AMsg: string): string;
  published
    procedure TestDelete;
    procedure TestGet;
    procedure TestUpdate;
    procedure TestList;
    procedure TestSend;
  end;

implementation

var
  Service: TGmailService = nil;

function GetService: TGmailService;
var
  credential: TGoogleOAuthCredential;
  initializer: TServiceInitializer;
begin
  if (Service = nil) then
  begin
    credential := TGoogleOAuthCredential.Create();
    initializer := TGoogleApisServiceInitializer.Create(credential, 'CleverComponents Calendar test');
    Service := TGmailService.Create(initializer);

    credential.ClientID := '421475025220-6khpgoldbdsi60fegvjdqk2bk4v19ss2.apps.googleusercontent.com';
    credential.ClientSecret := '_4HJyAVUmH_iVrPB8pOJXjR1';
    credential.Scope := MailGoogleCom + ' ' + GMailLabels + ' ' + GmailReadonly + ' ' + GmailSend;
  end;
  Result := Service;
end;

{ TLabelsTests }

procedure TLabelsTests.TestGet;
var
  request: TLabelsGetRequest;
  response: TLabel;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.Labels.Get('me', 'INBOX');

    response := request.Execute();

    CheckEquals('INBOX', response.Name);
    CheckEquals('system', response.Type_);
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TLabelsTests.TestList;
var
  request: TLabelsListRequest;
  response: TLabels;
  lab: TLabel;
  found: Boolean;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.Labels.List('me');

    response := request.Execute();

    Check(Length(response.Labels) > 0);

    found := False;
    for lab in response.Labels do
    begin
      found := (lab.Name = 'INBOX') and (lab.Type_ = 'system');
      if found then Break;
    end;
    Check(found);
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TLabelsTests.TestModify;
var
  create_request: TLabelsCreateRequest;
  patch_request: TLabelsPatchRequest;
  delete_request: TLabelsDeleteRequest;
  content, response: TLabel;
  id: string;
begin
  create_request := nil;
  patch_request := nil;
  delete_request := nil;
  response := nil;
  try
    //create
    content := TLabel.Create();
    create_request := GetService().Users.Labels.Create_('me', content);
    content.Name := 'delphi_gmail_api_name';

    response := create_request.Execute();

    id := response.Id;
    CheckNotEquals('', id);
    CheckEquals(content.Name, response.Name);
    FreeAndNil(response);

    //patch
    content := TLabel.Create();
    patch_request := GetService().Users.Labels.Patch('me', id, content);
    content.Id := id;
    content.Name := 'delphi_gmail_api_name_updated';

    response := patch_request.Execute();

    id := response.Id;
    CheckNotEquals('', id);
    CheckEquals(content.Name, response.Name);
    FreeAndNil(response);

    //delete
    delete_request := GetService().Users.Labels.Delete('me', id);
    delete_request.Execute();

    //try to delete non-existing
    try
      delete_request.Execute();
      CheckFalse(True);
    except
      on E: EGoogleApisException do;
    end;
  finally
    response.Free();
    delete_request.Free();
    patch_request.Free();
    create_request.Free();
  end;
end;

{ TMessagesTests }

class function TMessagesTests.GetMessageId(const ASubject: string): string;
var
  request: TMessagesListRequest;
  response: TMessages;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.Messages.List('me');
    request.MaxResults := 1;

    if (ASubject <> '') then
    begin
      request.Q := 'subject:' + ASubject;
    end;

    response := request.Execute();

    if (Length(response.Messages) = 1) then
    begin
      Result := response.Messages[0].Id;
    end else
    begin
      Result := '';
    end;
  finally
    response.Free();
    request.Free();
  end;
end;

class function TMessagesTests.GetMyEmail: string;
var
  request: TUsersGetProfileRequest;
  response: TProfile;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.GetProfile('me');
    response := request.Execute();
    Result := response.EmailAddress;
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TMessagesTests.TestBatchDelete;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-msg-batchdelete';

  msg =
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'Batch delete from gmail api for Delphi'#$D#$A;

var
  insert_request: TMessagesInsertRequest;
  delete_request: TMessagesBatchDeleteRequest;
  batch_content: TBatchDeleteMessagesRequest;
  content, response: TMessage;
  myEmail: string;
begin
  myEmail := GetMyEmail();

  insert_request := nil;
  delete_request := nil;
  response := nil;
  try
    content := TMessage.Create();
    insert_request := GetService().Users.Messages.Insert('me', content);

    content.Raw := TBase64UrlEncoder.Encode(msg);
    insert_request.InternalDateSource := miReceivedTime;
    response := insert_request.Execute();

    batch_content := TBatchDeleteMessagesRequest.Create();

    batch_content.Ids := TArray<string>.Create(response.Id);

    delete_request := GetService().Users.Messages.BatchDelete('me', batch_content);
    delete_request.Execute();

    CheckEquals('', GetMessageId(subj));
  finally
    response.Free();
    delete_request.Free();
    insert_request.Free();
  end;
end;

procedure TMessagesTests.TestBatchModify;
var
  request: TMessagesBatchModifyRequest;
  id: string;
  content: TBatchModifyMessagesRequest;
begin
  request := nil;
  try
    id := GetMessageId();

    content := TBatchModifyMessagesRequest.Create();
    request := GetService().Users.Messages.BatchModify('me', content);
    content.Ids := TArray<string>.Create(id);
    content.AddLabelIds := TArray<string>.Create('TRASH');
    content.RemoveLabelIds := TArray<string>.Create('INBOX');
    request.Execute();
    FreeAndNil(request);

    content := TBatchModifyMessagesRequest.Create();
    request := GetService().Users.Messages.BatchModify('me', content);
    content.Ids := TArray<string>.Create(id);
    content.AddLabelIds := TArray<string>.Create('INBOX');
    content.RemoveLabelIds := TArray<string>.Create('TRASH');
    request.Execute();
    FreeAndNil(request);
  finally
    request.Free();
  end;
end;

procedure TMessagesTests.TestGet;
var
  request: TMessagesGetRequest;
  response: TMessage;
  id: string;
begin
  request := nil;
  response := nil;
  try
    id := GetMessageId();

    request := GetService().Users.Messages.Get('me', id);

    //full
    request.Format := mfFull;
    request.MetadataHeaders := nil;

    response := request.Execute();

    CheckEquals(id, response.Id);
    Check(response.Payload <> nil);
    CheckEquals('', response.Raw);

    Check(Length(response.Payload.Headers) > 0);
    Check(response.Payload.Body <> nil);

    //raw
    request.Format := mfRaw;
    request.MetadataHeaders := nil;

    response := request.Execute();

    CheckEquals(id, response.Id);
    Check(response.Payload = nil);
    CheckNotEquals('', response.Raw);

    //metadata
    request.Format := mfMetadata;
    request.MetadataHeaders := TArray<string>.Create('SUBJECT', 'FROM');

    response := request.Execute();

    CheckEquals(id, response.Id);
    Check(response.Payload <> nil);
    CheckEquals('', response.Raw);

    CheckEquals(2, Length(response.Payload.Headers));
    CheckNotEquals('', response.Payload.Headers[0].Value);
    Check(response.Payload.Body = nil);
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TMessagesTests.TestImport;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-msg-import';

  msg =
'From: %s'#$D#$A +
'To: %s'#$D#$A +
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'Import from gmail api for Delphi'#$D#$A;

var
  import_request: TMessagesImportRequest;
  delete_request: TMessagesDeleteRequest;
  content, response: TMessage;
  myEmail: string;
begin
  myEmail := GetMyEmail();

  import_request := nil;
  delete_request := nil;
  response := nil;
  try
    content := TMessage.Create();
    import_request := GetService().Users.Messages.Import('me', content);
    import_request.InternalDateSource := miReceivedTime;
    import_request.NeverMarkSpam := True;

    content.Raw := TBase64UrlEncoder.Encode(Format(msg, [myEmail, myEmail]));
    response := import_request.Execute();
    CheckEquals(response.Id, GetMessageId(subj));

    delete_request := GetService().Users.Messages.Delete('me', response.Id);
    delete_request.Execute();

    CheckEquals('', GetMessageId(subj));
  finally
    response.Free();
    delete_request.Free();
    import_request.Free();
  end;
end;

procedure TMessagesTests.TestInsert;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-msg-insert';

  msg =
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'Insert from gmail api for Delphi'#$D#$A;

var
  insert_request: TMessagesInsertRequest;
  delete_request: TMessagesDeleteRequest;
  content, response: TMessage;
  myEmail: string;
begin
  myEmail := GetMyEmail();

  insert_request := nil;
  delete_request := nil;
  response := nil;
  try
    content := TMessage.Create();
    insert_request := GetService().Users.Messages.Insert('me', content);

    content.Raw := TBase64UrlEncoder.Encode(msg);
    insert_request.InternalDateSource := miReceivedTime;
    response := insert_request.Execute();
    CheckEquals(response.Id, GetMessageId(subj));

    delete_request := GetService().Users.Messages.Delete('me', response.Id);
    delete_request.Execute();

    CheckEquals('', GetMessageId(subj));
  finally
    response.Free();
    delete_request.Free();
    insert_request.Free();
  end;
end;

procedure TMessagesTests.TestList;
var
  request: TMessagesListRequest;
  response: TMessages;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.Messages.List('me');
    request.MaxResults := 2;
    request.LabelIds := TArray<string>.Create('INBOX');

    response := request.Execute();

    CheckEquals(2, Length(response.Messages));

    CheckNotEquals('', response.Messages[0].Id);
    CheckNotEquals('', response.Messages[0].ThreadId);

    CheckNotEquals(response.Messages[0].Id, response.Messages[1].Id);
    CheckNotEquals(response.Messages[0].ThreadId, response.Messages[1].ThreadId);
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TMessagesTests.TestModify;
var
  request: TMessagesModifyRequest;
  response: TMessage;
  id: string;
  ind: Integer;
  arr: TArray<string>;
  content: TModifyMessageRequest;
begin
  request := nil;
  response := nil;
  try
    id := GetMessageId();

    content := TModifyMessageRequest.Create();
    request := GetService().Users.Messages.Modify('me', id, content);
    content.AddLabelIds := TArray<string>.Create('TRASH');
    content.RemoveLabelIds := TArray<string>.Create('INBOX');
    response := request.Execute();
    arr := response.LabelIds;
    TArray.Sort<string>(arr, TStringComparer.Ordinal);
    CheckTrue(TArray.BinarySearch<string>(arr, 'TRASH', ind));
    CheckFalse(TArray.BinarySearch<string>(arr, 'INBOX', ind));
    FreeAndNil(response);
    FreeAndNil(request);

    content := TModifyMessageRequest.Create();
    request := GetService().Users.Messages.Modify('me', id, content);
    content.AddLabelIds := TArray<string>.Create('INBOX');
    content.RemoveLabelIds := TArray<string>.Create('TRASH');
    response := request.Execute();
    arr := response.LabelIds;
    TArray.Sort<string>(arr, TStringComparer.Ordinal);
    CheckFalse(TArray.BinarySearch<string>(arr, 'TRASH', ind));
    CheckTrue(TArray.BinarySearch<string>(arr, 'INBOX', ind));
    FreeAndNil(response);
    FreeAndNil(request);
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TMessagesTests.TestSend;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-msg-send';

  msg =
'From: %s'#$D#$A +
'To: %s'#$D#$A +
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'Hello from gmail api for Delphi'#$D#$A;

var
  send_request: TMessagesSendRequest;
  delete_request: TMessagesDeleteRequest;
  content, response: TMessage;
  myEmail: string;
begin
  myEmail := GetMyEmail();

  send_request := nil;
  delete_request := nil;
  response := nil;
  try
    content := TMessage.Create();
    send_request := GetService().Users.Messages.Send('me', content);

    content.Raw := TBase64UrlEncoder.Encode(Format(msg, [myEmail, myEmail]));
    response := send_request.Execute();
    CheckEquals(response.Id, GetMessageId(subj));

    delete_request := GetService().Users.Messages.Delete('me', response.Id);
    delete_request.Execute();

    CheckEquals('', GetMessageId(subj));
  finally
    response.Free();
    delete_request.Free();
    send_request.Free();
  end;
end;

procedure TMessagesTests.TestTrash;
var
  request: TMessagesTrashRequest;
  response: TMessage;
  id: string;
  ind: Integer;
  arr: TArray<string>;
begin
  request := nil;
  response := nil;
  try
    id := GetMessageId();

    request := GetService().Users.Messages.Trash('me', id);
    response := request.Execute();
    arr := response.LabelIds;
    TArray.Sort<string>(arr, TStringComparer.Ordinal);
    CheckTrue(TArray.BinarySearch<string>(arr, 'TRASH', ind));
    FreeAndNil(response);
    FreeAndNil(request);

    request := GetService().Users.Messages.Untrash('me', id);
    response := request.Execute();
    arr := response.LabelIds;
    TArray.Sort<string>(arr, TStringComparer.Ordinal);
    CheckFalse(TArray.BinarySearch<string>(arr, 'TRASH', ind));
    FreeAndNil(response);
    FreeAndNil(request);
  finally
    response.Free();
    request.Free();
  end;
end;

{ TUsersTests }

procedure TUsersTests.TestGetProfile;
var
  request: TUsersGetProfileRequest;
  response: TProfile;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.GetProfile('me');

    response := request.Execute();

    CheckNotEquals('', response.EmailAddress);
    CheckNotEquals('', response.MessagesTotal);
    CheckNotEquals('', response.ThreadsTotal);
    CheckNotEquals('', response.HistoryId);
  finally
    response.Free();
    request.Free();
  end;
end;

{ TDraftsTests }

function TDraftsTests.CreateDraft(const AMsg: string): string;
var
  request: TDraftsCreateRequest;
  response: TDraft;
  ind: Integer;
  arr: TArray<string>;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.Drafts.Create_('me', TDraft.Create());

    request.Content.Message_ := TMessage.Create();
    request.Content.Message_.Raw := TBase64UrlEncoder.Encode(AMsg);
    response := request.Execute();
    CheckNotEquals('', response.Id);

    arr := response.Message_.LabelIds;
    TArray.Sort<string>(arr, TStringComparer.Ordinal);
    CheckTrue(TArray.BinarySearch<string>(arr, 'DRAFT', ind));

    Result := response.Id;
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TDraftsTests.TestDelete;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-draft-create';

  msg =
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'Create draft from gmail api for Delphi'#$D#$A;

var
  request: TDraftsDeleteRequest;
  id: string;
begin
  request := nil;
  try
    id := CreateDraft(msg);
    request := GetService().Users.Drafts.Delete('me', id);
    request.Execute();
  finally
    request.Free();
  end;
end;

procedure TDraftsTests.TestGet;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-draft-get';

  msg =
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'Get draft from gmail api for Delphi'#$D#$A;

var
  get_request: TDraftsGetRequest;
  delete_request: TDraftsDeleteRequest;
  response: TDraft;
  id: string;
begin
  get_request := nil;
  delete_request := nil;
  response := nil;
  try
    id := CreateDraft(msg);

    get_request := GetService().Users.Drafts.Get('me', id);
    get_request.Format := mfRaw;
    response := get_request.Execute();
    CheckEquals(id, response.Id);
    CheckTrue(nil <> response.Message_);
    CheckNotEquals('', response.Message_.Raw);
    FreeAndNil(response);

    delete_request := GetService().Users.Drafts.Delete('me', id);
    delete_request.Execute();
  finally
    response.Free();
    delete_request.Free();
    get_request.Free();
  end;
end;

procedure TDraftsTests.TestList;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-draft-list';

  msg =
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'List drafts from gmail api for Delphi'#$D#$A;

var
  list_request: TDraftsListRequest;
  delete_request: TDraftsDeleteRequest;
  create_response: TDraft;
  list_response: TDrafts;
  id: string;
begin
  list_request := nil;
  delete_request := nil;
  create_response := nil;
  list_response := nil;
  try
    id := CreateDraft(msg);

    list_request := GetService().Users.Drafts.List('me');
    list_request.Q := 'subject:' + subj;
    list_response := list_request.Execute();
    CheckEquals(1, Length(list_response.Drafts));
    CheckEquals(id, list_response.Drafts[0].Id);
    FreeAndNil(list_response);

    delete_request := GetService().Users.Drafts.Delete('me', id);
    delete_request.Execute();
  finally
    list_response.Free();
    create_response.Free();
    delete_request.Free();
    list_request.Free();
  end;
end;

procedure TDraftsTests.TestSend;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-draft-send';

  msg =
'From: %s'#$D#$A +
'To: %s'#$D#$A +
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'Send draft from gmail api for Delphi'#$D#$A;

var
  send_request: TDraftsSendRequest;
  delete_request: TMessagesDeleteRequest;
  response: TMessage;
  id, myEmail: string;
begin
  myEmail := TMessagesTests.GetMyEmail();

  send_request := nil;
  delete_request := nil;
  response := nil;
  try
    id := CreateDraft(Format(msg, [myEmail, myEmail]));

    send_request := GetService().Users.Drafts.Send('me', TDraft.Create());
    send_request.Content.Id := id;
    response := send_request.Execute();

    id := TMessagesTests.GetMessageId(subj);
    CheckEquals(response.Id, id);

    delete_request := GetService().Users.Messages.Delete('me', id);
    delete_request.Execute();
  finally
    response.Free();
    delete_request.Free();
    send_request.Free();
  end;
end;

procedure TDraftsTests.TestUpdate;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-draft-update';

  msg =
'Subject: ' + subj + #$D#$A +
'MIME-Version: 1.0'#$D#$A +
'Content-Type: text/plain'#$D#$A +
#$D#$A +
'Update draft from gmail api for Delphi'#$D#$A;

var
  update_request: TDraftsUpdateRequest;
  get_request: TDraftsGetRequest;
  delete_request: TDraftsDeleteRequest;
  response: TDraft;
  id, raw: string;
begin
  update_request := nil;
  get_request := nil;
  delete_request := nil;
  response := nil;
  try
    id := CreateDraft(msg);

    update_request := GetService().Users.Drafts.Update('me', id, TDraft.Create());
    update_request.Content.Message_ := TMessage.Create();
    update_request.Content.Message_.Raw := TBase64UrlEncoder.Encode(msg + 'MODIFIED'#$D#$A);
    response := update_request.Execute();
    CheckEquals(id, response.Id);
    FreeAndNil(response);

    get_request := GetService().Users.Drafts.Get('me', id);
    get_request.Format := mfRaw;
    response := get_request.Execute();
    CheckTrue(nil <> response.Message_);
    raw := TBase64UrlEncoder.Decode(response.Message_.Raw);
    CheckTrue(Pos('MODIFIED', raw) > 0);
    FreeAndNil(response);

    delete_request := GetService().Users.Drafts.Delete('me', id);
    delete_request.Execute();
  finally
    response.Free();
    delete_request.Free();
    get_request.Free();
    update_request.Free();
  end;
end;

initialization
  TestFramework.RegisterTest(TUsersTests.Suite);
  TestFramework.RegisterTest(TLabelsTests.Suite);
  TestFramework.RegisterTest(TMessagesTests.Suite);
  TestFramework.RegisterTest(TDraftsTests.Suite);

finalization
  Service.Free();

end.
