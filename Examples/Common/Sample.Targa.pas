unit Sample.Targa;

{$INCLUDE 'Sample.inc'}

interface

uses
  Neslib.Ooogles;

type
  TPixel = array [0..3] of Byte;

type
  TTgaImage = record
  public
    Width: Integer;
    Height: Integer;
    Data: TArray<TPixel>;
  public
    function Load(const APath: String): Boolean;
    function ToTexture: TGLTexture;
  end;

implementation

uses
  {$INCLUDE 'OpenGL.inc'}
  System.SysUtils,
  Sample.Assets;

type
  TTgaHeader = packed record
    Size: UInt8;
    MapType: UInt8;
    ImageType: UInt8;
    PaletteStart: UInt16;
    PaletteSize: UInt16;
    PaletteEntryDepth: UInt8;
    X: UInt16;
    Y: UInt16;
    Width: UInt16;
    Height: UInt16;
    ColorDepth: UInt8;
    Descriptor: UInt8;
  end;

const
  INVERTED_BIT = 1 shl 5;

{ TTgaImage }

function TTgaImage.Load(const APath: String): Boolean;
var
  Bytes: TBytes;
  Header: TTgaHeader;
  X, Y, PixelComponentCount, RowIdx, PixelIdx, TargetIdx: Integer;
  Pixel: TPixel;
begin
  Bytes := TAssets.Load(APath);
  if (Length(Bytes) < SizeOf(Header)) then
    Exit(False);

  Move(Bytes[0], Header, SizeOf(Header));
  Width := Header.Width;
  Height := Header.Height;
  PixelComponentCount := Header.ColorDepth div 8;
  if (Width = 0) or (Height = 0) or (PixelComponentCount = 0) then
    Exit(False);

  SetLength(Data, Width * Height);
  TargetIdx := 0;
  for Y := 0 to Height - 1 do
  begin
    if ((Header.Descriptor and INVERTED_BIT) <> 0) then
      RowIdx := Height - 1 - Y
    else
      RowIdx := Y;
    RowIdx := SizeOf(Header) + (RowIdx * Width * PixelComponentCount);

    for X := 0 to Width - 1 do
    begin
      PixelIdx := RowIdx + (X * PixelComponentCount);
      Cardinal(Pixel) := $FF000000;

      if (PixelComponentCount > 2) then
        Pixel[0] := Bytes[PixelIdx + 2];

      if (PixelComponentCount > 1) then
        Pixel[1] := Bytes[PixelIdx + 1];

      if (PixelComponentCount > 0) then
        Pixel[2] := Bytes[PixelIdx + 0];

      if (PixelComponentCount > 3) then
        Pixel[3] := Bytes[PixelIdx + 3];

      Data[TargetIdx] := Pixel;
      Inc(TargetIdx);
    end;
  end;
  Result := True;
end;

function TTgaImage.ToTexture: TGLTexture;
begin
  Result.New;
  Result.Bind;
  Result.MinFilter(TGLMinFilter.LinearMipmapLinear);
  Result.MagFilter(TGLMagFilter.Linear);
  gl.PixelStore(TGLPixelStoreMode.UnpackAlignment, TGLPixelStoreValue.One);
  Result.Upload(TGLPixelFormat.RGBA, Width, Height, @Data[0]);
  Result.GenerateMipmap;
end;

end.
