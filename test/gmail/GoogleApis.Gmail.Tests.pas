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
    procedure TestLabelList;
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

procedure TLabelsTests.TestLabelList;
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

initialization
  TestFramework.RegisterTest(TLabelsTests.Suite);

end.