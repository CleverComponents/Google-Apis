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

unit GoogleApis.Gmail.Drafts;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs, GoogleApis, GoogleApis.Gmail.Data,
  GoogleApis.Gmail.Resource;

type
  TDraftsCreateRequest = class(TServiceRequest<TDraft>)
  strict private
    FUserId: string;
    FContent: TDraft;
  public
    constructor Create(AService: TService; const AUserId: string; AContent: TDraft);
    destructor Destroy; override;

    function Execute: TDraft; override;

    property UserId: string read FUserId;
    property Content: TDraft read FContent;
  end;

  TDraftsDeleteRequest = class(TServiceRequest<Boolean>)
  strict private
    FUserId: string;
    FId: string;
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: Boolean; override;

    property UserId: string read FUserId;
    property Id: string read FId;
  end;

  TDraftsResource = class(TGmailResource)
  public
    function Create_(const AUserId: string; AContent: TDraft): TDraftsCreateRequest; virtual;
    function Delete(const AUserId, AId: string): TDraftsDeleteRequest;
    //function get
    //function list
    //function send
    //function update
  end;

implementation

{ TDraftsResource }

function TDraftsResource.Create_(const AUserId: string; AContent: TDraft): TDraftsCreateRequest;
begin
  Result := TDraftsCreateRequest.Create(Service, AUserId, AContent);
end;

function TDraftsResource.Delete(const AUserId, AId: string): TDraftsDeleteRequest;
begin
  Result := TDraftsDeleteRequest.Create(Service, AUserId, AId);
end;

{ TDraftsCreateRequest }

constructor TDraftsCreateRequest.Create(AService: TService; const AUserId: string; AContent: TDraft);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FContent := AContent;
end;

destructor TDraftsCreateRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TDraftsCreateRequest.Execute: TDraft;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/drafts', params, request);

    Result := TDraft(Service.Initializer.JsonSerializer.JsonToObject(TDraft, response));
  finally
    params.Free();
  end;
end;

{ TDraftsDeleteRequest }

constructor TDraftsDeleteRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TDraftsDeleteRequest.Execute: Boolean;
begin
  Service.Initializer.HttpClient.Delete(
    'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/drafts/' + Id);
  Result := True;
end;

end.
