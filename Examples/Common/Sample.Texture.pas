unit Sample.Texture;

{$INCLUDE 'Sample.inc'}

interface

uses
  Neslib.Ooogles;

function CreateSimpleTexture2D: TGLTexture;

function CreateMipmappedTexture2D: TGLTexture;

function CreateSimpleTextureCubeMap: TGLTexture;

function LoadTexture(const APath: String): TGLTexture;

implementation

uses
  System.SysUtils,
  {$INCLUDE 'OpenGL.inc'}
  Sample.Targa;

function CreateSimpleTexture2D: TGLTexture;
const
  WIDTH = 2;
  HEIGHT = 2;
  PIXELS: array [0..WIDTH * HEIGHT * 3 - 1] of Byte = (
    255,   0,   0,  // Red
      0, 255,   0,  // Green
      0,   0, 255,  // Blue
    255, 255,   0); // Yellow
begin
  { Use tightly packed data }
  gl.PixelStore(TGLPixelStoreMode.UnpackAlignment, TGLPixelStoreValue.One);

  { Generate a texture object }
  Result.New;

  { Bind the texture object }
  Result.Bind;

  { Load the texture: 2x2 Image, 3 bytes per pixel (R, G, B) }
  Result.Upload(TGLPixelFormat.RGB, WIDTH, HEIGHT, @PIXELS);

  { Set the filtering mode }
  Result.MinFilter(TGLMinFilter.Nearest);
  Result.MagFilter(TGLMagFilter.Nearest);
end;

function CreateMipmappedTexture2D: TGLTexture;
const
  WIDTH = 256;
  HEIGHT = 256;
  CHECKER_SIZE = 8;
var
  Pixels: TBytes;
  X, Y: Integer;
  R, B: Byte;
begin
  SetLength(Pixels, WIDTH * HEIGHT * 3);
  for Y := 0 to HEIGHT - 1 do
  begin
    for X := 0 to WIDTH - 1 do
    begin
      if (((X div CHECKER_SIZE) and 1) = 0) then
      begin
        R := 255 * ((Y div CHECKER_SIZE) and 1);
        B := 255 * (1 - ((Y div CHECKER_SIZE) and 1));
      end
      else
      begin
        B := 255 * ((Y div CHECKER_SIZE) and 1);
        R := 255 * (1 - ((Y div CHECKER_SIZE) and 1));
      end;

      Pixels[(Y * HEIGHT + X) * 3 + 0] := R;
      Pixels[(Y * HEIGHT + X) * 3 + 1] := 0;
      Pixels[(Y * HEIGHT + X) * 3 + 2] := B;
    end;
  end;

  { Generate a texture object }
  Result.New;

  { Bind the texture object }
  Result.Bind;

  { Load mipmap level 0 }
  Result.Upload(TGLPixelFormat.RGB, WIDTH, HEIGHT, @Pixels[0]);

  { Generate mipmaps }
  Result.GenerateMipmap;

  { Set the filtering mode }
  Result.MinFilter(TGLMinFilter.NearestMipmapNearest);
  Result.MagFilter(TGLMagFilter.Linear);
end;

function CreateSimpleTextureCubeMap: TGLTexture;
const
  PIXELS: array [0..5, 0..2] of Byte = (
    // Face 0 - Red
    (255,   0,   0),

    // Face 1 - Green,
    (  0, 255,   0),

    // Face 3 - Blue
    (  0,   0, 255),

    // Face 4 - Yellow
    (255, 255,   0),

    // Face 5 - Purple
    (255,   0, 255),

    // Face 6 - White
    (255, 255, 255));
var
  I: Integer;
begin
  { Generate a texture object }
  Result.New(TGLTextureType.CubeMap);

  { Bind the texture object }
  Result.Bind;

  for I := 0 to 5 do
    Result.Upload(TGLPixelFormat.RGB, 1, 1, @PIXELS[I], 0,
      TGLPixelDataType.UnsignedByte, I);

  { Set the filtering mode }
  Result.MinFilter(TGLMinFilter.Nearest);
  Result.MagFilter(TGLMagFilter.Nearest);
end;

function LoadTexture(const APath: String): TGLTexture;
var
  Image: TTgaImage;
begin
  if Image.Load(APath) then
    Result := Image.ToTexture
  else
    raise Exception.Create('Unable to load texture ' + APath);
end;

end.
