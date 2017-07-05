unit App;

{ Based on 021_morphing.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App,
  Sample.Geometry;

type
  TMorphingApp = class(TApplication)
  private const
    POINT_COUNT = 4096;
  private
    FProgram: TGLProgram;
    FVBOs: array [0..3] of TGLBuffer;
    FUniProjectionMatrix: TGLUniform;
    FUniCameraMatrix: TGLUniform;
    FUniModelMatrix: TGLUniform;
    FUniStatus: TGLUniform;
    FStatus: Single;
  private
    function MakeShape1: TGLBuffer;
    function MakeShape2: TGLBuffer;
    function MakeRadiance(const AAttrName: RawByteString): TGLBuffer;
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
  Sample.Platform;

{ TMorphingApp }

procedure TMorphingApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  Uniform: TGLUniform;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 ProjectionMatrix, CameraMatrix, ModelMatrix;'#10+
    'uniform vec3 Color1, Color2;'#10+
    'uniform float Status, ScreenScale;'#10+

    'attribute vec4 Position1, Position2;'#10+
    'attribute float Radiance1, Radiance2;'#10+

    'varying vec3 vertColor;'#10+

    'void main(void)'#10+
    '{'#10+
    '  gl_Position = '#10+
    '    ProjectionMatrix * '#10+
    '    CameraMatrix * '#10+
    '    ModelMatrix * '#10+
    '    mix(Position1, Position2, Status);'#10+

    '  gl_PointSize = (2.0 + 3.0 * mix('#10+
    '    Radiance1, '#10+
    '    Radiance2, '#10+
    '    Status)) * ScreenScale;'#10+

    '  vertColor = mix('#10+
    '    (0.2 + Radiance1) * Color1,'#10+
    '    (0.2 + Radiance2) * Color2,'#10+
    '    Status);'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'varying vec3 vertColor;'#10+

    'void main(void)'#10+
    '{'#10+
    '  gl_FragColor = vec4(vertColor, 1.0);'#10+
    '}');
  FragmentShader.Compile;

  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  VertexShader.Delete;
  FragmentShader.Delete;

  FProgram.Use;

  FVBOs[0] := MakeShape1;
  FVBOs[1] := MakeShape2;
  FVBOs[2] := MakeRadiance('Radiance1');
  FVBOs[3] := MakeRadiance('Radiance2');

  { Uniforms }
  Uniform.Init(FProgram, 'Color1');
  Uniform.SetValue(1.0, 0.5, 0.4);

  Uniform.Init(FProgram, 'Color2');
  Uniform.SetValue(1.0, 0.8, 0.7);

  { The gl_PointSize vertex shader output does not take screen scale into
    account. So we scale it ourselves. }
  Uniform.Init(FProgram, 'ScreenScale');
  Uniform.SetValue(TPlatform.ScreenScale);

  FUniProjectionMatrix.Init(FProgram, 'ProjectionMatrix');
  FUniCameraMatrix.Init(FProgram, 'CameraMatrix');
  FUniModelMatrix.Init(FProgram, 'ModelMatrix');
  FUniStatus.Init(FProgram, 'Status');

  gl.ClearColor(0.2, 0.2, 0.2, 0);
  gl.ClearDepth(1);
  gl.Enable(TGLCapability.DepthTest);
  gl.Enable(TGLCapability.Blend);
end;

procedure TMorphingApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

function TMorphingApp.MakeRadiance(const AAttrName: RawByteString): TGLBuffer;
var
  Data: TArray<Single>;
  I: Integer;
  Attr: TGLVertexAttrib;
begin
  SetLength(Data, POINT_COUNT);
  for I := 0 to POINT_COUNT- 1 do
    Data[I] := Random(101) * 0.01;

  Result.New(TGLBufferType.Vertex);
  Result.Bind;
  Result.Data(Data);

  Attr.Init(FProgram, AAttrName);
  Attr.SetConfig<Single>;
  Attr.Enable;
end;

function TMorphingApp.MakeShape1: TGLBuffer;
var
  Data: TArray<TVector3>;
  I: Integer;
  Phi, Rho, SPhi, CPhi, SRho, CRho: Single;
  Attr: TGLVertexAttrib;
begin
  SetLength(Data, POINT_COUNT);
  for I := 0 to POINT_COUNT - 1 do
  begin
    Phi := 2 * Pi * (Random(1001) * 0.001);
    Rho := 0.5 * Pi * ((Random(1001) * 0.002) - 1.0);

    FastSinCos(Phi, SPhi, CPhi);
    FastSinCos(Rho, SRho, CRho);

    Data[I].Init(CPhi * CRho, SRho, SPhi * CRho);
  end;

  Result.New(TGLBufferType.Vertex);
  Result.Bind;
  Result.Data(Data);

  Attr.Init(FProgram, 'Position1');
  Attr.SetConfig<TVector3>;
  Attr.Enable;
end;

function TMorphingApp.MakeShape2: TGLBuffer;
var
  Data: TArray<TVector3>;
  I: Integer;
  Phi, Rho, SPhi, CPhi, SRho, CRho: Single;
  Attr: TGLVertexAttrib;
begin
  SetLength(Data, POINT_COUNT);
  for I := 0 to POINT_COUNT - 1 do
  begin
    Phi := 2 * Pi * (Random(1001) * 0.001);
    Rho := 2 * Pi * (Random(1001) * 0.001);

    FastSinCos(Phi, SPhi, CPhi);
    FastSinCos(Rho, SRho, CRho);

    Data[I].Init(
      CPhi * (0.5 + (0.5 * (1.0 + CRho))),
      SRho * 0.5,
      SPhi * (0.5 + (0.5 * (1.0 + CRho))));
  end;

  Result.New(TGLBufferType.Vertex);
  Result.Bind;
  Result.Data(Data);

  Attr.Init(FProgram, 'Position2');
  Attr.SetConfig<TVector3>;
  Attr.Enable;
end;

procedure TMorphingApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  CameraMatrix, ModelMatrix: TMatrix4;
begin
  if ((Trunc(ATotalTimeSec) and 3) = 0) then
    FStatus := FStatus + ADeltaTimeSec
  else if (FStatus <> Trunc(FStatus)) then
  begin
    if (Frac(FStatus) < 0.5) then
      FStatus := Trunc(FStatus)
    else
      FStatus := 1 + Trunc(FStatus);
  end;

  { Clear the color and depth buffer }
  gl.Clear([TGLClear.Color, TGLClear.Depth]);

  { Use the program }
  FProgram.Use;

  FUniStatus.SetValue(0.5 - (0.5 * FastCos(Pi * FStatus)));

  { Set the matrix for camera orbiting the origin }
  OrbitCameraMatrix(TVector3.Zero, 5.5, ATotalTimeSec * Pi / 9.5,
    Radians(45 + FastSin(Pi * ATotalTimeSec / 7.5) * 40), CameraMatrix);
  FUniCameraMatrix.SetValue(CameraMatrix);

  { Render }
  ModelMatrix.InitRotationX(FStatus * Pi * 0.5);
  FUniModelMatrix.SetValue(ModelMatrix);
  gl.DrawArrays(TGLPrimitiveType.Points, POINT_COUNT);
end;

procedure TMorphingApp.Resize(const AWidth, AHeight: Integer);
var
  ProjectionMatrix: TMatrix4;
begin
  inherited;
  ProjectionMatrix.InitPerspectiveFovRH(Radians(48), AWidth / AHeight, 1, 20);
  FProgram.Use;
  FUniProjectionMatrix.SetValue(ProjectionMatrix);
end;

procedure TMorphingApp.Shutdown;
var
  I: Integer;
begin
  { Release resources }
  for I := 0 to Length(FVBOs) - 1 do
    FVBOs[I].Delete;
  FProgram.Delete;
end;

end.
