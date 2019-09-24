program Delphi.Mock.Test;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  DUnitX.TestFramework,
  Delphi.Mock in '..\Delphi.Mock.pas',
  Delphi.Mock.Tests in 'Delphi.Mock.Tests.pas',
  Delphi.Mock.Setup in '..\Delphi.Mock.Setup.pas',
  Delphi.Mock.Setup.Tests in 'Delphi.Mock.Setup.Tests.pas',
  Delphi.Mock.VirtualInterface in '..\Delphi.Mock.VirtualInterface.pas',
  Delphi.Mock.VirtualInterface.Test in 'Delphi.Mock.VirtualInterface.Test.pas',
  Delphi.Mock.Method.Types in '..\Delphi.Mock.Method.Types.pas',
  Delphi.Mock.Expect in '..\Delphi.Mock.Expect.pas',
  Delphi.Mock.Expect.Test in 'Delphi.Mock.Expect.Test.pas';

//Just to not remove de IFDEF
{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  ReportMemoryLeaksOnShutdown := True;

  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.