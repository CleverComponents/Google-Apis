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
  GoogleApis.Gmail.Drafts, GoogleApis.Gmail.History, GoogleApis.Gmail.Threads;

type
  TGmailUsersTests = class(TTestCase)
  published
    procedure TestGetProfile;
  end;

  TGmailLabelsTests = class(TTestCase)
  published
    procedure TestList;
    procedure TestGet;
    procedure TestModify;
  end;

  TGmailMessagesTests = class(TTestCase)
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

  TGmailDraftsTests = class(TTestCase)
  strict private
    function CreateDraft(const AMsg: string): string;
  published
    procedure TestDelete;
    procedure TestGet;
    procedure TestUpdate;
    procedure TestList;
    procedure TestSend;
  end;

  TGmailHistoryTests = class(TTestCase)
  strict private
    function GetMessage: TMessage;
  published
    procedure TestList;
  end;

  TGmailThreadsTests = class(TTestCase)
  strict private
    function GetThreadId(const ASubject: string = ''): string;
  published
    procedure TestGet;
    procedure TestList;
    procedure TestTrash;
    procedure TestModify;
    procedure TestDelete;
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
    initializer := TGoogleApisServiceInitializer.Create(credential, 'CleverComponents Gmail test');
    Service := TGmailService.Create(initializer);

    credential.ClientID := '421475025220-6khpgoldbdsi60fegvjdqk2bk4v19ss2.apps.googleusercontent.com';
    credential.ClientSecret := '_4HJyAVUmH_iVrPB8pOJXjR1';
    credential.Scope := MailGoogleCom + ' ' + GMailLabels + ' ' + GmailReadonly + ' ' + GmailSend;
  end;
  Result := Service;
end;

{ TGmailLabelsTests }

procedure TGmailLabelsTests.TestGet;
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

procedure TGmailLabelsTests.TestList;
var
  request: TLabelsListRequest;
  response: TLabelsResponse;
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

procedure TGmailLabelsTests.TestModify;
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

{ TGmailMessagesTests }

class function TGmailMessagesTests.GetMessageId(const ASubject: string): string;
var
  request: TMessagesListRequest;
  response: TMessagesResponse;
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

class function TGmailMessagesTests.GetMyEmail: string;
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

procedure TGmailMessagesTests.TestBatchDelete;
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

procedure TGmailMessagesTests.TestBatchModify;
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

procedure TGmailMessagesTests.TestGet;
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
    FreeAndNil(response);

    //raw
    request.Format := mfRaw;
    request.MetadataHeaders := nil;
    response := request.Execute();
    CheckEquals(id, response.Id);
    Check(response.Payload = nil);
    CheckNotEquals('', response.Raw);
    FreeAndNil(response);

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
    FreeAndNil(response);
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TGmailMessagesTests.TestImport;
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

procedure TGmailMessagesTests.TestInsert;
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

procedure TGmailMessagesTests.TestList;
var
  request: TMessagesListRequest;
  response: TMessagesResponse;
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

procedure TGmailMessagesTests.TestModify;
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

procedure TGmailMessagesTests.TestSend;
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

    Sleep(2000);
    delete_request := GetService().Users.Messages.Delete('me', response.Id);
    delete_request.Execute();

    Sleep(2000);
    CheckEquals('', GetMessageId(subj));
  finally
    response.Free();
    delete_request.Free();
    send_request.Free();
  end;
end;

procedure TGmailMessagesTests.TestTrash;
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

{ TGmailUsersTests }

procedure TGmailUsersTests.TestGetProfile;
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

{ TGmailDraftsTests }

function TGmailDraftsTests.CreateDraft(const AMsg: string): string;
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

procedure TGmailDraftsTests.TestDelete;
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

procedure TGmailDraftsTests.TestGet;
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

procedure TGmailDraftsTests.TestList;
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
  list_response: TDraftsResponse;
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

procedure TGmailDraftsTests.TestSend;
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
  myEmail := TGmailMessagesTests.GetMyEmail();

  send_request := nil;
  delete_request := nil;
  response := nil;
  try
    id := CreateDraft(Format(msg, [myEmail, myEmail]));

    send_request := GetService().Users.Drafts.Send('me', TDraft.Create());
    send_request.Content.Id := id;
    response := send_request.Execute();

    id := TGmailMessagesTests.GetMessageId(subj);
    CheckEquals(response.Id, id);

    Sleep(2000);

    delete_request := GetService().Users.Messages.Delete('me', id);
    delete_request.Execute();
  finally
    response.Free();
    delete_request.Free();
    send_request.Free();
  end;
end;

procedure TGmailDraftsTests.TestUpdate;
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

{ TGmailHistoryTests }

function TGmailHistoryTests.GetMessage: TMessage;
var
  list_request: TMessagesListRequest;
  list_response: TMessagesResponse;
  get_request: TMessagesGetRequest;
begin
  list_request := nil;
  list_response := nil;
  get_request := nil;
  Result := nil;
  try
    list_request := GetService().Users.Messages.List('me');
    list_request.MaxResults := 1;

    list_response := list_request.Execute();

    if (Length(list_response.Messages) <> 1) then Exit(nil);

    get_request := GetService().Users.Messages.Get('me', list_response.Messages[0].Id);
    get_request.Format := mfFull;

    try
      Result := get_request.Execute();
    except
      Result.Free();
      raise;
    end;

  finally
    get_request.Free();
    list_response.Free();
    list_request.Free();
  end;
end;

procedure TGmailHistoryTests.TestList;
var
  msg: TMessage;
  request: THistoryListRequest;
  response: THistoryResponse;
begin
  request := nil;
  response := nil;
  msg := nil;
  try
    msg := GetMessage();
    CheckFalse(nil = msg);

    request := GetService().Users.History.List('me');
    request.MaxResults := 1;
    request.StartHistoryId := msg.HistoryId;
    request.HistoryTypes := [htMessageAdded, htMessageDeleted, htLabelAdded, htLabelRemoved];

    response := request.Execute();

    CheckNotEquals('', response.HistoryId);
  finally
    msg.Free();
    response.Free();
    request.Free();
  end;
end;

{ TGmailThreadsTests }

function TGmailThreadsTests.GetThreadId(const ASubject: string): string;
var
  request: TThreadsListRequest;
  response: TThreadsResponse;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.Threads.List('me');
    request.MaxResults := 1;

    if (ASubject <> '') then
    begin
      request.Q := 'subject:' + ASubject;
    end;

    response := request.Execute();

    if (Length(response.Threads) = 1) then
    begin
      Result := response.Threads[0].Id;
    end else
    begin
      Result := '';
    end;
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TGmailThreadsTests.TestDelete;
const
  subj = '9CB792EB-611E-4800-B79D-C659EA60DED8-thread-delete';

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
  delete_request: TThreadsDeleteRequest;
  content, response: TMessage;
  myEmail, threadId: string;
begin
  myEmail := TGmailMessagesTests.GetMyEmail();

  send_request := nil;
  delete_request := nil;
  response := nil;
  try
    content := TMessage.Create();
    send_request := GetService().Users.Messages.Send('me', content);

    content.Raw := TBase64UrlEncoder.Encode(Format(msg, [myEmail, myEmail]));
    response := send_request.Execute();

    threadId := GetThreadId(subj);
    CheckNotEquals('', threadId);

    Sleep(2000);

    delete_request := GetService().Users.Threads.Delete('me', threadId);
    delete_request.Execute();

    Sleep(2000);
    CheckEquals('', GetThreadId(subj));
  finally
    response.Free();
    delete_request.Free();
    send_request.Free();
  end;
end;

procedure TGmailThreadsTests.TestGet;
var
  request: TThreadsGetRequest;
  response: TThread;
  id: string;
begin
  request := nil;
  response := nil;
  try
    id := GetThreadId();

    request := GetService().Users.Threads.Get('me', id);

    request.Format := mfFull;
    request.MetadataHeaders := nil;

    response := request.Execute();

    CheckEquals(id, response.Id);
    CheckTrue(Length(response.Messages) > 0);
    CheckEquals('', response.Messages[0].Raw);

    Check(Length(response.Messages[0].Payload.Headers) > 0);
    Check(response.Messages[0].Payload.Body <> nil);
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TGmailThreadsTests.TestList;
var
  request: TThreadsListRequest;
  response: TThreadsResponse;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.Threads.List('me');
    request.MaxResults := 2;
    request.LabelIds := TArray<string>.Create('INBOX');

    response := request.Execute();

    CheckEquals(2, Length(response.Threads));
  finally
    response.Free();
    request.Free();
  end;
end;

procedure TGmailThreadsTests.TestModify;
var
  request: TThreadsModifyRequest;
  response: TThread;
  id: string;
  ind: Integer;
  arr: TArray<string>;
  content: TModifyThreadRequest;
begin
  request := nil;
  response := nil;
  try
    id := GetThreadId();

    content := TModifyThreadRequest.Create();
    request := GetService().Users.Threads.Modify('me', id, content);
    content.AddLabelIds := TArray<string>.Create('TRASH');
    content.RemoveLabelIds := TArray<string>.Create('INBOX');
    response := request.Execute();
    CheckTrue(Length(response.Messages) > 0);
    arr := response.Messages[0].LabelIds;
    TArray.Sort<string>(arr, TStringComparer.Ordinal);
    CheckTrue(TArray.BinarySearch<string>(arr, 'TRASH', ind));
    CheckFalse(TArray.BinarySearch<string>(arr, 'INBOX', ind));
    FreeAndNil(response);
    FreeAndNil(request);

    content := TModifyThreadRequest.Create();
    request := GetService().Users.Threads.Modify('me', id, content);
    content.AddLabelIds := TArray<string>.Create('INBOX');
    content.RemoveLabelIds := TArray<string>.Create('TRASH');
    response := request.Execute();
    CheckTrue(Length(response.Messages) > 0);
    arr := response.Messages[0].LabelIds;
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

procedure TGmailThreadsTests.TestTrash;
var
  request: TThreadsTrashRequest;
  response: TThread;
  id: string;
  ind: Integer;
  arr: TArray<string>;
begin
  request := nil;
  response := nil;
  try
    id := GetThreadId();

    request := GetService().Users.Threads.Trash('me', id);
    response := request.Execute();
    CheckTrue(Length(response.Messages) > 0);
    arr := response.Messages[0].LabelIds;
    TArray.Sort<string>(arr, TStringComparer.Ordinal);
    CheckTrue(TArray.BinarySearch<string>(arr, 'TRASH', ind));
    FreeAndNil(response);
    FreeAndNil(request);

    request := GetService().Users.Threads.Untrash('me', id);
    response := request.Execute();
    CheckTrue(Length(response.Messages) > 0);
    arr := response.Messages[0].LabelIds;
    TArray.Sort<string>(arr, TStringComparer.Ordinal);
    CheckFalse(TArray.BinarySearch<string>(arr, 'TRASH', ind));
    FreeAndNil(response);
    FreeAndNil(request);
  finally
    response.Free();
    request.Free();
  end;
end;

initialization
  TestFramework.RegisterTest(TGmailUsersTests.Suite);
  TestFramework.RegisterTest(TGmailLabelsTests.Suite);
  TestFramework.RegisterTest(TGmailMessagesTests.Suite);
  TestFramework.RegisterTest(TGmailDraftsTests.Suite);
  TestFramework.RegisterTest(TGmailHistoryTests.Suite);
  TestFramework.RegisterTest(TGmailThreadsTests.Suite);

finalization
  Service.Free();

end.
