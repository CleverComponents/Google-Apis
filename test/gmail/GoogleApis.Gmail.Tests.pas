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
  System.Classes, System.SysUtils, System.Generics.Collections, TestFramework,
  GoogleApis, GoogleApis.Persister, GoogleApis.Gmail, GoogleApis.Gmail.Data;

type
  TLabelsTests = class(TTestCase)
  strict private
    class var Service: TGmailService;

    class constructor Create;
    class destructor Destroy;
    function GetService: TGmailService;
  published
    procedure TestList;
    procedure TestGet;
    procedure TestModify;
  end;

  TMessagesTests = class(TTestCase)
  strict private
    class var Service: TGmailService;

    class constructor Create;
    class destructor Destroy;
    function GetService: TGmailService;
    function GetMessageId: string;
  published
    procedure TestList;
    procedure TestGet;
  end;

implementation

{ TLabelsTests }

class constructor TLabelsTests.Create;
begin
  Service := nil;
end;

class destructor TLabelsTests.Destroy;
begin
  Service.Free();
end;

function TLabelsTests.GetService: TGmailService;
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
    credential.Scope := GmailLabels;
  end;
  Result := Service;
end;

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

class constructor TMessagesTests.Create;
begin
  Service := nil;
end;

class destructor TMessagesTests.Destroy;
begin
  Service.Free();
end;

function TMessagesTests.GetMessageId: string;
var
  request: TMessagesListRequest;
  response: TMessages;
begin
  request := nil;
  response := nil;
  try
    request := GetService().Users.Messages.List('me');
    request.MaxResults := 1;

    response := request.Execute();

    Result := response.Messages[0].Id;
  finally
    response.Free();
    request.Free();
  end;
end;

function TMessagesTests.GetService: TGmailService;
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
    credential.Scope := GmailReadonly;
  end;
  Result := Service;
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

initialization
  TestFramework.RegisterTest(TLabelsTests.Suite);
  TestFramework.RegisterTest(TMessagesTests.Suite);

end.
