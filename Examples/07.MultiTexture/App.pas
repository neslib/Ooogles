unit App;

{ Based on MultiTexture.c from
  Book:      OpenGL(R) ES 2.0 Programming Guide
  Authors:   Aaftab Munshi, Dan Ginsburg, Dave Shreiner
  ISBN-10:   0321502795
  ISBN-13:   9780321502797
  Publisher: Addison-Wesley Professional
  URLs:      http://safari.informit.com/9780321563835
             http://www.opengles-book.com }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App;

type
  TMultiTextureApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FAttrPosition: TGLVertexAttrib;
    FAttrTexCoord: TGLVertexAttrib;
    FUniBaseMap: TGLUniform;
    FUniLightMap: TGLUniform;
    FTexBaseMap: TGLTexture;
    FTexLightMap: TGLTexture;
  public
    procedure Initialize; override;
    procedure Render(const ADeltaTimeSec, ATotalTimeSec: Double); override;
    procedure Shutdown; override;
    procedure KeyDown(const AKey: Integer; const AShift: TShiftState); override;
  end;

implementation

uses
  {$INCLUDE 'OpenGL.inc'}
  System.UITypes,
  Sample.Texture,
  Sample.Assets;

{ TMultiTextureApp }

procedure TMultiTextureApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
begin
  { Initialize the asset manager }
  TAssets.Initialize;

  { Compile vertex and fragment shaders }
  VertexShader.New(TGLShaderType.Vertex,
    'attribute vec4 a_position;'#10+
    'attribute vec2 a_texCoord;'#10+

    'varying vec2 v_texCoord;'#10+

    'void main()'#10+
    '{'#10+
    '  gl_Position = a_position;'#10+
    '  v_texCoord = a_texCoord;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'varying vec2 v_texCoord;'#10+

    'uniform sampler2D s_baseMap;'#10+
    'uniform sampler2D s_lightMap;'#10+

    'void main()'#10+
    '{'#10+
    '  vec4 baseColor;'#10+
    '  vec4 lightColor;'#10+

    '  baseColor = texture2D(s_baseMap, v_texCoord);'#10+
    '  lightColor = texture2D(s_lightMap, v_texCoord);'#10+

    '  gl_FragColor = baseColor * (lightColor + 0.25);'#10+
    '}');
  FragmentShader.Compile;

  { Link shaders into program }
  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  { We don't need the shaders anymore. Note that the shaders won't actually be
    deleted until the program is deleted. }
  VertexShader.Delete;
  FragmentShader.Delete;

  { Initialize vertex attributes }
  FAttrPosition.Init(FProgram, 'a_position');
  FAttrTexCoord.Init(FProgram, 'a_texCoord');

  { Initialize uniforms }
  FUniBaseMap.Init(FProgram, 's_baseMap');
  FUniLightMap.Init(FProgram, 's_lightMap');

  { Load the textures }
  FTexBaseMap := LoadTexture('basemap.tga');
  FTexLightMap := LoadTexture('lightmap.tga');

  { Set clear color to black }
  gl.ClearColor(0, 0, 0, 0);
end;

procedure TMultiTextureApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TMultiTextureApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
type
  TVertex = record
    Pos: TVector3;
    TexCoord: TVector2;
  end;
const
  VERTICES: array [0..3] of TVertex = (
    (Pos: (X: -0.5; Y:  0.5; Z: 0.0); TexCoord: (X: 0.0; Y: 0.0)),
    (Pos: (X: -0.5; Y: -0.5; Z: 0.0); TexCoord: (X: 0.0; Y: 1.0)),
    (Pos: (X:  0.5; Y: -0.5; Z: 0.0); TexCoord: (X: 1.0; Y: 1.0)),
    (Pos: (X:  0.5; Y:  0.5; Z: 0.0); TexCoord: (X: 1.0; Y: 0.0)));
  INDICES: array [0..5] of UInt16 = (
    0, 1, 2, 0, 2, 3);
begin
  { Clear the color buffer }
  gl.Clear([TGLClear.Color]);

  { Use the program }
  FProgram.Use;

  { Set the data for the vertex attributes }
  FAttrPosition.SetData(TGLDataType.Float, 3, @VERTICES[0].Pos, SizeOf(TVertex));
  FAttrPosition.Enable;
  FAttrTexCoord.SetData(TGLDataType.Float, 2, @VERTICES[0].TexCoord, SizeOf(TVertex));
  FAttrTexCoord.Enable;

  { Bind the base map }
  FTexBaseMap.BindToTextureUnit(0);

  { Set the base map sampler to texture unit to 0 }
  FUniBaseMap.SetValue(0);

  { Bind the light map }
  FTexLightMap.BindToTextureUnit(1);

  { Set the light map sampler to texture unit to 1 }
  FUniLightMap.SetValue(1);

  { Draw the quad }
  gl.DrawElements(TGLPrimitiveType.Triangles, INDICES);
end;

procedure TMultiTextureApp.Shutdown;
begin
  { Release resources }
  FTexLightMap.Delete;
  FTexBaseMap.Delete;
  FProgram.Delete;
end;

end.
