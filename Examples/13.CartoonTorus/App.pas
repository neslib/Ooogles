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
  TCartoonTorusApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FNormals: TGLBuffer;
    FIndices: TGLBuffer;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
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

{ TCartoonTorusApp }

procedure TCartoonTorusApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec3 Normal;'#10+

    'varying vec3 vertNormal;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vertNormal = mat3(ModelMatrix) * Normal;'#10+
    '  gl_Position = '#10+
    '    ProjectionMatrix *'#10+
    '    CameraMatrix *'#10+
    '    ModelMatrix *'#10+
    '    vec4(Position, 1.0);'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'varying vec3 vertNormal;'#10+

    'uniform vec3 LightPos;'#10+

    'void main(void)'#10+
    '{'#10+
    '  float intensity = 2.0 * max('#10+
    '    dot(vertNormal,  LightPos)/'#10+
    '    length(LightPos),'#10+
    '    0.0);'#10+
    '  if (!gl_FrontFacing)'#10+
    '  {'#10+
    '    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);'#10+
    '  }'#10+
    '  else if (intensity > 0.9)'#10+
    '  {'#10+
    '    gl_FragColor = vec4(1.0, 0.9, 0.8, 1.0);'#10+
    '  }'#10+
    '  else if (intensity > 0.1)'#10+
    '  {'#10+
    '    gl_FragColor = vec4(0.7, 0.6, 0.4, 1.0);'#10+
    '  }'#10+
    '  else'#10+
    '  {'#10+
    '    gl_FragColor = vec4(0.3, 0.2, 0.1, 1.0);'#10+
    '  }'#10+
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

  { Indices }
  FIndices.New(TGLBufferType.Index);
  FIndices.Bind;
  FIndices.Data<UInt16>(FTorus.Indices);

  { Don't need data anymore }
  FTorus.Clear;

  { Uniforms }
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

procedure TCartoonTorusApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TCartoonTorusApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  RotationX, RotationY, CameraMatrix, ModelMatrix: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  { Use the program }
  FProgram.Use;

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 3.5, Radians(ATotalTimeSec * 35),
    Radians(FastSin(Pi * ATotalTimeSec / 10) * 60), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Update and render the torus }
  RotationY.InitRotationY(ATotalTimeSec * Pi * 0.5);
  RotationX.InitRotationX(Pi * 0.5);
  ModelMatrix := RotationY * RotationX;
  FUniModelMatrix.SetValue(ModelMatrix);
  FTorus.DrawWithBoundIndexBuffer;
end;

procedure TCartoonTorusApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(70), AWidth / AHeight, 1, 30);
  FProgram.Use;
  FUniProjectionMatrix.SetValue(ProjectionMatrix);
end;

procedure TCartoonTorusApp.Shutdown;
begin
  { Release resources }
  FIndices.Delete;
  FNormals.Delete;
  FVerts.Delete;
  FProgram.Delete;
end;

end.
