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

unit GoogleApis.Gmail.Data;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, clJsonSerializerBase, GoogleApis;

type
  TProfile = class
  strict private
    FEmailAddress: string;
    FMessagesTotal: string;
    FThreadsTotal: string;
    FHistoryId: string;
  public
    [TclJsonString('emailAddress')]
    property EmailAddress: string read FEmailAddress write FEmailAddress;

    [TclJsonProperty('messagesTotal')]
    property MessagesTotal: string read FMessagesTotal write FMessagesTotal;

    [TclJsonProperty('threadsTotal')]
    property ThreadsTotal: string read FThreadsTotal write FThreadsTotal;

    [TclJsonString('historyId')]
    property HistoryId: string read FHistoryId write FHistoryId;
  end;

  TLabelColor = class
  strict private
    FTextColor: string;
    FBackgroundColor: string;
  public
    [TclJsonString('textColor')]
    property TextColor: string read FTextColor write FTextColor;

    [TclJsonString('backgroundColor')]
    property BackgroundColor: string read FBackgroundColor write FBackgroundColor;
  end;

  TLabel = class
  strict private
    FName: string;
    FType_: string;
    FColor: TLabelColor;
    FMessagesTotal: string;
    FThreadsUnread: string;
    FId: string;
    FMessageListVisibility: string;
    FLabelListVisibility: string;
    FMessagesUnread: string;
    FThreadsTotal: string;

    procedure SetColor(const Value: TLabelColor);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonString('id')]
    property Id: string read FId write FId;

    [TclJsonString('name')]
    property Name: string read FName write FName;

    [TclJsonString('messageListVisibility')]
    property MessageListVisibility: string read FMessageListVisibility write FMessageListVisibility;

    [TclJsonString('labelListVisibility')]
    property LabelListVisibility: string read FLabelListVisibility write FLabelListVisibility;

    [TclJsonString('type')]
    property Type_: string read FType_ write FType_;

    [TclJsonProperty('messagesTotal')]
    property MessagesTotal: string read FMessagesTotal write FMessagesTotal;

    [TclJsonProperty('messagesUnread')]
    property MessagesUnread: string read FMessagesUnread write FMessagesUnread;

    [TclJsonProperty('threadsTotal')]
    property ThreadsTotal: string read FThreadsTotal write FThreadsTotal;

    [TclJsonProperty('threadsUnread')]
    property ThreadsUnread: string read FThreadsUnread write FThreadsUnread;

    [TclJsonProperty('color')]
    property Color: TLabelColor read FColor write SetColor;
  end;

  TLabelsResponse = class
  strict private
    FLabels: TArray<TLabel>;
    procedure SetLabels(const Value: TArray<TLabel>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('labels')]
    property Labels: TArray<TLabel> read FLabels write SetLabels;
  end;

  THeader = class
  strict private
    FName: string;
    FValue: string;
  public
    [TclJsonString('name')]
    property Name: string read FName write FName;

    [TclJsonString('value')]
    property Value: string read FValue write FValue;
  end;

  TMessagePartBody = class
  strict private
    FSize: Integer;
    FAttachmentId: string;
    FData: string;
  public
    [TclJsonString('attachmentId')]
    property AttachmentId: string read FAttachmentId write FAttachmentId;

    [TclJsonString('size')]
    property Size: Integer read FSize write FSize;

    [TclJsonString('data')]
    property Data: string read FData write FData;
  end;

  TMessagePart = class
  strict private
    FFilename: string;
    FPartId: string;
    FMimeType: string;
    FHeaders: TArray<THeader>;
    FBody: TMessagePartBody;
    FParts: TArray<TMessagePart>;

    procedure SetHeaders(const Value: TArray<THeader>);
    procedure SetBody(const Value: TMessagePartBody);
    procedure SetParts(const Value: TArray<TMessagePart>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonString('partId')]
    property PartId: string read FPartId write FPartId;

    [TclJsonString('mimeType')]
    property MimeType: string read FMimeType write FMimeType;

    [TclJsonString('mimeType')]
    property Filename: string read FFilename write FFilename;

    [TclJsonProperty('headers')]
    property Headers: TArray<THeader> read FHeaders write SetHeaders;

    [TclJsonProperty('body')]
    property Body: TMessagePartBody read FBody write SetBody;

    [TclJsonProperty('parts')]
    property Parts: TArray<TMessagePart> read FParts write SetParts;
  end;

  TMessage = class
  strict private
    FThreadId: string;
    FId: string;
    FLabelIds: TArray<string>;
    FHistoryId: string;
    FSnippet: string;
    FInternalDate: string;
    FPayload: TMessagePart;
    FSizeEstimate: string;
    FRaw: string;

    procedure SetPayload(const Value: TMessagePart);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonString('id')]
    property Id: string read FId write FId;

    [TclJsonString('threadId')]
    property ThreadId: string read FThreadId write FThreadId;

    [TclJsonString('labelIds')]
    property LabelIds: TArray<string> read FLabelIds write FLabelIds;

    [TclJsonString('snippet')]
    property Snippet: string read FSnippet write FSnippet;

    [TclJsonString('historyId')]
    property HistoryId: string read FHistoryId write FHistoryId;

    [TclJsonString('internalDate')]
    property InternalDate: string read FInternalDate write FInternalDate;

    [TclJsonProperty('payload')]
    property Payload: TMessagePart read FPayload write SetPayload;

    [TclJsonProperty('sizeEstimate')]
    property SizeEstimate: string read FSizeEstimate write FSizeEstimate;

    [TclJsonString('raw')]
    property Raw: string read FRaw write FRaw;
  end;

  TMessagesResponse = class
  strict private
    FMessages: TArray<TMessage>;
    FNextPageToken: string;
    FResultSizeEstimate: Integer;

    procedure SetMessages(const Value: TArray<TMessage>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('messages')]
    property Messages: TArray<TMessage> read FMessages write SetMessages;

    [TclJsonString('nextPageToken')]
    property NextPageToken: string read FNextPageToken write FNextPageToken;

    [TclJsonProperty('resultSizeEstimate')]
    property ResultSizeEstimate: Integer read FResultSizeEstimate write FResultSizeEstimate;
  end;

  TDraft = class
  strict private
    FId: string;
    FMessage_: TMessage;

    procedure SetMessage_(const Value: TMessage);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonString('id')]
    property Id: string read FId write FId;

    [TclJsonProperty('message')]
    property Message_: TMessage read FMessage_ write SetMessage_;
  end;

  TDraftsResponse = class
  private
    FNextPageToken: string;
    FDrafts: TArray<TDraft>;
    FResultSizeEstimate: Integer;

    procedure SetDrafts(const Value: TArray<TDraft>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('drafts')]
    property Drafts: TArray<TDraft> read FDrafts write SetDrafts;

    [TclJsonString('nextPageToken')]
    property NextPageToken: string read FNextPageToken write FNextPageToken;

    [TclJsonProperty('resultSizeEstimate')]
    property ResultSizeEstimate: Integer read FResultSizeEstimate write FResultSizeEstimate;
  end;

  TModifyMessageRequest = class
  strict private
    FAddLabelIds: TArray<string>;
    FRemoveLabelIds: TArray<string>;
  public
    [TclJsonString('addLabelIds')]
    property AddLabelIds: TArray<string> read FAddLabelIds write FAddLabelIds;

    [TclJsonString('removeLabelIds')]
    property RemoveLabelIds: TArray<string> read FRemoveLabelIds write FRemoveLabelIds;
  end;

  TBatchDeleteMessagesRequest = class
  strict private
    FIds: TArray<string>;
  public
    [TclJsonString('ids')]
    property Ids: TArray<string> read FIds write FIds;
  end;

  TBatchModifyMessagesRequest = class
  strict private
    FIds: TArray<string>;
    FRemoveLabelIds: TArray<string>;
    FAddLabelIds: TArray<string>;
  public
    [TclJsonString('ids')]
    property Ids: TArray<string> read FIds write FIds;

    [TclJsonString('addLabelIds')]
    property AddLabelIds: TArray<string> read FAddLabelIds write FAddLabelIds;

    [TclJsonString('removeLabelIds')]
    property RemoveLabelIds: TArray<string> read FRemoveLabelIds write FRemoveLabelIds;
  end;

  TMessageAdded = class
  strict private
    FMessage_: TMessage;

    procedure SetMessage_(const Value: TMessage);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('message')]
    property Message_: TMessage read FMessage_ write SetMessage_;
  end;

  TMessageDeleted = class(TMessageAdded);

  TLabelAdded = class(TMessageAdded)
  strict private
    FLabelIds: TArray<string>;
  public
    [TclJsonString('labelIds')]
    property LabelIds: TArray<string> read FLabelIds write FLabelIds;
  end;

  TLabelRemoved = class(TLabelAdded);

  THistory = class
  strict private
    FId: string;
    FMessages: TArray<TMessage>;
    FLabelsAdded: TArray<TLabelAdded>;
    FLabelsRemoved: TArray<TLabelRemoved>;
    FMessagesDeleted: TArray<TMessageDeleted>;
    FMessagesAdded: TArray<TMessageAdded>;

    procedure SetMessages(const Value: TArray<TMessage>);
    procedure SetLabelsAdded(const Value: TArray<TLabelAdded>);
    procedure SetLabelsRemoved(const Value: TArray<TLabelRemoved>);
    procedure SetMessagesAdded(const Value: TArray<TMessageAdded>);
    procedure SetMessagesDeleted(const Value: TArray<TMessageDeleted>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('id')]
    property Id: string read FId write FId;

    [TclJsonProperty('messages')]
    property Messages: TArray<TMessage> read FMessages write SetMessages;

    [TclJsonProperty('messagesAdded')]
    property MessagesAdded: TArray<TMessageAdded> read FMessagesAdded write SetMessagesAdded;

    [TclJsonProperty('messagesDeleted')]
    property MessagesDeleted: TArray<TMessageDeleted> read FMessagesDeleted write SetMessagesDeleted;

    [TclJsonProperty('labelsAdded')]
    property LabelsAdded: TArray<TLabelAdded> read FLabelsAdded write SetLabelsAdded;

    [TclJsonProperty('labelsRemoved')]
    property LabelsRemoved: TArray<TLabelRemoved> read FLabelsRemoved write SetLabelsRemoved;
  end;

  THistoryResponse = class
  strict private
    FHistory: TArray<THistory>;
    FNextPageToken: string;
    FHistoryId: string;

    procedure SetHistory(const Value: TArray<THistory>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('history')]
    property History: TArray<THistory> read FHistory write SetHistory;

    [TclJsonString('nextPageToken')]
    property NextPageToken: string read FNextPageToken write FNextPageToken;

    [TclJsonProperty('historyId')]
    property HistoryId: string read FHistoryId write FHistoryId;
  end;

  TThread = class
  strict private
    FMessages: TArray<TMessage>;
    FId: string;
    FHistoryId: string;
    FSnippet: string;

    procedure SetMessages(const Value: TArray<TMessage>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonString('id')]
    property Id: string read FId write FId;

    [TclJsonString('snippet')]
    property Snippet: string read FSnippet write FSnippet;

    [TclJsonProperty('historyId')]
    property HistoryId: string read FHistoryId write FHistoryId;

    [TclJsonProperty('messages')]
    property Messages: TArray<TMessage> read FMessages write SetMessages;
  end;

  TThreadsResponse = class
  strict private
    FThreads: TArray<TThread>;
    FNextPageToken: string;
    FResultSizeEstimate: Integer;

    procedure SetThreads(const Value: TArray<TThread>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('threads')]
    property Threads: TArray<TThread> read FThreads write SetThreads;

    [TclJsonString('nextPageToken')]
    property NextPageToken: string read FNextPageToken write FNextPageToken;

    [TclJsonProperty('resultSizeEstimate')]
    property ResultSizeEstimate: Integer read FResultSizeEstimate write FResultSizeEstimate;
  end;

  TModifyThreadRequest = class(TModifyMessageRequest);

implementation

{ TLabalList }

constructor TLabelsResponse.Create;
begin
  inherited Create();
  FLabels := nil;
end;

destructor TLabelsResponse.Destroy;
begin
  SetLabels(nil);
  inherited Destroy();
end;

procedure TLabelsResponse.SetLabels(const Value: TArray<TLabel>);
var
  obj: TObject;
begin
  if (FLabels <> nil) then
  begin
    for obj in FLabels do
    begin
      obj.Free();
    end;
  end;

  FLabels := Value;
end;

{ TLabel }

constructor TLabel.Create;
begin
  inherited Create();
  FColor := nil;
end;

destructor TLabel.Destroy;
begin
  FColor.Free();
  inherited Destroy();
end;

procedure TLabel.SetColor(const Value: TLabelColor);
begin
  FColor.Free();
  FColor := Value;
end;

{ TMessagesResponse }

constructor TMessagesResponse.Create;
begin
  inherited Create();
  FMessages := nil;
end;

destructor TMessagesResponse.Destroy;
begin
  SetMessages(nil);
  inherited Destroy();
end;

procedure TMessagesResponse.SetMessages(const Value: TArray<TMessage>);
var
  obj: TObject;
begin
  if (FMessages <> nil) then
  begin
    for obj in FMessages do
    begin
      obj.Free();
    end;
  end;

  FMessages := Value;
end;

{ TMessage }

constructor TMessage.Create;
begin
  inherited Create();
  FPayload := nil;
end;

destructor TMessage.Destroy;
begin
  FPayload.Free();
  inherited Destroy();
end;

procedure TMessage.SetPayload(const Value: TMessagePart);
begin
  FPayload.Free();
  FPayload := Value;
end;

{ TMessagePart }

constructor TMessagePart.Create;
begin
  inherited Create();

  FHeaders := nil;
  FBody := nil;
  FParts := nil;
end;

destructor TMessagePart.Destroy;
begin
  SetParts(nil);
  SetBody(nil);
  SetHeaders(nil);

  inherited Destroy();
end;

procedure TMessagePart.SetBody(const Value: TMessagePartBody);
begin
  FBody.Free();
  FBody := Value;
end;

procedure TMessagePart.SetHeaders(const Value: TArray<THeader>);
var
  obj: TObject;
begin
  if (FHeaders <> nil) then
  begin
    for obj in FHeaders do
    begin
      obj.Free();
    end;
  end;

  FHeaders := Value;
end;

procedure TMessagePart.SetParts(const Value: TArray<TMessagePart>);
var
  obj: TObject;
begin
  if (FParts <> nil) then
  begin
    for obj in FParts do
    begin
      obj.Free();
    end;
  end;

  FParts := Value;
end;

{ TDraft }

constructor TDraft.Create;
begin
  inherited Create();
  FMessage_ := nil;
end;

destructor TDraft.Destroy;
begin
  FMessage_.Free();
  inherited Destroy();
end;

procedure TDraft.SetMessage_(const Value: TMessage);
begin
  FMessage_.Free();
  FMessage_ := Value;
end;

{ TDraftsResponse }

constructor TDraftsResponse.Create;
begin
  inherited Create();
  FDrafts := nil;
end;

destructor TDraftsResponse.Destroy;
begin
  SetDrafts(nil);
  inherited Destroy();
end;

procedure TDraftsResponse.SetDrafts(const Value: TArray<TDraft>);
var
  obj: TObject;
begin
  if (FDrafts <> nil) then
  begin
    for obj in FDrafts do
    begin
      obj.Free();
    end;
  end;
  FDrafts := Value;
end;

{ THistoryResponse }

constructor THistoryResponse.Create;
begin
  inherited Create();
  FHistory := nil;
end;

destructor THistoryResponse.Destroy;
begin
  SetHistory(nil);
  inherited Destroy();
end;

procedure THistoryResponse.SetHistory(const Value: TArray<THistory>);
var
  obj: TObject;
begin
  if (FHistory <> nil) then
  begin
    for obj in FHistory do
    begin
      obj.Free();
    end;
  end;
  FHistory := Value;
end;

{ THistory }

constructor THistory.Create;
begin
  inherited Create();

  FMessages := nil;
  FLabelsAdded := nil;
  FLabelsRemoved := nil;
  FMessagesDeleted := nil;
  FMessagesAdded := nil;
end;

destructor THistory.Destroy;
begin
  SetMessagesAdded(nil);
  SetMessagesDeleted(nil);
  SetLabelsRemoved(nil);
  SetLabelsAdded(nil);
  SetMessages(nil);

  inherited Destroy();
end;

procedure THistory.SetLabelsAdded(const Value: TArray<TLabelAdded>);
var
  obj: TObject;
begin
  if (FLabelsAdded <> nil) then
  begin
    for obj in FLabelsAdded do
    begin
      obj.Free();
    end;
  end;
  FLabelsAdded := Value;
end;

procedure THistory.SetLabelsRemoved(const Value: TArray<TLabelRemoved>);
var
  obj: TObject;
begin
  if (FLabelsRemoved <> nil) then
  begin
    for obj in FLabelsRemoved do
    begin
      obj.Free();
    end;
  end;
  FLabelsRemoved := Value;
end;

procedure THistory.SetMessages(const Value: TArray<TMessage>);
var
  obj: TObject;
begin
  if (FMessages <> nil) then
  begin
    for obj in FMessages do
    begin
      obj.Free();
    end;
  end;
  FMessages := Value;
end;

procedure THistory.SetMessagesAdded(const Value: TArray<TMessageAdded>);
var
  obj: TObject;
begin
  if (FMessagesAdded <> nil) then
  begin
    for obj in FMessagesAdded do
    begin
      obj.Free();
    end;
  end;
  FMessagesAdded := Value;
end;

procedure THistory.SetMessagesDeleted(const Value: TArray<TMessageDeleted>);
var
  obj: TObject;
begin
  if (FMessagesDeleted <> nil) then
  begin
    for obj in FMessagesDeleted do
    begin
      obj.Free();
    end;
  end;
  FMessagesDeleted := Value;
end;

{ TMessageAdded }

constructor TMessageAdded.Create;
begin
  inherited Create();
  FMessage_ := nil;
end;

destructor TMessageAdded.Destroy;
begin
  FMessage_.Free();
  inherited Destroy();
end;

procedure TMessageAdded.SetMessage_(const Value: TMessage);
begin
  FMessage_.Free();
  FMessage_ := Value;
end;

{ TThreadsResponse }

constructor TThreadsResponse.Create;
begin
  inherited Create();
  FThreads := nil;
end;

destructor TThreadsResponse.Destroy;
begin
  SetThreads(nil);
  inherited Destroy();
end;

procedure TThreadsResponse.SetThreads(const Value: TArray<TThread>);
var
  obj: TObject;
begin
  if (FThreads <> nil) then
  begin
    for obj in FThreads do
    begin
      obj.Free();
    end;
  end;
  FThreads := Value;
end;

{ TThread }

constructor TThread.Create;
begin
  inherited Create();
  FMessages := nil;
end;

destructor TThread.Destroy;
begin
  SetMessages(nil);
  inherited Destroy();
end;

procedure TThread.SetMessages(const Value: TArray<TMessage>);
var
  obj: TObject;
begin
  if (FMessages <> nil) then
  begin
    for obj in FMessages do
    begin
      obj.Free();
    end;
  end;
  FMessages := Value;
end;

end.
