unit App;

{ Based on 016_cartoon_torus.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TNoiseTorusApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FNormals: TGLBuffer;
    FTexCoords: TGLBuffer;
    FIndices: TGLBuffer;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
    FTexture: TGLTexture;
    FTorus: TTorusGeometry;
  public
    procedure Initialize; override;
    procedure Render(const ADeltaTimeSec, ATotalTimeSec: Double); override;
    procedure Shutdown; override;
    procedure KeyDown(const AKey: Integer; const AShift: TShiftState); override;
    procedure Resize(const AWidth, AHeight: Integer); override;
  end;

implementation

uses
  {$INCLUDE 'OpenGL.inc'}
  System.UITypes,
  Sample.Math;

{ TNoiseTorusApp }

procedure TNoiseTorusApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
  TexData: array [0..255, 0..255] of Byte;
  U, V: Integer;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec3 Normal;'#10+
    'attribute vec2 TexCoord;'#10+

    'varying vec3 vertNormal;'#10+
    'varying vec3 vertLight;'#10+
    'varying vec2 vertTexCoord;'#10+

    'uniform vec3 LightPos;'#10+

    'void main(void)'#10+
    '{'#10+
    '  gl_Position = ModelMatrix * vec4(Position, 1.0);'#10+
    '  vertNormal = mat3(ModelMatrix)*Normal;'#10+
    '  vertLight = LightPos - gl_Position.xyz;'#10+
    '  vertTexCoord = TexCoord;'#10+
    '  gl_Position = ProjectionMatrix * CameraMatrix * gl_Position;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'uniform sampler2D TexUnit;'#10+

    'varying vec3 vertNormal;'#10+
    'varying vec3 vertLight;'#10+
    'varying vec2 vertTexCoord;'#10+

    'void main(void)'#10+
    '{'#10+
    '  float l = sqrt(length(vertLight));'#10+
    '  float d = (l > 0.0) ? dot('#10+
    '    vertNormal, '#10+
    '    normalize(vertLight)'#10+
    '  ) / l : 0.0;'#10+
    '  float i = 0.2 + 3.2 * max(d, 0.0);'#10+
    '  gl_FragColor = texture2D(TexUnit, vertTexCoord) * i;'#10+
    '}');
  FragmentShader.Compile;

  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  VertexShader.Delete;
  FragmentShader.Delete;

  FProgram.Use;

  FTorus.Generate(72, 48, 1.0, 0.5);

  { Positions }
  FVerts.New(TGLBufferType.Vertex);
  FVerts.Bind;
  FVerts.Data<TVector3>(FTorus.Positions);

  VertAttr.Init(FProgram, 'Position');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Normals }
  FNormals.New(TGLBufferType.Vertex);
  FNormals.Bind;
  FNormals.Data<TVector3>(FTorus.Normals);

  VertAttr.Init(FProgram, 'Normal');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Texture coordinates }
  FTexCoords.New(TGLBufferType.Vertex);
  FTexCoords.Bind;
  FTexCoords.Data<TVector2>(FTorus.TexCoords);

  VertAttr.Init(FProgram, 'TexCoord');
  VertAttr.SetConfig<TVector2>;
  VertAttr.Enable;

  { Indices }
  FIndices.New(TGLBufferType.Index);
  FIndices.Bind;
  FIndices.Data<UInt16>(FTorus.Indices);

  { Don't need data anymore }
  FTorus.Clear;

  { Texture }
  for V := 0 to 255 do
    for U := 0 to 255 do
      TexData[V, U] := Random(256);
  FTexture.New;
  FTexture.Bind;
  FTexture.MinFilter(TGLMinFilter.Linear);
  FTexture.MagFilter(TGLMagFilter.Linear);
  FTexture.WrapS(TGLWrapMode.NormalRepeat);
  FTexture.WrapT(TGLWrapMode.NormalRepeat);
  FTexture.Upload(TGLPixelFormat.Luminance, 256, 256, @TexData);

  { Uniforms }
  Uniform.Init(FProgram, 'TexUnit');
  Uniform.SetValue(0);

  Uniform.Init(FProgram, 'LightPos');
  Uniform.SetValue(4.0, 4.0, -8.0);

  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');

  gl.ClearColor(0.8, 0.8, 0.7, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
  gl.Enable(TGLCapability.CullFace);
  gl.FrontFace(TGLFaceOrientation.CounterClockwise);
  gl.CullFace(TGLFace.Back);
end;

procedure TNoiseTorusApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TNoiseTorusApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  CameraMatrix, ModelMatrix: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  { Use the program }
  FProgram.Use;

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 4.5, Radians(ATotalTimeSec * 35),
    Radians(FastSin(Pi * ATotalTimeSec / 10) * 60), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Update and render the torus }
  ModelMatrix.InitRotationX(Pi * ATotalTimeSec * 0.5);
  FUniModelMatrix.SetValue(ModelMatrix);
  FTorus.DrawWithBoundIndexBuffer;
end;

procedure TNoiseTorusApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(60), AWidth / AHeight, 1, 20);
  FProgram.Use;
  FUniProjectionMatrix.SetValue(ProjectionMatrix);
end;

procedure TNoiseTorusApp.Shutdown;
begin
  { Release resources }
  FTexture.Delete;
  FIndices.Delete;
  FTexCoords.Delete;
  FNormals.Delete;
  FVerts.Delete;
  FProgram.Delete;
end;

end.
