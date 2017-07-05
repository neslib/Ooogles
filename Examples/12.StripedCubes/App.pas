unit App;

{ Based on 013_striped_cubes.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.Geometry,
  Sample.App;

type
  TStripedCubesApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FTexCoords: TGLBuffer;
    FIndices: TGLBuffer;
    FCube: TCubeGeometry;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
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

{ TStripedCubesApp }

procedure TStripedCubesApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+

    'attribute vec3 Position;'#10+
    'attribute vec2 TexCoord;'#10+

    'varying vec2 vertTexCoord;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vertTexCoord = TexCoord;'#10+
    '  gl_Position = '#10+
    '    ProjectionMatrix *'#10+
    '    CameraMatrix *'#10+
    '    ModelMatrix *'#10+
    '    vec4(Position, 1.0);'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'varying vec2 vertTexCoord;'#10+

    'void main(void)'#10+
    '{'#10+
    '  float i = floor(mod((vertTexCoord.x + vertTexCoord.y) * 8.0, 2.0));'#10+
    '  gl_FragColor = mix('#10+
    '    vec4(0, 0, 0, 1),'#10+
    '    vec4(1, 1, 0, 1),'#10+
    '    i'#10+
    '  );'#10+
    '}');
  FragmentShader.Compile;

  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  VertexShader.Delete;
  FragmentShader.Delete;

  FProgram.Use;

  FCube.Generate(0.5);

  { Positions }
  FVerts.New(TGLBufferType.Vertex);
  FVerts.Bind;
  FVerts.Data<TVector3>(FCube.Positions);

  VertAttr.Init(FProgram, 'Position');
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

  { Uniforms }
  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');

  gl.ClearColor(0.8, 0.8, 0.7, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
end;

procedure TStripedCubesApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TStripedCubesApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  Translation, Rotation, CameraMatrix, ModelMatrix: TMatrix4;
begin
  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  { Use the program }
  FProgram.Use;

  { Orbit camera around cubes }
  OrbitCameraMatrix(TVector3.Zero, 3.5, Radians(ATotalTimeSec * 15),
    Radians(FastSin(ATotalTimeSec) * 45), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Update and render first cube }
  Translation.InitTranslation(-1, 0, 0);
  Rotation.InitRotationZ(Radians(ATotalTimeSec * 180));
  ModelMatrix := Translation * Rotation;
  FUniModelMatrix.SetValue(ModelMatrix);
  FCube.DrawWithBoundIndexBuffer;

  { Update and render second cube }
  Translation.InitTranslation(1, 0, 0);
  Rotation.InitRotationY(Radians(ATotalTimeSec * 90));
  ModelMatrix := Translation * Rotation;
  FUniModelMatrix.SetValue(ModelMatrix);
  FCube.DrawWithBoundIndexBuffer;
end;

procedure TStripedCubesApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(60), AWidth / AHeight, 1, 30);
  FProgram.Use;
  FUniProjectionMatrix.SetValue(ProjectionMatrix);
end;

procedure TStripedCubesApp.Shutdown;
begin
  { Release resources }
  FIndices.Delete;
  FTexCoords.Delete;
  FVerts.Delete;
  FProgram.Delete;
end;

end.
