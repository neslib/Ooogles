unit App;

{ Based on 020_cube_mapping.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TCubeMappingApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FNormals: TGLBuffer;
    FTexture: TGLTexture;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
    FShape: TSpiralSphereGeometry;
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
  Sample.Math,
  Sample.Assets,
  Sample.Targa;

{ TCubeMappingApp }

procedure TCubeMappingApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
  Image: TTgaImage;
  I: Integer;
begin
  TAssets.Initialize;

  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec3 Normal;'#10+
    'attribute vec2 TexCoord;'#10+

    'varying vec3 vertNormal;'#10+
    'varying vec3 vertLightDir;'#10+
    'varying vec3 vertLightRefl;'#10+
    'varying vec3 vertViewDir;'#10+
    'varying vec3 vertViewRefl;'#10+

    'uniform vec3 LightPos;'#10+

    'void main(void)'#10+
    '{'#10+
    '  gl_Position = ModelMatrix * vec4(Position, 1.0);'#10+
    '  vertNormal = mat3(ModelMatrix) * Normal;'#10+
    '  vertLightDir = LightPos - gl_Position.xyz;'#10+

    '  vertLightRefl = reflect('#10+
    '    -normalize(vertLightDir),'#10+
    '    normalize(vertNormal));'#10+

    '  vertViewDir = ('#10+
    '    vec4(0.0, 0.0, 1.0, 1.0)*'#10+
    '    CameraMatrix).xyz;'#10+

    '  vertViewRefl = reflect('#10+
    '    normalize(vertViewDir),'#10+
    '    normalize(vertNormal));'#10+

    '  gl_Position = ProjectionMatrix * CameraMatrix * gl_Position;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'uniform samplerCube TexUnit;'#10+

    'varying vec3 vertNormal;'#10+
    'varying vec3 vertLightDir;'#10+
    'varying vec3 vertLightRefl;'#10+
    'varying vec3 vertViewDir;'#10+
    'varying vec3 vertViewRefl;'#10+

    'void main(void)'#10+
    '{'#10+
    '  float l = length(vertLightDir);'#10+

    '  float d = dot('#10+
    '    normalize(vertNormal), '#10+
    '    normalize(vertLightDir)) / l;'#10+

    '  float s = dot('#10+
    '    normalize(vertLightRefl),'#10+
    '    normalize(vertViewDir));'#10+

    '  vec3 lt = vec3(1.0, 1.0, 1.0);'#10+
    '  vec3 env = textureCube(TexUnit, vertViewRefl).rgb;'#10+

    '  gl_FragColor = vec4('#10+
    '    env * 0.4 + '#10+
    '    (lt + env) * 1.5 * max(d, 0.0) + '#10+
    '    lt * pow(max(s, 0.0), 64.0), '#10+
    '    1.0);'#10+
    '}');
  FragmentShader.Compile;

  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  VertexShader.Delete;
  FragmentShader.Delete;

  FProgram.Use;

  FShape.Generate;

  { Positions }
  FVerts.New(TGLBufferType.Vertex);
  FVerts.Bind;
  FVerts.Data<TVector3>(FShape.Positions);

  VertAttr.Init(FProgram, 'Position');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Normals }
  FNormals.New(TGLBufferType.Vertex);
  FNormals.Bind;
  FNormals.Data<TVector3>(FShape.Normals);

  VertAttr.Init(FProgram, 'Normal');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Don't need data anymore }
  FShape.Clear;

  { Setup the texture }
  Image.Load('Newton.tga');
  FTexture.New(TGLTextureType.CubeMap);
  FTexture.Bind;
  FTexture.MinFilter(TGLMinFilter.Linear);
  FTexture.MagFilter(TGLMagFilter.Linear);
  FTexture.WrapS(TGLWrapMode.ClampToEdge);
  FTexture.WrapT(TGLWrapMode.ClampToEdge);
  for I := 0 to 5 do
    FTexture.Upload(TGLPixelFormat.RGBA, Image.Width, Image.Height,
      @Image.Data[0], 0, TGLPixelDataType.UnsignedByte, I);

  { Uniforms }
  Uniform.Init(FProgram, 'TexUnit');
  Uniform.SetValue(0);

  Uniform.Init(FProgram, 'LightPos');
  Uniform.SetValue(3.0, 5.0, 4.0);

  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');

  gl.ClearColor(0.2, 0.05, 0.1, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
  gl.Enable(TGLCapability.CullFace);
  gl.FrontFace(TGLFaceOrientation.CounterClockwise);
  gl.CullFace(TGLFace.Back);
end;

procedure TCubeMappingApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TCubeMappingApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  CameraMatrix, ModelMatrix: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  { Use the program }
  FProgram.Use;

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 4.5 - Sin(ATotalTimeSec * Pi / 8) * 2,
    ATotalTimeSec * Pi / 6,
    Radians(Sin(Pi * ATotalTimeSec / 15) * 90), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Update and render the sphere }
  ModelMatrix.InitRotation(Vector3(1, 1, 1), ATotalTimeSec * Pi / 5);
  FUniModelMatrix.SetValue(ModelMatrix);

  FShape.Draw;
end;

procedure TCubeMappingApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(60), AWidth / AHeight, 1, 100);
  FProgram.Use;
  FUniProjectionMatrix.SetValue(ProjectionMatrix);
end;

procedure TCubeMappingApp.Shutdown;
begin
  { Release resources }
  FTexture.Delete;
  FNormals.Delete;
  FVerts.Delete;
  FProgram.Delete;
end;

end.
