unit App;

{ Based on 020_shaded_objects.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TShape = class abstract
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FNormals: TGLBuffer;
    FTexCoords: TGLBuffer;
    FIndices: TGLBuffer;
    FAttrVerts: TGLVertexAttrib;
    FAttrNormals: TGLVertexAttrib;
    FAttrTexCoords: TGLVertexAttrib;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
    FUniLightPos: TGLUniform;
  public
    constructor Create(const AVertexShader, AFragmentShader: TGLShader;
      const AVerts, ANormals: TArray<TVector3>;
      const ATexCoords: TArray<TVector2>; const AIndices: TArray<UInt16>);
    destructor Destroy; override;

    procedure SetProjection(const AProjection: TMatrix4);
    procedure Render(const ALight: TVector3; const ACamera, AModel: TMatrix4); virtual;
  end;

type
  TSphere = class(TShape)
  private
    FSphere: TSphereGeometry;
  public
    constructor Create(const AVertexShader, AFragmentShader: TGLShader);
    procedure Render(const ALight: TVector3; const ACamera, AModel: TMatrix4); override;
  end;

type
  TCube = class(TShape)
  private
    FCube: TCubeGeometry;
  public
    constructor Create(const AVertexShader, AFragmentShader: TGLShader);
    procedure Render(const ALight: TVector3; const ACamera, AModel: TMatrix4); override;
  end;

type
  TTorus = class(TShape)
  private
    FTorus: TTorusGeometry;
  public
    constructor Create(const AVertexShader, AFragmentShader: TGLShader);
    procedure Render(const ALight: TVector3; const ACamera, AModel: TMatrix4); override;
  end;

type
  TShadedObjectsApp = class(TApplication)
  private
    FSphere: TSphere;
    FCubeX: TCube;
    FCubeY: TCube;
    FCubeZ: TCube;
    FTorus: TTorus;
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

    'varying vec2 vertTexCoord;'#10+
    'varying vec3 vertNormal;'#10+
    'varying vec3 vertLight;'#10+

    'void main(void)'#10+
    '{'#10+
    '  float Len = dot(vertLight, vertLight);'#10+
    '  float Dot = Len > 0.0 ? dot('#10+
    '    vertNormal, '#10+
    '    normalize(vertLight)'#10+
    '  ) / Len : 0.0;'#10+
    '  float Intensity = 0.2 + max(Dot, 0.0) * 4.0;';

const
  // The common last part of all fragment shader sources
  FS_EPILOGUE =
    '  gl_FragColor = vec4(Color * Intensity, 1.0);'#10+
    '}';

const
  // The part calculating the color for the black/white checker shader
  FS_BW_CHECKER =
    '  float c = floor(mod('#10+
    '    1.0 +'#10+
    '    floor(mod(vertTexCoord.x * 8.0, 2.0)) +'#10+
    '    floor(mod(vertTexCoord.y * 8.0, 2.0)), '#10+
    '    2.0));'#10+
    '  vec3 Color = vec3(c, c, c);';

const
  // The part calculating the color for the yellow/black strips shader
  FS_YB_STRIPS =
    '  float m = floor(mod((vertTexCoord.x + vertTexCoord.y) * 16.0, 2.0));'#10+
    '  vec3 Color = mix('#10+
    '    vec3(0.0, 0.0, 0.0),'#10+
    '    vec3(1.0, 1.0, 0.0),'#10+
    '    m);';

const
  // The part calculating the color for the white/orange strips shader
  FS_WO_VSTRIPS =
    '  float m = floor(mod(vertTexCoord.x * 8.0, 2.0));'#10+
    '  vec3 Color = mix('#10+
    '    vec3(1.0, 0.6, 0.1),'#10+
    '    vec3(1.0, 0.9, 0.8),'#10+
    '    m);';

const
  // The part calculating the color for the blue/red circles shader
  FS_BR_CIRCLES =
    '  vec2 center = vertTexCoord - vec2(0.5, 0.5);'#10+
    '  float m = floor(mod(sqrt(length(center)) * 16.0, 2.0));'#10+
    '  vec3 Color = mix('#10+
    '    vec3(1.0, 0.0, 0.0),'#10+
    '    vec3(0.0, 0.0, 1.0),'#10+
    '    m);';

const
  // The part calculating the color for the white/green spiral shader
  FS_WG_SPIRALS =
    '  vec2  center = (vertTexCoord - vec2(0.5, 0.5)) * 16.0;'#10+
    '  float l = length(center);'#10+
    '  float t = atan(center.y, center.x) / (2.0 * asin(1.0));'#10+
    '  float m = floor(mod(l + t, 2.0));'#10+
    '  vec3 Color = mix('#10+
    '    vec3(0.0, 1.0, 0.0),'#10+
    '    vec3(1.0, 1.0, 1.0),'#10+
    '    m);';

{ TShadedObjectsApp }

class function TShadedObjectsApp.CreateFragmentShader(
  const ASource: RawByteString): TGLShader;
begin
  Result.New(TGLShaderType.Fragment);
  Result.SetSource(FS_PROLOGUE + ASource + FS_EPILOGUE);
  Result.Compile;
end;

procedure TShadedObjectsApp.Initialize;
var
  VertexShader: TGLShader;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec3 Normal;'#10+
    'attribute vec2 TexCoord;'#10+

    'varying vec2 vertTexCoord;'#10+
    'varying vec3 vertNormal;'#10+
    'varying vec3 vertLight;'#10+

    'uniform vec3 LightPos;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vertTexCoord = TexCoord;'#10+
    '  gl_Position = ModelMatrix * vec4(Position, 1.0);'#10+
    '  vertNormal = mat3(ModelMatrix) * Normal;'#10+
    '  vertLight = LightPos - gl_Position.xyz;'#10+
    '  gl_Position = ProjectionMatrix * CameraMatrix * gl_Position;'#10+
    '}');
  VertexShader.Compile;

  FSphere := TSphere.Create(VertexShader, CreateFragmentShader(FS_YB_STRIPS));
  FCubeX := TCube.Create(VertexShader, CreateFragmentShader(FS_BW_CHECKER));
  FCubeY := TCube.Create(VertexShader, CreateFragmentShader(FS_BR_CIRCLES));
  FCubeZ := TCube.Create(VertexShader, CreateFragmentShader(FS_WG_SPIRALS));
  FTorus := TTorus.Create(VertexShader, CreateFragmentShader(FS_WO_VSTRIPS));

  { Vertex shader no longer needed }
  VertexShader.Delete;

  gl.ClearColor(0.5, 0.5, 0.5, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
end;

procedure TShadedObjectsApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TShadedObjectsApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  Light: TVector3;
  Camera, Model, Rotate, M1, M2: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  Light.Init(2, 2, 2);

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 6.0, Radians(ATotalTimeSec * 15),
    Radians(FastSin(Pi * ATotalTimeSec / 3) * 45), Camera);

  { Render the shapes }
  Model.Init;
  FSphere.Render(Light, Camera, Model);

  Model.InitTranslation(2, 0, 0);
  Rotate.InitRotationX(Radians(ATotalTimeSec * 45));
  FCubeX.Render(Light, Camera, Model * Rotate);

  Model.InitTranslation(0, 2, 0);
  Rotate.InitRotationY(Radians(ATotalTimeSec * 90));
  FCubeY.Render(Light, Camera, Model * Rotate);

  Model.InitTranslation(0, 0, 2);
  Rotate.InitRotationZ(Radians(ATotalTimeSec * 135));
  FCubeZ.Render(Light, Camera, Model * Rotate);

  Model.InitTranslation(-1, -1, -1);
  Rotate.InitRotation(Vector3(1, 1, 1), Radians(ATotalTimeSec * 45));
  M1.InitRotationY(Radians(45));
  M2.InitRotationX(Radians(45));
  FTorus.Render(Light, Camera, Model * Rotate * M1 * M2);
end;

procedure TShadedObjectsApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(60), AWidth / AHeight, 1, 50);
  FSphere.SetProjection(ProjectionMatrix);
  FCubeX.SetProjection(ProjectionMatrix);
  FCubeY.SetProjection(ProjectionMatrix);
  FCubeZ.SetProjection(ProjectionMatrix);
  FTorus.SetProjection(ProjectionMatrix);
end;

procedure TShadedObjectsApp.Shutdown;
begin
  { Release resources }
  FSphere.Free;
  FCubeX.Free;
  FCubeY.Free;
  FCubeZ.Free;
  FTorus.Free;
end;

{ TShape }

constructor TShape.Create(const AVertexShader, AFragmentShader: TGLShader;
  const AVerts, ANormals: TArray<TVector3>; const ATexCoords: TArray<TVector2>;
  const AIndices: TArray<UInt16>);
begin
  inherited Create;
  FProgram.New(AVertexShader, AFragmentShader);
  FProgram.Link;
  FProgram.Use;

  { Fragment shader no longer needed. Vertex shader is shared though. }
  AFragmentShader.Delete;

  { Positions }
  FVerts.New(TGLBufferType.Vertex);
  FVerts.Bind;
  FVerts.Data<TVector3>(AVerts);

  FAttrVerts.Init(FProgram, 'Position');

  { Normals }
  FNormals.New(TGLBufferType.Vertex);
  FNormals.Bind;
  FNormals.Data<TVector3>(ANormals);

  FAttrNormals.Init(FProgram, 'Normal');

  { Texture coordinates }
  FTexCoords.New(TGLBufferType.Vertex);
  FTexCoords.Bind;
  FTexCoords.Data<TVector2>(ATexCoords);

  FAttrTexCoords.Init(FProgram, 'TexCoord');

  { Indices }
  FIndices.New(TGLBufferType.Index);
  FIndices.Bind;
  FIndices.Data<UInt16>(AIndices);

  { Uniforms }
  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');
  FUniLightPos.Init(FProgram, 'LightPos');
end;

destructor TShape.Destroy;
begin
  FProgram.Delete;
  FVerts.Delete;
  FNormals.Delete;
  FTexCoords.Delete;
  FIndices.Delete;
  inherited;
end;

procedure TShape.Render(const ALight: TVector3; const ACamera,
  AModel: TMatrix4);
begin
  FProgram.Use;

  FUniLightPos.SetValue(ALight);
  FUniCameraMatrix.SetValue(ACamera);
  FUniModelMatrix.SetValue(AModel);

  FVerts.Bind;
  FAttrVerts.SetConfig(TGLDataType.Float, 3);
  FAttrVerts.Enable;

  FNormals.Bind;
  FAttrNormals.SetConfig(TGLDataType.Float, 3);
  FAttrNormals.Enable;

  FTexCoords.Bind;
  FAttrTexCoords.SetConfig(TGLDataType.Float, 2);
  FAttrTexCoords.Enable;

  FIndices.Bind;
end;

procedure TShape.SetProjection(const AProjection: TMatrix4);
begin
  FProgram.Use;
  FUniProjectionMatrix.SetValue(AProjection);
end;

{ TSphere }

constructor TSphere.Create(const AVertexShader, AFragmentShader: TGLShader);
begin
  FSphere.Generate;
  inherited Create(AVertexShader, AFragmentShader, FSphere.Positions,
    FSphere.Normals, FSphere.TexCoords, FSphere.Indices);
  FSphere.Clear;
end;

procedure TSphere.Render(const ALight: TVector3; const ACamera,
  AModel: TMatrix4);
begin
  inherited;
  FSphere.DrawWithBoundIndexBuffer;
end;

{ TCube }

constructor TCube.Create(const AVertexShader, AFragmentShader: TGLShader);
begin
  FCube.Generate;
  inherited Create(AVertexShader, AFragmentShader, FCube.Positions,
    FCube.Normals, FCube.TexCoords, FCube.Indices);
  FCube.Clear;
end;

procedure TCube.Render(const ALight: TVector3; const ACamera, AModel: TMatrix4);
begin
  inherited;
  FCube.DrawWithBoundIndexBuffer;
end;

{ TTorus }

constructor TTorus.Create(const AVertexShader, AFragmentShader: TGLShader);
begin
  FTorus.Generate;
  inherited Create(AVertexShader, AFragmentShader, FTorus.Positions,
    FTorus.Normals, FTorus.TexCoords, FTorus.Indices);
  FTorus.Clear;
end;

procedure TTorus.Render(const ALight: TVector3; const ACamera,
  AModel: TMatrix4);
begin
  inherited;
  FTorus.DrawWithBoundIndexBuffer;
end;

end.
