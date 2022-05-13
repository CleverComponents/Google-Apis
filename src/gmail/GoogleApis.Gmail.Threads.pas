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

unit GoogleApis.Gmail.Threads;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs, GoogleApis, GoogleApis.Gmail.Data,
  GoogleApis.Gmail.Core, GoogleApis.Gmail.Messages;

type
  TThreadsListRequest = class(TServiceRequest<TThreadsResponse>)
  strict private
    FIncludeSpamTrash: Boolean;
    FUserId: string;
    FPageToken: string;
    FLabelIds: TArray<string>;
    FMaxResults: Integer;
    FQ: string;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId: string);

    function Execute: TThreadsResponse; override;

    property UserId: string read FUserId;

    property MaxResults: Integer read FMaxResults write FMaxResults;
    property PageToken: string read FPageToken write FPageToken;
    property Q: string read FQ write FQ;
    property LabelIds: TArray<string> read FLabelIds write FLabelIds;
    property IncludeSpamTrash: Boolean read FIncludeSpamTrash write FIncludeSpamTrash;
  end;

  TThreadsTrashRequest = class(TServiceRequest<TThread>)
  strict private
    FUserId: string;
    FId: string;
  strict protected
    function GetUrl: string; virtual;
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: TThread; override;

    property UserId: string read FUserId;
    property Id: string read FId;
  end;

  TThreadsUntrashRequest = class(TThreadsTrashRequest)
  strict protected
    function GetUrl: string; override;
  end;

  TThreadsModifyRequest = class(TServiceRequest<TThread>)
  strict private
    FUserId: string;
    FId: string;
    FContent: TModifyThreadRequest;
  public
    constructor Create(AService: TService; const AUserId, AId: string; AContent: TModifyThreadRequest);
    destructor Destroy; override;

    function Execute: TThread; override;

    property UserId: string read FUserId;
    property Id: string read FId;
    property Content: TModifyThreadRequest read FContent;
  end;

  TThreadsGetRequest = class(TServiceRequest<TThread>)
  strict private
    FUserId: string;
    FId: string;
    FFormat: TFormat;
    FMetadataHeaders: TArray<string>;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: TThread; override;

    property UserId: string read FUserId;
    property Id: string read FId;

    property Format: TFormat read FFormat write FFormat;
    property MetadataHeaders: TArray<string> read FMetadataHeaders write FMetadataHeaders;
  end;

  TThreadsDeleteRequest = class(TServiceRequest<Boolean>)
  strict private
    FUserId: string;
    FId: string;
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: Boolean; override;

    property UserId: string read FUserId;
    property Id: string read FId;
  end;

  TThreadsResource = class(TGmailResource)
  public
    function Delete(const AUserId, AId: string): TThreadsDeleteRequest; virtual;
    function Get(const AUserId, AId: string): TThreadsGetRequest; virtual;
    function List(const AUserId: string): TThreadsListRequest; virtual;
    function Modify(const AUserId, AId: string;
      AContent: TModifyThreadRequest): TThreadsModifyRequest; virtual;
    function Trash(const AUserId, AId: string): TThreadsTrashRequest; virtual;
    function Untrash(const AUserId, AId: string): TThreadsUntrashRequest; virtual;
  end;

implementation

{ TThreadsResource }

function TThreadsResource.Delete(const AUserId, AId: string): TThreadsDeleteRequest;
begin
  Result := TThreadsDeleteRequest.Create(Service, AUserId, AId);
end;

function TThreadsResource.Get(const AUserId, AId: string): TThreadsGetRequest;
begin
  Result := TThreadsGetRequest.Create(Service, AUserId, AId);
end;

function TThreadsResource.List(const AUserId: string): TThreadsListRequest;
begin
  Result := TThreadsListRequest.Create(Service, AUserId);
end;

function TThreadsResource.Modify(const AUserId, AId: string;
  AContent: TModifyThreadRequest): TThreadsModifyRequest;
begin
  Result := TThreadsModifyRequest.Create(Service, AUserId, AId, AContent);
end;

function TThreadsResource.Trash(const AUserId, AId: string): TThreadsTrashRequest;
begin
  Result := TThreadsTrashRequest.Create(Service, AUserId, AId);
end;

function TThreadsResource.Untrash(const AUserId, AId: string): TThreadsUntrashRequest;
begin
  Result := TThreadsUntrashRequest.Create(Service, AUserId, AId);
end;

{ TThreadsListRequest }

constructor TThreadsListRequest.Create(AService: TService; const AUserId: string);
begin
  inherited Create(AService);
  FUserId := AUserId;
end;

function TThreadsListRequest.Execute: TThreadsResponse;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    response := Service.Initializer.HttpClient.Get(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/threads', params);
    Result := TThreadsResponse(Service.Initializer.JsonSerializer.JsonToObject(TThreadsResponse, response));
  finally
    params.Free();
  end;
end;

procedure TThreadsListRequest.FillParams(AParams: THttpRequestParameterList);
var
  id: string;
begin
  AParams.Add('maxResults', MaxResults);
  AParams.Add('pageToken', PageToken);
  AParams.Add('q', Q);

  if (LabelIds <> nil) then
  begin
    for id in LabelIds do
    begin
      AParams.Add('labelIds', id);
    end;
  end;

  AParams.Add('includeSpamTrash', IncludeSpamTrash);
end;

{ TThreadsTrashRequest }

constructor TThreadsTrashRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TThreadsTrashRequest.Execute: TThread;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    response := Service.Initializer.HttpClient.Post(GetUrl(), params, '');

    Result := TThread(Service.Initializer.JsonSerializer.JsonToObject(TThread, response));
  finally
    params.Free();
  end;
end;

function TThreadsTrashRequest.GetUrl: string;
begin
  Result := 'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/threads/' + Id + '/trash';
end;

{ TThreadsUntrashRequest }

function TThreadsUntrashRequest.GetUrl: string;
begin
  Result := 'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/threads/' + Id + '/untrash';
end;

{ TThreadsModifyRequest }

constructor TThreadsModifyRequest.Create(AService: TService; const AUserId,
  AId: string; AContent: TModifyThreadRequest);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
  FContent := AContent;
end;

destructor TThreadsModifyRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TThreadsModifyRequest.Execute: TThread;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/threads/' + Id + '/modify', params, request);

    Result := TThread(Service.Initializer.JsonSerializer.JsonToObject(TThread, response));
  finally
    params.Free();
  end;
end;

{ TThreadsGetRequest }

constructor TThreadsGetRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TThreadsGetRequest.Execute: TThread;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    response := Service.Initializer.HttpClient.Get(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/threads/' + Id, params);
    Result := TThread(Service.Initializer.JsonSerializer.JsonToObject(TThread, response));
  finally
    params.Free();
  end;
end;

procedure TThreadsGetRequest.FillParams(AParams: THttpRequestParameterList);
var
  hdr: string;
begin
  AParams.Add('format', FormatNames[Format]);

  if (MetadataHeaders <> nil) then
  begin
    for hdr in MetadataHeaders do
    begin
      AParams.Add('metadataHeaders', hdr);
    end;
  end;
end;

{ TThreadsDeleteRequest }

constructor TThreadsDeleteRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TThreadsDeleteRequest.Execute: Boolean;
begin
  Service.Initializer.HttpClient.Delete(
    'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/threads/' + Id);
  Result := True;
end;

end.
