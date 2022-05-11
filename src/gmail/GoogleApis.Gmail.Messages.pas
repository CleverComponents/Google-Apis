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

unit GoogleApis.Gmail.Messages;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs, GoogleApis, GoogleApis.Gmail.Data,
  GoogleApis.Gmail.Core;

type
  TMessagesListRequest = class(TServiceRequest<TMessages>)
  strict private
    FUserId: string;
    FIncludeSpamTrash: Boolean;
    FPageToken: string;
    FLabelIds: TArray<string>;
    FMaxResults: Integer;
    FQ: string;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId: string);

    function Execute: TMessages; override;

    property UserId: string read FUserId;

    property MaxResults: Integer read FMaxResults write FMaxResults;
    property PageToken: string read FPageToken write FPageToken;
    property Q: string read FQ write FQ;
    property LabelIds: TArray<string> read FLabelIds write FLabelIds;
    property IncludeSpamTrash: Boolean read FIncludeSpamTrash write FIncludeSpamTrash;
  end;

  TFormat = (mfMinimal, mfFull, mfRaw, mfMetadata);

  TMessagesGetRequest = class(TServiceRequest<TMessage>)
  strict private
    FUserId: string;
    FId: string;
    FFormat: TFormat;
    FMetadataHeaders: TArray<string>;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: TMessage; override;

    property UserId: string read FUserId;
    property Id: string read FId;

    property Format: TFormat read FFormat write FFormat;
    property MetadataHeaders: TArray<string> read FMetadataHeaders write FMetadataHeaders;
  end;

  TMessagesSendRequest = class(TServiceRequest<TMessage>)
  strict private
    FUserId: string;
    FContent: TMessage;
  public
    constructor Create(AService: TService; const AUserId: string; AContent: TMessage);
    destructor Destroy; override;

    function Execute: TMessage; override;

    property UserId: string read FUserId;
    property Content: TMessage read FContent;
  end;

  TMessagesDeleteRequest = class(TServiceRequest<Boolean>)
  strict private
    FUserId: string;
    FId: string;
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: Boolean; override;

    property UserId: string read FUserId;
    property Id: string read FId;
  end;

  TMessagesTrashRequest = class(TServiceRequest<TMessage>)
  strict private
    FUserId: string;
    FId: string;
  strict protected
    function GetUrl: string; virtual;
  public
    constructor Create(AService: TService; const AUserId, AId: string);

    function Execute: TMessage; override;

    property UserId: string read FUserId;
    property Id: string read FId;
  end;

  TMessagesUntrashRequest = class(TMessagesTrashRequest)
  strict protected
    function GetUrl: string; override;
  end;

  TMessagesModifyRequest = class(TServiceRequest<TMessage>)
  strict private
    FUserId: string;
    FId: string;
    FContent: TModifyMessageRequest;
  public
    constructor Create(AService: TService; const AUserId, AId: string; AContent: TModifyMessageRequest);
    destructor Destroy; override;

    function Execute: TMessage; override;

    property UserId: string read FUserId;
    property Id: string read FId;
    property Content: TModifyMessageRequest read FContent;
  end;

  TInternalDateSource = (miReceivedTime, miDateHeader);

  TMessagesInsertRequest = class(TServiceRequest<TMessage>)
  strict private
    FUserId: string;
    FContent: TMessage;
    FInternalDateSource: TInternalDateSource;
    FDeleted: Boolean;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId: string; AContent: TMessage);
    destructor Destroy; override;

    function Execute: TMessage; override;

    property UserId: string read FUserId;
    property Content: TMessage read FContent;

    property InternalDateSource: TInternalDateSource read FInternalDateSource write FInternalDateSource;
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  TMessagesImportRequest = class(TServiceRequest<TMessage>)
  strict private
    FUserId: string;
    FContent: TMessage;
    FInternalDateSource: TInternalDateSource;
    FDeleted: Boolean;
    FProcessForCalendar: Boolean;
    FNeverMarkSpam: Boolean;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId: string; AContent: TMessage);
    destructor Destroy; override;

    function Execute: TMessage; override;

    property UserId: string read FUserId;
    property Content: TMessage read FContent;

    property InternalDateSource: TInternalDateSource read FInternalDateSource write FInternalDateSource;
    property NeverMarkSpam: Boolean read FNeverMarkSpam write FNeverMarkSpam;
    property ProcessForCalendar: Boolean read FProcessForCalendar write FProcessForCalendar;
    property Deleted: Boolean read FDeleted write FDeleted;
  end;

  TMessagesBatchDeleteRequest = class(TServiceRequest<Boolean>)
  strict private
    FUserId: string;
    FContent: TBatchDeleteMessagesRequest;
  public
    constructor Create(AService: TService; const AUserId: string; AContent: TBatchDeleteMessagesRequest);
    destructor Destroy; override;

    function Execute: Boolean; override;

    property UserId: string read FUserId;
    property Content: TBatchDeleteMessagesRequest read FContent;
  end;

  TMessagesBatchModifyRequest = class(TServiceRequest<Boolean>)
  strict private
    FUserId: string;
    FContent: TBatchModifyMessagesRequest;
  public
    constructor Create(AService: TService; const AUserId: string; AContent: TBatchModifyMessagesRequest);
    destructor Destroy; override;

    function Execute: Boolean; override;

    property UserId: string read FUserId;
    property Content: TBatchModifyMessagesRequest read FContent;
  end;

  TMessagesResource = class(TGmailResource)
  public
    function BatchDelete(const AUserId: string;
      AContent: TBatchDeleteMessagesRequest): TMessagesBatchDeleteRequest; virtual;
    function BatchModify(const AUserId: string;
      AContent: TBatchModifyMessagesRequest): TMessagesBatchModifyRequest; virtual;
    function Delete(const AUserId, AId: string): TMessagesDeleteRequest; virtual;
    function Get(const AUserId, AId: string): TMessagesGetRequest; virtual;
    function Import(const AUserId: string; AContent: TMessage): TMessagesImportRequest; virtual;
    function Insert(const AUserId: string; AContent: TMessage): TMessagesInsertRequest; virtual;
    function List(const AUserId: string): TMessagesListRequest; virtual;
    function Modify(const AUserId, AId: string;
      AContent: TModifyMessageRequest): TMessagesModifyRequest; virtual;
    function Send(const AUserId: string; AContent: TMessage): TMessagesSendRequest; virtual;
    function Trash(const AUserId, AId: string): TMessagesTrashRequest; virtual;
    function Untrash(const AUserId, AId: string): TMessagesUntrashRequest; virtual;
  end;

const
  Formats: array[TFormat] of string = ('minimal', 'full', 'raw', 'metadata');
  InternalDateSources: array[TInternalDateSource] of string = ('receivedTime', 'dateHeader');

implementation

{ TMessagesListRequest }

constructor TMessagesListRequest.Create(AService: TService; const AUserId: string);
begin
  inherited Create(AService);
  FUserId := AUserId;
end;

function TMessagesListRequest.Execute: TMessages;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    response := Service.Initializer.HttpClient.Get(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages', params);
    Result := TMessages(Service.Initializer.JsonSerializer.JsonToObject(TMessages, response));
  finally
    params.Free();
  end;
end;

procedure TMessagesListRequest.FillParams(AParams: THttpRequestParameterList);
var
  id: string;
begin
  AParams.Add('maxResults', maxResults);
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

{ TMessagesGetRequest }

constructor TMessagesGetRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TMessagesGetRequest.Execute: TMessage;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    response := Service.Initializer.HttpClient.Get(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/' + Id, params);
    Result := TMessage(Service.Initializer.JsonSerializer.JsonToObject(TMessage, response));
  finally
    params.Free();
  end;
end;

procedure TMessagesGetRequest.FillParams(AParams: THttpRequestParameterList);
var
  hdr: string;
begin
  AParams.Add('format', Formats[Format]);

  if (MetadataHeaders <> nil) then
  begin
    for hdr in MetadataHeaders do
    begin
      AParams.Add('metadataHeaders', hdr);
    end;
  end;
end;

{ TMessagesSendRequest }

constructor TMessagesSendRequest.Create(AService: TService;
  const AUserId: string; AContent: TMessage);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FContent := AContent;
end;

destructor TMessagesSendRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TMessagesSendRequest.Execute: TMessage;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/send', params, request);

    Result := TMessage(Service.Initializer.JsonSerializer.JsonToObject(TMessage, response));
  finally
    params.Free();
  end;
end;

{ TMessagesDeleteRequest }

constructor TMessagesDeleteRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TMessagesDeleteRequest.Execute: Boolean;
begin
  Service.Initializer.HttpClient.Delete(
    'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/' + Id);
  Result := True;
end;

{ TMessagesTrashRequest }

constructor TMessagesTrashRequest.Create(AService: TService; const AUserId, AId: string);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
end;

function TMessagesTrashRequest.Execute: TMessage;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    response := Service.Initializer.HttpClient.Post(GetUrl(), params, '');

    Result := TMessage(Service.Initializer.JsonSerializer.JsonToObject(TMessage, response));
  finally
    params.Free();
  end;
end;

function TMessagesTrashRequest.GetUrl: string;
begin
  Result := 'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/' + Id + '/trash';
end;

{ TMessagesUntrashRequest }

function TMessagesUntrashRequest.GetUrl: string;
begin
  Result := 'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/' + Id + '/untrash';
end;

{ TMessagesModifyRequest }

constructor TMessagesModifyRequest.Create(AService: TService; const AUserId,
  AId: string; AContent: TModifyMessageRequest);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FId := AId;
  FContent := AContent;
end;

destructor TMessagesModifyRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TMessagesModifyRequest.Execute: TMessage;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);

    response := Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/' + Id + '/modify', params, request);

    Result := TMessage(Service.Initializer.JsonSerializer.JsonToObject(TMessage, response));
  finally
    params.Free();
  end;
end;

{ TMessagesInsertRequest }

constructor TMessagesInsertRequest.Create(AService: TService; const AUserId: string; AContent: TMessage);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FContent := AContent;
end;

destructor TMessagesInsertRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TMessagesInsertRequest.Execute: TMessage;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);
    response := Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages', params, request);
    Result := TMessage(Service.Initializer.JsonSerializer.JsonToObject(TMessage, response));
  finally
    params.Free();
  end;
end;

procedure TMessagesInsertRequest.FillParams(AParams: THttpRequestParameterList);
begin
  AParams.Add('internalDateSource', InternalDateSources[InternalDateSource]);
  AParams.Add('deleted', Deleted);
end;

{ TMessagesImportRequest }

constructor TMessagesImportRequest.Create(AService: TService; const AUserId: string; AContent: TMessage);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FContent := AContent;
end;

destructor TMessagesImportRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TMessagesImportRequest.Execute: TMessage;
var
  request, response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);
    response := Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/import', params, request);
    Result := TMessage(Service.Initializer.JsonSerializer.JsonToObject(TMessage, response));
  finally
    params.Free();
  end;
end;

procedure TMessagesImportRequest.FillParams(AParams: THttpRequestParameterList);
begin
  AParams.Add('internalDateSource', InternalDateSources[InternalDateSource]);
  AParams.Add('neverMarkSpam', NeverMarkSpam);
  AParams.Add('processForCalendar', ProcessForCalendar);
  AParams.Add('deleted', Deleted);
end;

{ TMessagesResource }

function TMessagesResource.BatchDelete(const AUserId: string;
  AContent: TBatchDeleteMessagesRequest): TMessagesBatchDeleteRequest;
begin
  Result := TMessagesBatchDeleteRequest.Create(Service, AUserId, AContent);
end;

function TMessagesResource.BatchModify(const AUserId: string;
  AContent: TBatchModifyMessagesRequest): TMessagesBatchModifyRequest;
begin
  Result := TMessagesBatchModifyRequest.Create(Service, AUserId, AContent);
end;

function TMessagesResource.Delete(const AUserId, AId: string): TMessagesDeleteRequest;
begin
  Result := TMessagesDeleteRequest.Create(Service, AUserId, AId);
end;

function TMessagesResource.Get(const AUserId, AId: string): TMessagesGetRequest;
begin
  Result := TMessagesGetRequest.Create(Service, AUserId, AId);
end;

function TMessagesResource.Import(const AUserId: string; AContent: TMessage): TMessagesImportRequest;
begin
  Result := TMessagesImportRequest.Create(Service, AUserId, AContent);
end;

function TMessagesResource.Insert(const AUserId: string; AContent: TMessage): TMessagesInsertRequest;
begin
  Result := TMessagesInsertRequest.Create(Service, AUserId, AContent);
end;

function TMessagesResource.List(const AUserId: string): TMessagesListRequest;
begin
  Result := TMessagesListRequest.Create(Service, AUserId);
end;

function TMessagesResource.Modify(const AUserId, AId: string;
  AContent: TModifyMessageRequest): TMessagesModifyRequest;
begin
  Result := TMessagesModifyRequest.Create(Service, AUserId, AId, AContent);
end;

function TMessagesResource.Send(const AUserId: string; AContent: TMessage): TMessagesSendRequest;
begin
  Result := TMessagesSendRequest.Create(Service, AUserId, AContent);
end;

function TMessagesResource.Trash(const AUserId, AId: string): TMessagesTrashRequest;
begin
  Result := TMessagesTrashRequest.Create(Service, AUserId, AId);
end;

function TMessagesResource.Untrash(const AUserId, AId: string): TMessagesUntrashRequest;
begin
  Result := TMessagesUntrashRequest.Create(Service, AUserId, AId);
end;

{ TMessagesBatchDeleteRequest }

constructor TMessagesBatchDeleteRequest.Create(AService: TService;
  const AUserId: string; AContent: TBatchDeleteMessagesRequest);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FContent := AContent;
end;

destructor TMessagesBatchDeleteRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TMessagesBatchDeleteRequest.Execute: Boolean;
var
  request: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);
    Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/batchDelete', params, request);
    Result := True;
  finally
    params.Free();
  end;
end;

{ TMessagesBatchModifyRequest }

constructor TMessagesBatchModifyRequest.Create(AService: TService;
  const AUserId: string; AContent: TBatchModifyMessagesRequest);
begin
  inherited Create(AService);

  FUserId := AUserId;
  FContent := AContent;
end;

destructor TMessagesBatchModifyRequest.Destroy;
begin
  FContent.Free();
  inherited Destroy();
end;

function TMessagesBatchModifyRequest.Execute: Boolean;
var
  request: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    request := Service.Initializer.JsonSerializer.ObjectToJson(Content);
    Service.Initializer.HttpClient.Post(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/messages/batchModify', params, request);
    Result := True;
  finally
    params.Free();
  end;
end;

end.
