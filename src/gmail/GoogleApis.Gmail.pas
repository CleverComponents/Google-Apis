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

unit GoogleApis.Gmail;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs, GoogleApis, GoogleApis.Gmail.Users;

type
  TGmailService = class(TService)
  strict private
    FUsers: TUsersResource;

    function GetUsers: TUsersResource;
  strict protected
    function CreateUsers: TUsersResource; virtual;
  public
    constructor Create(AInitializer: TServiceInitializer);
    destructor Destroy; override;

    property Users: TUsersResource read GetUsers;
  end;

const
  //Available OAuth 2.0 scopes for use with the Gmail API.

  //Read, compose, send, and permanently delete all your email from Gmail
  MailGoogleCom = 'https://mail.google.com/';

  //Manage drafts and send emails
  GmailCompose = 'https://www.googleapis.com/auth/gmail.compose';

  //Insert mail into your mailbox
  GmailInsert = 'https://www.googleapis.com/auth/gmail.insert';

  //Manage mailbox labels
  GmailLabels = 'https://www.googleapis.com/auth/gmail.labels';

  //View your email message metadata such as labels and headers, but not the email body
  GmailMetadata = 'https://www.googleapis.com/auth/gmail.metadata';

  //View and modify but not delete your email
  GmailModify = 'https://www.googleapis.com/auth/gmail.modify';

  //View your email messages and settings
  GmailReadonly = 'https://www.googleapis.com/auth/gmail.readonly';

  //Send email on your behalf
  GmailSend = 'https://www.googleapis.com/auth/gmail.send';

  //Manage your basic mail settings
  GmailSettingsBasic = 'https://www.googleapis.com/auth/gmail.settings.basic';

  //Manage your sensitive mail settings, including who can manage your mail
  GmailSettingsSharing = 'https://www.googleapis.com/auth/gmail.settings.sharing';

implementation

{ TGmailService }

constructor TGmailService.Create(AInitializer: TServiceInitializer);
begin
  inherited Create(AInitializer);
  FUsers := nil;
end;

function TGmailService.CreateUsers: TUsersResource;
begin
  Result := TUsersResource.Create(Self);
end;

destructor TGmailService.Destroy;
begin
  FreeAndNil(FUsers);
  inherited Destroy();
end;

function TGmailService.GetUsers: TUsersResource;
begin
  if (FUsers = nil) then
  begin
    FUsers := CreateUsers();
  end;
  Result := FUsers;
end;

end.
