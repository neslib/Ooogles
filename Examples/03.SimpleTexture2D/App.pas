unit App;

{ Based on Simple_Texture2D.c from
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
  TSimpleTexture2DApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FAttrPosition: TGLVertexAttrib;
    FAttrTexCoord: TGLVertexAttrib;
    FUniSampler: TGLUniform;
    FTexture: TGLTexture;
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
  Sample.Texture;

{ TSimpleTexture2DApp }

procedure TSimpleTexture2DApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
begin
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

    'uniform sampler2D s_texture;'#10+

    'void main()'#10+
    '{'#10+
    '  gl_FragColor = texture2D(s_texture, v_texCoord);'#10+
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

  { Initialize uniform }
  FUniSampler.Init(FProgram, 's_texture');

  { Load the texture }
  FTexture := CreateSimpleTexture2D;

  { Set clear color to black }
  gl.ClearColor(0, 0, 0, 0);
end;

procedure TSimpleTexture2DApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TSimpleTexture2DApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
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

  { Bind the texture }
  FTexture.BindToTextureUnit(0);

  { Set the texture sampler to texture unit to 0 }
  FUniSampler.SetValue(0);

  { Draw the quad }
  gl.DrawElements(TGLPrimitiveType.Triangles, INDICES);
end;

procedure TSimpleTexture2DApp.Shutdown;
begin
  { Release resources }
  FTexture.Delete;
  FProgram.Delete;
end;

end.
