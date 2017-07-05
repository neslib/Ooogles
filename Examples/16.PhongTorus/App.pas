unit App;

{ Based on 017_phong_torus.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TPhongTorusApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FNormals: TGLBuffer;
    FColors: TGLBuffer;
    FIndices: TGLBuffer;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FTorus: TTwistedTorusGeometry;
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

{ TPhongTorusApp }

procedure TPhongTorusApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
  Lights: array [0..2] of TVector3;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec3 Normal;'#10+
    'attribute vec3 Color;'#10+

    'varying vec3 vertColor;'#10+
    'varying vec3 vertNormal;'#10+
    'varying vec3 vertViewDir;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vertColor = normalize(vec3(1.0, 1.0, 1.0) - Color);'#10+
    '  vertNormal = Normal;'#10+
    '  vertViewDir = (vec4(0.0, 0.0, 1.0, 1.0) * CameraMatrix).xyz;'#10+
    '  gl_Position = ProjectionMatrix * CameraMatrix * vec4(Position, 1.0);'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'varying vec3 vertColor;'#10+
    'varying vec3 vertNormal;'#10+
    'varying vec3 vertViewDir;'#10+

    'uniform vec3 LightPos[3];'#10+

    'void main(void)'#10+
    '{'#10+
    '  float amb = 0.2;'#10+
    '  float diff = 0.0;'#10+
    '  float spec = 0.0;'#10+
    '  for (int i=0; i != 3; ++i)'#10+
    '  {'#10+
    '    diff += max('#10+
    '      dot(vertNormal,  LightPos[i]) /'#10+
    '      dot(LightPos[i], LightPos[i]), '#10+
    '      0.0);'#10+
    '    float k = dot(vertNormal, LightPos[i]);'#10+
    '    vec3 r = 2.0*k*vertNormal - LightPos[i];'#10+
    '    spec += pow(max('#10+
    '      dot(normalize(r), vertViewDir),'#10+
    '      0.0), 32.0 * dot(r, r));'#10+
    '  }'#10+
    '  gl_FragColor = '#10+
    '    vec4(vertColor, 1.0) * (amb + diff) +'#10+
    '    vec4(1.0, 1.0, 1.0, 1.0) * spec;'#10+
    '}');
  FragmentShader.Compile;

  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  VertexShader.Delete;
  FragmentShader.Delete;

  FProgram.Use;

  FTorus.Generate;

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

  { Colors }
  FColors.New(TGLBufferType.Vertex);
  FColors.Bind;
  FColors.Data<TVector3>(FTorus.Tangents);

  VertAttr.Init(FProgram, 'Color');
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
  Lights[0].Init(2, -1,  0);
  Lights[1].Init(0,  3, -1);
  Lights[2].Init(0, -1,  4);
  Uniform.SetValues(Lights);

  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');

  gl.ClearColor(0.8, 0.8, 0.7, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
  gl.Enable(TGLCapability.CullFace);
  gl.FrontFace(TGLFaceOrientation.CounterClockwise);
  gl.CullFace(TGLFace.Back);
end;

procedure TPhongTorusApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TPhongTorusApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  CameraMatrix: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  { Use the program }
  FProgram.Use;

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 5.0, Radians(ATotalTimeSec * Pi * 2),
    Radians(Pi * ATotalTimeSec / 8) * 90, CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Render the torus }
  FTorus.Draw;
end;

procedure TPhongTorusApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(60), AWidth / AHeight, 1, 30);
  FProgram.Use;
  FUniProjectionMatrix.SetValue(ProjectionMatrix);
end;

procedure TPhongTorusApp.Shutdown;
begin
  { Release resources }
  FIndices.Delete;
  FColors.Delete;
  FNormals.Delete;
  FVerts.Delete;
  FProgram.Delete;
end;

end.
