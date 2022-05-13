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
  GoogleApis.Gmail.Core, GoogleApis.Gmail.Messages;

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

  TDraftsGetRequest = class(TServiceRequest<TDraft>)
  strict private
    FUserId: string;
    FId: string;
    FFormat: TFormat;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: TDraft; override;

    property UserId: string read FUserId;
    property Id: string read FId;

    property Format: TFormat read FFormat write FFormat;
  end;

  TDraftsUpdateRequest = class(TServiceRequest<TDraft>)
  strict private
    FUserId: string;
    FId: string;
    FContent: TDraft;
  public
    constructor Create(AService: TService; const AUserId, AId: string; AContent: TDraft);
    destructor Destroy; override;

    function Execute: TDraft; override;

    property UserId: string read FUserId;
    property Id: string read FId;
    property Content: TDraft read FContent;
  end;

  TDraftsListRequest = class(TServiceRequest<TDraftsResponse>)
  strict private
    FIncludeSpamTrash: Boolean;
    FUserId: string;
    FPageToken: string;
    FMaxResults: Integer;
    FQ: string;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId: string);

    function Execute: TDraftsResponse; override;

    property UserId: string read FUserId;

    property MaxResults: Integer read FMaxResults write FMaxResults;
    property PageToken: string read FPageToken write FPageToken;
    property Q: string read FQ write FQ;
    property IncludeSpamTrash: Boolean read FIncludeSpamTrash write FIncludeSpamTrash;
  end;

  TDraftsSendRequest = class(TServiceRequest<TMessage>)
  private
    FUserId: string;
    FContent: TDraft;
  public
    constructor Create(AService: TService; const AUserId: string; AContent: TDraft);
    destructor Destroy; override;

    function Execute: TMessage; override;

    property UserId: string read FUserId;
    property Content: TDraft read FContent;
  end;

  TDraftsResource = class(TGmailResource)
  public
    function Create_(const AUserId: string; AContent: TDraft): TDraftsCreateRequest; virtual;
    function Delete(const AUserId, AId: string): TDraftsDeleteRequest; virtual;
    function Get(const AUserId, AId: string): TDraftsGetRequest; virtual;
    function List(const AUserId: string): TDraftsListRequest; virtual;
    function Send(const AUserId: string; AContent: TDraft): TDraftsSendRequest; virtual;
    function Update(const AUserId, AId: string; AContent: TDraft): TDraftsUpdateRequest; virtual;
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

function TDraftsResource.Get(const AUserId, AId: string): TDraftsGetRequest;
begin
  Result := TDraftsGetRequest.Create(Service, AUserId, AId);
end;

function TDraftsResource.List(const AUserId: string): TDraftsListRequest;
begin
  Result := TDraftsListRequest.Create(Service, AUserId);
end;

function TDraftsResource.Send(const AUserId: string; AContent: TDraft): TDraftsSendRequest;
begin
  Result := TDraftsSendRequest.Create(Service, AUserId, AContent);
end;

function TDraftsResource.Update(const AUserId, AId: string; AContent: TDraft): TDraftsUpdateRequest;
begin
  Result := TDraftsUpdateRequest.Create(Service, AUserId, AId, AContent);
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

{ TDraftsGetRequest }

constructor TDraftsGetRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TDraftsGetRequest.Execute: TDraft;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    response := Service.Initializer.HttpClient.Get(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/drafts/' + Id, params);
    Result := TDraft(Service.Initializer.JsonSerializer.JsonToObject(TDraft, response));
  finally
    params.Free();
  end;
end;

procedure TDraftsGetRequest.FillParams(AParams: THttpRequestParameterList);
begin
  AParams.Add('format', FormatNames[Format]);
end;

{ TDraftsUpdateRequest }

constructor TDraftsUpdateRequest.Create(AService: TService; const AUserId, AId: string; AContent: TDraft);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
  FContent := AContent;
end;

destructor TDraftsUpdateRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TDraftsUpdateRequest.Execute: TDraft;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Put(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/drafts/' + Id, params, request);

    Result := TDraft(Service.Initializer.JsonSerializer.JsonToObject(TDraft, response));
  finally
    params.Free();
  end;
end;

{ TDraftsListRequest }

constructor TDraftsListRequest.Create(AService: TService; const AUserId: string);
begin
  inherited Create(AService);
  FUserId := AUserId;
end;

function TDraftsListRequest.Execute: TDraftsResponse;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    response := Service.Initializer.HttpClient.Get(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/drafts', params);
    Result := TDraftsResponse(Service.Initializer.JsonSerializer.JsonToObject(TDraftsResponse, response));
  finally
    params.Free();
  end;
end;

procedure TDraftsListRequest.FillParams(AParams: THttpRequestParameterList);
begin
  AParams.Add('maxResults', maxResults);
  AParams.Add('pageToken', PageToken);
  AParams.Add('q', Q);
  AParams.Add('includeSpamTrash', IncludeSpamTrash);
end;

{ TDraftsSendRequest }

constructor TDraftsSendRequest.Create(AService: TService; const AUserId: string; AContent: TDraft);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FContent := AContent;
end;

destructor TDraftsSendRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TDraftsSendRequest.Execute: TMessage;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/drafts/send', params, request);

    Result := TMessage(Service.Initializer.JsonSerializer.JsonToObject(TMessage, response));
  finally
    params.Free();
  end;
end;

end.
