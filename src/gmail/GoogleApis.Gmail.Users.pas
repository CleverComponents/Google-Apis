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

unit GoogleApis.Gmail.Users;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs, GoogleApis, GoogleApis.Gmail.Data,
  GoogleApis.Gmail.Core, GoogleApis.Gmail.Labels, GoogleApis.Gmail.Messages,
  GoogleApis.Gmail.Drafts;

type
  TUsersGetProfileRequest = class(TServiceRequest<TProfile>)
  strict private
    FUserId: string;
  public
    constructor Create(AService: TService; const AUserId: string);

    function Execute: TProfile; override;

    property UserId: string read FUserId;
  end;

  TUsersResource = class(TGmailResource)
  strict private
    FLabels: TLabelsResource;
    FMessages: TMessagesResource;

    function GetLabels: TLabelsResource;
    function GetMessages: TMessagesResource;
  strict
  private
    function GetDrafts: TDraftsResource; protected
    function CreateLabels: TLabelsResource; virtual;
    function CreateMessages: TMessagesResource; virtual;
  public
    constructor Create(AService: TService);
    destructor Destroy; override;

    function GetProfile(const AUserId: string): TUsersGetProfileRequest; virtual;
    //function stop
    //function watch

    property Drafts: TDraftsResource read GetDrafts;
    //property History
    property Labels: TLabelsResource read GetLabels;
    property Messages: TMessagesResource read GetMessages;
    //property Settings
    //property Threads
  end;

implementation

{ TUsersGetProfileRequest }

constructor TUsersGetProfileRequest.Create(AService: TService; const AUserId: string);
begin
  inherited Create(AService);
  FUserId := AUserId;
end;

function TUsersGetProfileRequest.Execute: TProfile;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    response := Service.Initializer.HttpClient.Get('https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/profile', params);
    Result := TProfile(Service.Initializer.JsonSerializer.JsonToObject(TProfile, response));
  finally
    params.Free();
  end;
end;

{ TUsersResource }

constructor TUsersResource.Create(AService: TService);
begin
  inherited Create(AService);

  FLabels := nil;
  FMessages := nil;
end;

function TUsersResource.CreateLabels: TLabelsResource;
begin
  Result := TLabelsResource.Create(Service);
end;

function TUsersResource.CreateMessages: TMessagesResource;
begin
  Result := TMessagesResource.Create(Service);
end;

destructor TUsersResource.Destroy;
begin
  FreeAndNil(FMessages);
  FreeAndNil(FLabels);

  inherited Destroy();
end;

function TUsersResource.GetDrafts: TDraftsResource;
begin
  Result := TDraftsResource.Create(Service);
end;

function TUsersResource.GetLabels: TLabelsResource;
begin
  if (FLabels = nil) then
  begin
    FLabels := CreateLabels();
  end;
  Result := FLabels;
end;

function TUsersResource.GetMessages: TMessagesResource;
begin
  if (FMessages = nil) then
  begin
    FMessages := CreateMessages();
  end;
  Result := FMessages;
end;

function TUsersResource.GetProfile(const AUserId: string): TUsersGetProfileRequest;
begin
  Result := TUsersGetProfileRequest.Create(Service, AUserId);
end;

end.
