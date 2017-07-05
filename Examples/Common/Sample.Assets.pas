unit Sample.Assets;

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Zip;

type
  { Static class for managing assets.

    For easy deployment, all assets are stored in a single ZIP file called
    assets.zip. This ZIP file is linked into the executable as a resource named
    ASSETS.

    For maximum portability, all file names and folder names in the ZIP file
    should be in lower case.

    To add the assets.zip file to your project in Delphi, go to "Project |
    Resources and Images..." and add the assets.zip file and set the "Resource
    identifier" to ASSETS. }
  TAssets = class // static
  {$REGION 'Internal Declarations'}
  private class var
    FStream: TResourceStream;
    FZipFile: TZipFile;
  public
    class constructor Create;
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    { Initializes the asset manager.
      Must be called before calling any other methods. }
    class procedure Initialize; static;

    { Loads a file into a byte array.

      Parameters:
        APath: the path to the file in assets.zip. If the path contains
          directories, forward slashes ('/') should be used.

      Returns:
        A byte array containing the file data. }
    class function Load(const APath: String): TBytes; static;

    { Loads a file into a RawByteString.

      Parameters:
        APath: the path to the file in assets.zip. If the path contains
          directories, forward slashes ('/') should be used.

      Returns:
        A RawByteString containing the file data. }
    class function LoadRawByteString(const APath: String): RawByteString; static;
  end;

implementation

uses
  System.Types;

{ TAssets }

class constructor TAssets.Create;
begin
  FStream := nil;
  FZipFile := nil;
end;

class destructor TAssets.Destroy;
begin
  FZipFile.DisposeOf;
  FZipFile := nil;

  FStream.DisposeOf;
  FStream := nil;
end;

class procedure TAssets.Initialize;
begin
  if (FStream = nil) then
    FStream := TResourceStream.Create(HInstance, 'ASSETS', RT_RCDATA);

  if (FZipFile = nil) then
  begin
    FZipFile := TZipFile.Create;
    FZipFile.Open(FStream, TZipMode.zmRead);
  end;
end;

class function TAssets.Load(const APath: String): TBytes;
begin
  Assert(Assigned(FZipFile));
  FZipFile.Read(APath, Result);
end;

class function TAssets.LoadRawByteString(const APath: String): RawByteString;
var
  Data: TBytes;
begin
  Assert(Assigned(FZipFile));
  FZipFile.Read(APath, Data);
  if (Data = nil) then
    Result := ''
  else
  begin
    SetLength(Result, Length(Data));
    Move(Data[0], Result[Low(RawByteString)], Length(Data));
  end;
end;

end.
