unit App;

{ Based on 019_helium.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TParticle = record
  private
    FProgram: TGLProgram;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
    FUniLightPos: TGLUniform;
    FVerts: TGLBuffer;
    FNormals: TGLBuffer;
    FIndices: TGLBuffer;
    FSphere: TSphereGeometry;
  public
    procedure New(const AVertexShader, AFragmentShader: TGLShader);
    procedure Delete;

    procedure SetProjection(const AProjection: TMatrix4);
    procedure SetLightAndCamera(const ALight: TVector3;
      const ACamera: TMatrix4);
    procedure Render(const AModel: TMatrix4);
  end;

type
  THeliumApp = class(TApplication)
  private
    FProton: TParticle;
    FNeutron: TParticle;
    FElectron: TParticle;
  private
    class function CreateFragmentShader(const ASource: RawByteString): TGLShader; static;
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

const
  // The common first part of all fragment shader sources
  FS_PROLOGUE =
    'precision mediump float;'#10+

    'varying vec3 vertNormal;'#10+
    'varying vec3 vertLight;'#10+
    'varying vec3 vertViewNormal;'#10+

    'void main(void)'#10+
    '{'#10+
    '  float lighting = dot('#10+
    '    vertNormal, '#10+
    '    normalize(vertLight));'#10+

    '  float intensity = clamp('#10+
    '    0.4 + lighting * 1.0,'#10+
    '    0.0,'#10+
    '    1.0);';

const
  // The common last part of all fragment shader sources
  FS_EPILOGUE =
    '  gl_FragColor = sig ? '#10+
    '    vec4(1.0, 1.0, 1.0, 1.0):'#10+
    '    vec4(color * intensity, 1.0);'#10+
    '}';

const
  // The part calculating the color for the protons
  FS_PROTON =
    '  bool sig = ('#10+
    '    abs(vertViewNormal.x) < 0.5 &&'#10+
    '    abs(vertViewNormal.y) < 0.2 '#10+
    '  ) || ('#10+
    '    abs(vertViewNormal.y) < 0.5 &&'#10+
    '    abs(vertViewNormal.x) < 0.2 '#10+
    '  );'#10+
    '  vec3 color = vec3(1.0, 0.0, 0.0);';

const
  // The part calculating the color for the neutrons
  FS_NEUTRON =
    '  bool sig = false;'#10+
    '  vec3 color = vec3(0.5, 0.5, 0.5);';

const
  // The part calculating the color for the electrons
  FS_ELECTRON =
    '  bool sig = ('#10+
    '    abs(vertViewNormal.x) < 0.5 &&'#10+
    '    abs(vertViewNormal.y) < 0.2'#10+
    '  );'#10+
    '  vec3 color = vec3(0.0, 0.0, 1.0);';

{ THeliumApp }

class function THeliumApp.CreateFragmentShader(
  const ASource: RawByteString): TGLShader;
begin
  Result.New(TGLShaderType.Fragment, FS_PROLOGUE + ASource + FS_EPILOGUE);
  Result.Compile;
end;

procedure THeliumApp.Initialize;
var
  VertexShader: TGLShader;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec3 Normal;'#10+

    'varying vec3 vertNormal;'#10+
    'varying vec3 vertLight;'#10+
    'varying vec3 vertViewNormal;'#10+

    'uniform vec3 LightPos;'#10+

    'void main(void)'#10+
    '{'#10+
    '  gl_Position = ModelMatrix * vec4(Position, 1.0);'#10+
    '  vertNormal = mat3(ModelMatrix) * Normal;'#10+
    '  vertViewNormal = mat3(CameraMatrix) * vertNormal;'#10+
    '  vertLight = LightPos - gl_Position.xyz;'#10+
    '  gl_Position = ProjectionMatrix * CameraMatrix * gl_Position;'#10+
    '}');
  VertexShader.Compile;

  FProton.New(VertexShader, CreateFragmentShader(FS_PROTON));
  FNeutron.New(VertexShader, CreateFragmentShader(FS_NEUTRON));
  FElectron.New(VertexShader, CreateFragmentShader(FS_ELECTRON));

  { Don't need vertex shader anymore }
  VertexShader.Delete;

  gl.ClearColor(0.3, 0.3, 0.3, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
end;

procedure THeliumApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure THeliumApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  Light: TVector3;
  Nucl, Camera, Model, Rotate: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  Light.Init(8, 8, 8);

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 21.0, Radians(ATotalTimeSec * 15),
    Radians((Pi * ATotalTimeSec * 0.30) * 45), Camera);

  Nucl.InitRotation(Vector3(1, 1, 1), ATotalTimeSec * 2 * Pi);

  FProton.SetLightAndCamera(Light, Camera);
  Model.InitTranslation(1.4, 0, 0);
  FProton.Render(Nucl * Model);
  Model.InitTranslation(-1.4, 0, 0);
  FProton.Render(Nucl * Model);

  FNeutron.SetLightAndCamera(Light, Camera);
  Model.InitTranslation(0, 0, 1);
  FNeutron.Render(Nucl * Model);
  Model.InitTranslation(0, 0, -1);
  FNeutron.Render(Nucl * Model);

  FElectron.SetLightAndCamera(Light, Camera);

  Rotate.InitRotationY(ATotalTimeSec * Pi * 1.4);
  Model.InitTranslation(10, 0, 0);
  FElectron.Render(Rotate * Model);

  Rotate.InitRotationX(ATotalTimeSec * Pi * 1.4);
  Model.InitTranslation(0, 0, 10);
  FElectron.Render(Rotate * Model);
end;

procedure THeliumApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(45), AWidth / AHeight, 1, 50);
  FProton.SetProjection(ProjectionMatrix);
  FNeutron.SetProjection(ProjectionMatrix);
  FElectron.SetProjection(ProjectionMatrix);
end;

procedure THeliumApp.Shutdown;
begin
  { Release resources }
  FProton.Delete;
  FNeutron.Delete;
  FElectron.Delete;
end;

{ TParticle }

procedure TParticle.Delete;
begin
  FProgram.Delete;
  FVerts.Delete;
  FNormals.Delete;
  FIndices.Delete;
end;

procedure TParticle.New(const AVertexShader, AFragmentShader: TGLShader);
var
  VertAttr: TGLVertexAttrib;
begin
  FProgram.New(AVertexShader, AFragmentShader);
  FProgram.Link;
  FProgram.Use;

  { Don't need fragment shader anymore (vertex shader is shared though) }
  AFragmentShader.Delete;

  { Initialize uniforms }
  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');
  FUniLightPos.Init(FProgram, 'LightPos');

  FSphere.Generate(18, 1.0);

  { Positions }
  FVerts.New(TGLBufferType.Vertex);
  FVerts.Bind;
  FVerts.Data<TVector3>(FSphere.Positions);

  VertAttr.Init(FProgram, 'Position');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Normals }
  FNormals.New(TGLBufferType.Vertex);
  FNormals.Bind;
  FNormals.Data<TVector3>(FSphere.Normals);

  VertAttr.Init(FProgram, 'Normal');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Indices }
  FIndices.New(TGLBufferType.Index);
  FIndices.Bind;
  FIndices.Data<UInt16>(FSphere.Indices);

  { Don't need data anymore }
  FSphere.Clear;
end;

procedure TParticle.Render(const AModel: TMatrix4);
begin
  FProgram.Use;
  FUniModelMatrix.SetValue(AModel);
  FVerts.Bind;
  FNormals.Bind;
  FSphere.DrawWithBoundIndexBuffer;
end;

procedure TParticle.SetLightAndCamera(const ALight: TVector3;
  const ACamera: TMatrix4);
begin
  FProgram.Use;
  FUniLightPos.SetValue(ALight);
  FUniCameraMatrix.SetValue(ACamera);
end;

procedure TParticle.SetProjection(const AProjection: TMatrix4);
begin
  FProgram.Use;
  FUniProjectionMatrix.SetValue(AProjection);
end;

end.
