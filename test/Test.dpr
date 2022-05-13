program Test;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  GoogleApis.Tests in 'core\GoogleApis.Tests.pas',
  GoogleApis in '..\src\core\GoogleApis.pas',
  GoogleApis.Persister in '..\src\core\GoogleApis.Persister.pas',
  GoogleApis.Calendar.Data in '..\src\calendar\GoogleApis.Calendar.Data.pas',
  GoogleApis.Calendar in '..\src\calendar\GoogleApis.Calendar.pas',
  GoogleApis.Calendar.Tests in 'calendar\GoogleApis.Calendar.Tests.pas',
  GoogleApis.Gmail in '..\src\gmail\GoogleApis.Gmail.pas',
  GoogleApis.Gmail.Data in '..\src\gmail\GoogleApis.Gmail.Data.pas',
  GoogleApis.Gmail.Tests in 'gmail\GoogleApis.Gmail.Tests.pas',
  GoogleApis.Gmail.Labels in '..\src\gmail\GoogleApis.Gmail.Labels.pas',
  GoogleApis.Gmail.Messages in '..\src\gmail\GoogleApis.Gmail.Messages.pas',
  GoogleApis.Gmail.Core in '..\src\gmail\GoogleApis.Gmail.Core.pas',
  GoogleApis.Gmail.Users in '..\src\gmail\GoogleApis.Gmail.Users.pas',
  GoogleApis.Gmail.Drafts in '..\src\gmail\GoogleApis.Gmail.Drafts.pas',
  GoogleApis.Gmail.History in '..\src\gmail\GoogleApis.Gmail.History.pas',
  GoogleApis.Gmail.Threads in '..\src\gmail\GoogleApis.Gmail.Threads.pas';

{$R *.RES}

begin
  System.ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

