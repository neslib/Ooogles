unit App;

{ Based on 025_recursive_texture.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TRecursiveTextureApp = class(TApplication)
  private const
    TEXTURE_SIZE = 512;
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FNormals: TGLBuffer;
    FTexCoords: TGLBuffer;
    FIndices: TGLBuffer;
    FUniTexUnit: TGLUniform;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
    FDefaultFramebuffer: TGLFramebuffer;
    FFramebuffers: array [0..1] of TGLFramebuffer;
    FRenderbuffers: array [0..1] of TGLRenderbuffer;
    FTextures: array [0..1] of TGLTexture;
    FCurrentTextureIndex: Integer;
    FCube: TCubeGeometry;
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
  Sample.Math;

{ TRecursiveTextureApp }

procedure TRecursiveTextureApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
  I: Integer;
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
    '  vertNormal = mat3(ModelMatrix) * Normal;'#10+
    '  gl_Position = ModelMatrix * vec4(Position, 1.0);'#10+
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
    '  float d = (l > 0.0) ? dot(vertNormal, normalize(vertLight)) / l : 0.0;'#10+
    '  float i = 0.6 + max(d, 0.0);'#10+
    '  gl_FragColor = texture2D(TexUnit, vertTexCoord) * i;'#10+
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

  { Texture coordinates }
  FNormals.New(TGLBufferType.Vertex);
  FNormals.Bind;
  FNormals.Data<TVector2>(FCube.TexCoords);

  VertAttr.Init(FProgram, 'TexCoord');
  VertAttr.SetConfig<TVector2>;
  VertAttr.Enable;

  { Indices }
  FIndices.New(TGLBufferType.Index);
  FIndices.Bind;
  FIndices.Data<UInt16>(FCube.Indices);

  { Don't need data anymore }
  FCube.Clear;

  { Textures, renderbuffers and framebuffers }
  FDefaultFramebuffer := TGLFramebuffer.GetCurrent;
  for I := 0 to 1 do
  begin
    FTextures[I].New;
    FTextures[I].BindToTextureUnit(I);
    FTextures[I].MinFilter(TGLMinFilter.Linear);
    FTextures[I].MagFilter(TGLMagFilter.Linear);
    FTextures[I].WrapS(TGLWrapMode.NormalRepeat);
    FTextures[I].WrapT(TGLWrapMode.NormalRepeat);
    FTextures[I].Upload(TGLPixelFormat.RGBA, TEXTURE_SIZE, TEXTURE_SIZE, nil);

    FRenderbuffers[I].New;
    FRenderbuffers[I].Bind;
    FRenderbuffers[I].Storage(TEXTURE_SIZE, TEXTURE_SIZE,
      TGLRenderbufferFormat.Depth16);

    FFramebuffers[I].New;
    FFramebuffers[I].Bind;
    FFramebuffers[I].AttachTexture(TGLFramebufferAttachment.Color,
      FTextures[I]);
    FFramebuffers[I].AttachRenderbuffer(TGLFramebufferAttachment.Depth,
      FRenderbuffers[I]);

    Assert(FFramebuffers[I].Status = TGLFramebufferStatus.Complete);
  end;

  { Uniforms }
  Uniform.Init(FProgram, 'LightPos');
  Uniform.SetValue(4.0, 4.0, -8.0);

  FUniTexUnit.Init(FProgram, 'TexUnit');
  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');

  gl.ClearColor(1.0, 1.0, 1.0, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
  gl.Enable(TGLCapability.CullFace);
  gl.FrontFace(TGLFaceOrientation.CounterClockwise);
  gl.CullFace(TGLFace.Back);
end;

procedure TRecursiveTextureApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TRecursiveTextureApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  FrontIndex, BackIndex: Integer;
  CameraMatrix, ModelMatrix, ProjectionMatrix: TMatrix4;
  Time: Single;
begin
  FrontIndex := FCurrentTextureIndex;
  BackIndex := 1 - FCurrentTextureIndex;
  FCurrentTextureIndex := BackIndex;

  { Use the program }
  FProgram.Use;

  { Render into texture }
  FUniTexUnit.SetValue(FrontIndex);

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 3.0, Radians(ATotalTimeSec * 35),
    Radians(FastSin(Pi * ATotalTimeSec / 10) * 60), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Set model matrix }
  ModelMatrix.InitRotationX(Pi * ATotalTimeSec * 0.5);
  FUniModelMatrix.SetValue(ModelMatrix);

  { Set projection matrix }
  ProjectionMatrix.InitPerspectiveFovRH(Radians(40), 1, 1, 40);
  FUniProjectionMatrix.SetValue(ProjectionMatrix);

  { Render to framebuffer }
  FFramebuffers[BackIndex].Bind;
  gl.Viewport(TEXTURE_SIZE, TEXTURE_SIZE);
  gl.Clear([TGLClear.Color, TGLClear.Depth]);
  FCube.DrawWithBoundIndexBuffer;

  { Render textured cube to default framebuffer }
  FDefaultFramebuffer.Bind;
  gl.Viewport(Width, Height);
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  Time := ATotalTimeSec + 0.3;

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 3.0, Radians(Time * 35),
    Radians(FastSin(Pi * Time / 10) * 60), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Set projection matrix }
  ProjectionMatrix.InitPerspectiveFovRH(Radians(60), Width / Height, 1, 40);
  FUniProjectionMatrix.SetValue(ProjectionMatrix);

  { Render }
  FCube.DrawWithBoundIndexBuffer;
end;

procedure TRecursiveTextureApp.Shutdown;
var
  I: Integer;
begin
  { Release resources }
  for I := 0 to 1 do
  begin
    FFramebuffers[I].Delete;
    FRenderbuffers[I].Delete;
    FTextures[I].Delete;
  end;
  FIndices.Delete;
  FTexCoords.Delete;
  FNormals.Delete;
  FVerts.Delete;
  FProgram.Delete;
end;

end.
