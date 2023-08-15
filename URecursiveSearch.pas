unit URecursiveSearch;

interface
uses Classes, SysUtils, StdCtrls, Windows, Forms;
procedure CaptureConsoleOutput(const ACommand, AParameters: String; AMemo: TMemo);
procedure FileFinder(Path: string;maska: string;recur: boolean ;sl: TStringList);
function FullRemoveDir(Dir: string; DeleteAllFilesAndFolders, StopIfNotAllDeleted, RemoveRoot: boolean): Boolean;

implementation
procedure CaptureConsoleOutput(const ACommand, AParameters: String; AMemo: TMemo);
 const
   CReadBuffer = 2400;
 var
   saSecurity: TSecurityAttributes;
   hRead: THandle;
   hWrite: THandle;
   suiStartup: TStartupInfo;
   piProcess: TProcessInformation;
   pBuffer: array[0..CReadBuffer] of AnsiChar;
   dRead: DWord;
   dRunning: DWord;
 begin
   saSecurity.nLength := SizeOf(TSecurityAttributes);
   saSecurity.bInheritHandle := True;
   saSecurity.lpSecurityDescriptor := nil;

   if CreatePipe(hRead, hWrite, @saSecurity, 0) then
   begin
     FillChar(suiStartup, SizeOf(TStartupInfo), #0);
     suiStartup.cb := SizeOf(TStartupInfo);
     suiStartup.hStdInput := hRead;
     suiStartup.hStdOutput := hWrite;
     suiStartup.hStdError := hWrite;
     suiStartup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
     suiStartup.wShowWindow := SW_HIDE;

     if CreateProcess(nil, PChar(ACommand + ' ' + AParameters), @saSecurity,
       @saSecurity, True, NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, piProcess)
       then
     begin
       repeat
         dRunning  := WaitForSingleObject(piProcess.hProcess, 100);
         Application.ProcessMessages();
         repeat
           dRead := 0;
           CloseHandle(piProcess.hProcess);
           piProcess.hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, piProcess.dwProcessId);
           if piProcess.hProcess > 0 then
           begin
             ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
             pBuffer[dRead] := #0;
           end;

           OemToAnsi(pBuffer, pBuffer);
           AMemo.Lines.Add(String(pBuffer));
         until (dRead < CReadBuffer);
       until (dRunning <> WAIT_TIMEOUT);
       CloseHandle(piProcess.hProcess);
       CloseHandle(piProcess.hThread);
     end;

     CloseHandle(hRead);
     CloseHandle(hWrite);
   end;
end;
{ **** UBPFD *********** by delphibase.endimus.com ****
>> Removing a non-empty directory along with subdirectories

Deleting subdirectories recursively - the function calls itself.
Description of the purpose of the arguments:

-DeleteAllFilesAndFolder - If TRUE then the function will be done
Trying to set the faArchive attribute to any file or folder
before its (e¸) removal;

-StopIfNotAllDeleted - If TRUE then the function works instantly
stop if an error occurs deleting at least one file or folder;

-RemoveRoot - If TRUE, specifies whether to remove the root.

Dependencies: FileCtrl, SysUtils
Author: lipskiy, lipskiy@mail.ru, ICQ:51219290, St. Petersburg
Copyright: Own spelling (lipskiy)
Date: April 26, 2002
***************************************************** }
function FullRemoveDir(Dir: string; DeleteAllFilesAndFolders,
  StopIfNotAllDeleted, RemoveRoot: boolean): Boolean;
var
  i: Integer;
  SRec: TSearchRec;
  FN: string;
begin
  Result := False;
  if not DirectoryExists(Dir) then
    exit;
  Result := True;
  // Add a backslash at the end and set the mask - "all files and directories"
  Dir := IncludeTrailingBackslash(Dir);
  i := FindFirst(Dir + '*', faAnyFile, SRec);
  try
    while i = 0 do
    begin
      // Getting the full path to a file or directory
      FN := Dir + SRec.Name;
      // If this directory
      if SRec.Attr = faDirectory then
      begin
        // Recursive call to this function with the option to remove the root
        if (SRec.Name <> '') and (SRec.Name <> '.') and (SRec.Name <> '..') then
        begin
          if DeleteAllFilesAndFolders then
            FileSetAttr(FN, faArchive);
          Result := FullRemoveDir(FN, DeleteAllFilesAndFolders,
            StopIfNotAllDeleted, True);
          if not Result and StopIfNotAllDeleted then
            exit;
        end;
      end
      else // First, delete the file
      begin
        if DeleteAllFilesAndFolders then
          FileSetAttr(FN, faArchive);
        Result := SysUtils.DeleteFile(FN);
        if not Result and StopIfNotAllDeleted then
          exit;
      end;
      // Get the next file or directory
      i := FindNext(SRec);
    end;
  finally
    SysUtils.FindClose(SRec);
  end;
  if not Result then
    exit;
  if RemoveRoot then // If it is necessary to remove the root - delete
    if not RemoveDir(Dir) then
      Result := false;
end;
procedure FileFinder(Path: string;maska: string;recur: boolean ;sl: TStringList);
{
Path - search path
maska ​​- search mask
recur - true - search for and in subdirectories
        false - search only in the specified folder
sl - list of found files
}
var sr : TSearchRec;
begin
if (Path[Length(Path)]='\') then SetLength(Path,Length(Path)-1);
if FindFirst(Path+'\'+maska,faAnyFile,sr)=0
   then
      begin
         if (sr.Attr or faDirectory)=sr.Attr then
            begin
            if (recur=true) then
               begin
                  if (sr.name<>'.') and (sr.name<>'..') then
                  FileFinder(path+'\'+sr.Name,maska,recur,sl);
               end
            end
         else
         sl.Add(Path+'\'+sr.Name);
         while FindNext(sr) = 0 do
         if (sr.Attr or faDirectory)=sr.Attr then
            begin
            if (recur=true) then
               begin
                  if (sr.name<>'.') and (sr.name<>'..') then
                  FileFinder(path+'\'+sr.Name,maska,recur,sl);
               end
            end
         else
         sl.Add(Path+'\'+sr.Name);
      end;
   //FindClose(sr);
end;

end.
