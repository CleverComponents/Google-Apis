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
  TLabelColor = class
  private
    FTextColor: string;
    FBackgroundColor: string;
  public
    [TclJsonString('textColor')]
    property TextColor: string read FTextColor write FTextColor;

    [TclJsonString('backgroundColor')]
    property BackgroundColor: string read FBackgroundColor write FBackgroundColor;
  end;

  TLabel = class
  private
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

  TLabels = class
  strict private
    FLabels: TArray<TLabel>;
    procedure SetLabels(const Value: TArray<TLabel>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('labels')]
    property Labels: TArray<TLabel> read FLabels write SetLabels;
  end;

implementation

{ TLabalList }

constructor TLabels.Create;
begin
  inherited Create();
  FLabels := nil;
end;

destructor TLabels.Destroy;
begin
  SetLabels(nil);
  inherited Destroy();
end;

procedure TLabels.SetLabels(const Value: TArray<TLabel>);
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

end.
