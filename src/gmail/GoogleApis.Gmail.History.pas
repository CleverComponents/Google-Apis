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

unit GoogleApis.Gmail.History;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs, GoogleApis, GoogleApis.Gmail.Data,
  GoogleApis.Gmail.Core;

type
  THistoryType = (htMessageAdded, htMessageDeleted, htLabelAdded, htLabelRemoved);
  THistoryTypes = set of THistoryType;

  THistoryListRequest = class(TServiceRequest<THistoryResponse>)
  strict private
    FUserId: string;
    FStartHistoryId: string;
    FPageToken: string;
    FMaxResults: Integer;
    FLabelId: string;
    FHistoryTypes: THistoryTypes;

    procedure FillParams(AParams: THttpRequestParameterList);
  public
    constructor Create(AService: TService; const AUserId: string);

    function Execute: THistoryResponse; override;

    property UserId: string read FUserId;

    property MaxResults: Integer read FMaxResults write FMaxResults;
    property PageToken: string read FPageToken write FPageToken;
    property StartHistoryId: string read FStartHistoryId write FStartHistoryId;
    property LabelId: string read FLabelId write FLabelId;
    property HistoryTypes: THistoryTypes read FHistoryTypes write FHistoryTypes;
  end;

  THistoryResource = class(TGmailResource)
  public
    function List(const AUserId: string): THistoryListRequest; virtual;
  end;

const
  HistoryTypeNames: array[THistoryType] of string =
    ('messageAdded', 'messageDeleted', 'labelAdded', 'labelRemoved');

implementation

{ THistoryResource }

function THistoryResource.List(const AUserId: string): THistoryListRequest;
begin
  Result := THistoryListRequest.Create(Service, AUserId);
end;

{ THistoryListRequest }

constructor THistoryListRequest.Create(AService: TService; const AUserId: string);
begin
  inherited Create(AService);
  FUserId := AUserId;
end;

function THistoryListRequest.Execute: THistoryResponse;
var
  response: string;
  params: THttpRequestParameterList;
begin
  params := THttpRequestParameterList.Create();
  try
    FillParams(params);
    response := Service.Initializer.HttpClient.Get(
      'https://gmail.googleapis.com/gmail/v1/users/' + UserId + '/history', params);
    Result := THistoryResponse(Service.Initializer.JsonSerializer.JsonToObject(THistoryResponse, response));
  finally
    params.Free();
  end;
end;

procedure THistoryListRequest.FillParams(AParams: THttpRequestParameterList);
var
  item: THistoryType;
begin
  AParams.Add('maxResults', MaxResults);
  AParams.Add('pageToken', PageToken);
  AParams.Add('startHistoryId', StartHistoryId);
  AParams.Add('labelId', LabelId);

  for item := Low(THistoryType) to High(THistoryType) do
  begin
    if (item in HistoryTypes) then
    begin
      AParams.Add('historyTypes', HistoryTypeNames[item]);
    end;
  end;
end;

end.
