unit App;

{ Based on 022_parallax_map.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TParallaxMapApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FNormals: TGLBuffer;
    FTangents: TGLBuffer;
    FTexCoords: TGLBuffer;
    FIndices: TGLBuffer;
    FTexture: TGLTexture;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
    FUniLightPos: TGLUniform;
    FCube: TCubeGeometry;
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
  Sample.Texture;

{ TParallaxMapApp }

procedure TParallaxMapApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
begin
  TAssets.Initialize;

  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+
    'uniform vec3 LightPos;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec3 Normal;'#10+
    'attribute vec3 Tangent;'#10+
    'attribute vec2 TexCoord;'#10+

    'varying vec3 vertEye;'#10+
    'varying vec3 vertLight;'#10+
    'varying vec3 vertNormal;'#10+
    'varying vec2 vertTexCoord;'#10+
    'varying vec3 vertViewTangent;'#10+
    'varying mat3 NormalMatrix;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vec4 EyePos = '#10+
    '    CameraMatrix *'#10+
    '    ModelMatrix *'#10+
    '    vec4(Position, 1.0);'#10+

    '  vertEye = EyePos.xyz;'#10+

    '  vec3 fragTangent = ('#10+
    '    CameraMatrix *'#10+
    '    ModelMatrix *'#10+
    '    vec4(Tangent, 0.0)).xyz;'#10+

    '  vertNormal = ('#10+
    '    CameraMatrix *'#10+
    '    ModelMatrix *'#10+
    '    vec4(Normal, 0.0)).xyz;'#10+

    '  vertLight = ('#10+
    '    CameraMatrix *'#10+
    '    vec4(LightPos - vertEye, 1.0)).xyz;'#10+

    '  NormalMatrix = mat3('#10+
    '    fragTangent,'#10+
    '    cross(vertNormal, fragTangent),'#10+
    '    vertNormal);'#10+

    '  vertViewTangent = vec3('#10+
    '    dot(NormalMatrix[0], vertEye),'#10+
    '    dot(NormalMatrix[1], vertEye),'#10+
    '    dot(NormalMatrix[2], vertEye));'#10+

    '  vertTexCoord = TexCoord;'#10+

    '  gl_Position = ProjectionMatrix * EyePos;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'uniform sampler2D BumpTex;'#10+
    'uniform int BumpTexWidth;'#10+
    'uniform int BumpTexHeight;'#10+

    'float DepthMult = 0.1;'#10+

    'varying vec3 vertEye;'#10+
    'varying vec3 vertLight;'#10+
    'varying vec3 vertNormal;'#10+
    'varying vec2 vertTexCoord;'#10+
    'varying vec3 vertViewTangent;'#10+
    'varying mat3 NormalMatrix;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vec3 ViewTangent = normalize(vertViewTangent);'#10+
    '  float perp = -dot(normalize(vertEye), vertNormal);'#10+

    '  float sampleInterval = 1.0 / length('#10+
    '    vec2(BumpTexWidth, BumpTexHeight));'#10+

    '  vec3 sampleStep = ViewTangent * sampleInterval;'#10+
    '  float prevD = 0.0;'#10+
    '  float depth = texture2D(BumpTex, vertTexCoord).w;'#10+
    '  float maxOffs = min((depth * DepthMult) / -ViewTangent.z, 1.0);'#10+

    '  vec3 viewOffs = vec3(0.0, 0.0, 0.0);'#10+
    '  vec2 offsTexC = vertTexCoord + viewOffs.xy;'#10+

    '  while (length(viewOffs) < maxOffs)'#10+
    '  {'#10+
    '    if ((offsTexC.x <= 0.0) || (offsTexC.x >= 1.0))'#10+
    '      break;'#10+

    '    if ((offsTexC.y <= 0.0) || (offsTexC.y >= 1.0))'#10+
    '      break;'#10+

    '    if ((depth * DepthMult * perp) <= -viewOffs.z)'#10+
    '      break;'#10+

    '    viewOffs += sampleStep;'#10+
    '    offsTexC = vertTexCoord + viewOffs.xy;'#10+
    '    prevD = depth;'#10+
    '    depth = texture2D(BumpTex, offsTexC).w;'#10+
    '  }'#10+

    '  offsTexC = vec2('#10+
    '    clamp(offsTexC.x, 0.0, 1.0),'#10+
    '    clamp(offsTexC.y, 0.0, 1.0));'#10+

    '  float b = floor(mod('#10+
    '    1.0 +'#10+
    '    floor(mod(offsTexC.x * 16.0, 2.0))+'#10+
    '    floor(mod(offsTexC.y * 16.0, 2.0)), 2.0));'#10+

    '  vec3 c = vec3(b, b, b);'#10+
    '  vec3 n = texture2D(BumpTex, offsTexC).xyz;'#10+
    '  vec3 finalNormal = NormalMatrix * n;'#10+
    '  float l = length(vertLight);'#10+

    '  float d = (l > 0.0) ? dot('#10+
    '    normalize(vertLight), '#10+
    '    finalNormal) / l : 0.0;'#10+

    '  float i = 0.1 + 2.5 * max(d, 0.0);'#10+
    '  gl_FragColor = vec4(c * i, 1.0);'#10+
    '}');
  FragmentShader.Compile;

  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  VertexShader.Delete;
  FragmentShader.Delete;

  FProgram.Use;

  FCube.Generate;

  { Positions }
  FVerts.New(TGLBufferType.Vertex);
  FVerts.Bind;
  FVerts.Data<TVector3>(FCube.Positions);

  VertAttr.Init(FProgram, 'Position');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Normals }
  FNormals.New(TGLBufferType.Vertex);
  FNormals.Bind;
  FNormals.Data<TVector3>(FCube.Normals);

  VertAttr.Init(FProgram, 'Normal');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Tangents }
  FTangents.New(TGLBufferType.Vertex);
  FTangents.Bind;
  FTangents.Data<TVector3>(FCube.Tangents);

  VertAttr.Init(FProgram, 'Tangent');
  VertAttr.SetConfig<TVector3>;
  VertAttr.Enable;

  { Texture coordinates }
  FTexCoords.New(TGLBufferType.Vertex);
  FTexCoords.Bind;
  FTexCoords.Data<TVector2>(FCube.TexCoords);

  VertAttr.Init(FProgram, 'TexCoord');
  VertAttr.SetConfig<TVector2>;
  VertAttr.Enable;

  { Indices }
  FIndices.New(TGLBufferType.Index);
  FIndices.Bind;
  FIndices.Data<UInt16>(FCube.Indices);

  { Don't need data anymore }
  FCube.Clear;

  { Texture }
  FTexture := LoadTexture('texture.tga');
  FTexture.WrapS(TGLWrapMode.NormalRepeat);
  FTexture.WrapT(TGLWrapMode.NormalRepeat);

  { Uniforms }
  Uniform.Init(FProgram, 'BumpTexWidth');
  Uniform.SetValue(512);

  Uniform.Init(FProgram, 'BumpTexHeight');
  Uniform.SetValue(512);

  Uniform.Init(FProgram, 'BumpTex');
  Uniform.SetValue(0);

  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');
  FUniLightPos.Init(FProgram, 'LightPos');

  gl.ClearColor(0.1, 0.1, 0.1, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
  gl.Enable(TGLCapability.CullFace);
  gl.FrontFace(TGLFaceOrientation.CounterClockwise);
end;

procedure TParallaxMapApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TParallaxMapApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  LightAzimuth, S, C: Single;
  CameraMatrix, ModelMatrix: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  { Use the program }
  FProgram.Use;

  { Set light position }
  LightAzimuth := -Pi * ATotalTimeSec;
  FastSinCos(LightAzimuth, S, C);
  FUniLightPos.SetValue(-C * 2, 2, -S * 2);

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 3.0, Radians(-45),
    Radians(FastSin(Pi * ATotalTimeSec / 15) * 70), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Update and render the cube }
  ModelMatrix.InitRotation(Vector3(1, 1, 1), -Pi * ATotalTimeSec * 0.025);
  FUniModelMatrix.SetValue(ModelMatrix);
  gl.CullFace(TGLFace.Back);
  FCube.DrawWithBoundIndexBuffer;
end;

procedure TParallaxMapApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(54), AWidth / AHeight, 1, 10);
  FProgram.Use;
  FUniProjectionMatrix.SetValue(ProjectionMatrix);
end;

procedure TParallaxMapApp.Shutdown;
begin
  { Release resources }
  FIndices.Delete;
  FTexCoords.Delete;
  FTangents.Delete;
  FNormals.Delete;
  FVerts.Delete;
  FProgram.Delete;
  FTexture.Delete;
end;

end.
