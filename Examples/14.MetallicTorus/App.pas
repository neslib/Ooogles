unit App;

{ Based on 016_metallic_torus.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TMetallicTorusApp = class(TApplication)
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

{ TMetallicTorusApp }

procedure TMetallicTorusApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
  Color: array [0..7] of TVector4;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec3 Normal;'#10+

    'varying vec3 vertNormal;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vertNormal = mat3(CameraMatrix) * mat3(ModelMatrix) * Normal;'#10+
    '  gl_Position = '#10+
    '    ProjectionMatrix *'#10+
    '    CameraMatrix *'#10+
    '    ModelMatrix *'#10+
    '    vec4(Position, 1.0);'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'uniform int ColorCount;'#10+
    'uniform vec4 Color[8];'#10+

    'varying vec3 vertNormal;'#10+

    'vec3 ViewDir = vec3(0.0, 0.0, 1.0);'#10+
    'vec3 TopDir = vec3(0.0, 1.0, 0.0);'#10+

    'void main(void)'#10+
    '{'#10+
    '  float k = dot(vertNormal, ViewDir);'#10+
    '  vec3 reflDir = 2.0 * k * vertNormal - ViewDir;'#10+
    '  float a = dot(reflDir, TopDir);'#10+
    '  vec3 reflColor = vec3(0.0);'#10+

    '  for(int i = 0; i != (ColorCount - 1); ++i)'#10+
    '  {'#10+
    '    if ((a<Color[i].a) && (a >= Color[i+1].a))'#10+
    '    {'#10+
    '      float m = '#10+
    '        (a - Color[i].a) / '#10+
    '        (Color[i+1].a - Color[i].a);'#10+
    '      reflColor = mix('#10+
    '        Color[i].rgb,'#10+
    '        Color[i+1].rgb,'#10+
    '        m'#10+
    '      );'#10+
    '      break;'#10+
    '    }'#10+
    '  }'#10+
    '  float i = max(dot(vertNormal, TopDir), 0.0);'#10+
    '  vec3 diffColor = vec3(i, i, i);'#10+
    '  gl_FragColor = vec4('#10+
    '    mix(reflColor, diffColor, 0.3 + i * 0.7),'#10+
    '    1.0'#10+
    '  );'#10+
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

  { Setup the color gradient }
  Uniform.Init(FProgram, 'ColorCount');
  Uniform.SetValue(8);

  Uniform.Init(FProgram, 'Color');
  Color[0].Init(1.0, 1.0, 0.9, 1.00);
  Color[1].Init(1.0, 0.9, 0.8, 0.97);
  Color[2].Init(0.9, 0.7, 0.5, 0.95);
  Color[3].Init(0.5, 0.5, 1.0, 0.95);
  Color[4].Init(0.2, 0.2, 0.7, 0.00);
  Color[5].Init(0.1, 0.1, 0.1, 0.00);
  Color[6].Init(0.2, 0.2, 0.2,-0.10);
  Color[7].Init(0.5, 0.5, 0.5,-1.00);
  Uniform.SetValues(Color);

  { Other uniforms }
  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');

  gl.ClearColor(0.1, 0.1, 0.1, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
  gl.Enable(TGLCapability.CullFace);
  gl.FrontFace(TGLFaceOrientation.CounterClockwise);
  gl.CullFace(TGLFace.Back);
end;

procedure TMetallicTorusApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TMetallicTorusApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  CameraMatrix, ModelMatrix: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  { Use the program }
  FProgram.Use;

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 3.5, Radians(ATotalTimeSec * 35),
    Radians(FastSin(Pi * ATotalTimeSec / 30) * 80), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Update and render the torus }
  ModelMatrix.InitRotationX(ATotalTimeSec * Pi * 0.5);
  FUniModelMatrix.SetValue(ModelMatrix);
  FTorus.DrawWithBoundIndexBuffer;
end;

procedure TMetallicTorusApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(70), AWidth / AHeight, 1, 20);
  FProgram.Use;
  FUniProjectionMatrix.SetValue(ProjectionMatrix);
end;

procedure TMetallicTorusApp.Shutdown;
begin
  { Release resources }
  FIndices.Delete;
  FNormals.Delete;
  FVerts.Delete;
  FProgram.Delete;
end;

end.
