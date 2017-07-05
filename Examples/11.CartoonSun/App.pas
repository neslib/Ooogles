unit App;

{ Based on 006_cartoon_sun.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App;

type
  TCartoonSunApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FUniTime: TGLUniform;
    FUniSunPos: TGLUniform;
  public
    procedure Initialize; override;
    procedure Render(const ADeltaTimeSec, ATotalTimeSec: Double); override;
    procedure Shutdown; override;
    procedure KeyDown(const AKey: Integer; const AShift: TShiftState); override;
  end;

implementation

uses
  {$INCLUDE 'OpenGL.inc'}
  System.UITypes;

{ TCartoonSunApp }

procedure TCartoonSunApp.Initialize;
const
  RECTANGLE_VERTS: array [0..3] of TVector2 = (
    (X: -1; Y: -1),
    (X: -1; Y:  1),
    (X:  1; Y: -1),
    (X:  1; Y:  1));
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'attribute vec2 Position;'#10+

    'varying vec2 vertPos;'#10+

    'void main(void)'#10+
    '{'#10+
    '  gl_Position = vec4(Position, 0.0, 1.0);'#10+
    '  vertPos = gl_Position.xy;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'uniform float Time;'#10+

    'uniform vec2 SunPos;'#10+
    'uniform vec3 Sun1, Sun2, Sky1, Sky2;'#10+

    'varying vec2 vertPos;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vec2 v = vertPos - SunPos;'#10+
    '  float l = length(v);'#10+
    '  float a = (sin(l) + atan(v.y, v.x)) / 3.1415;'#10+
    '  if (l < 0.1)'#10+
    '  {'#10+
    '    gl_FragColor = vec4(Sun1, 1.0);'#10+
    '  }'#10+
    '  else if (floor(mod(18.0 * (Time * 0.1 + 1.0 + a), 2.0)) == 0.0)'#10+
    '  {'#10+
    '    gl_FragColor = vec4(mix(Sun1, Sun2, l), 1.0);'#10+
    '  }'#10+
    '  else'#10+
    '  {'#10+
    '    gl_FragColor = vec4(mix(Sky1, Sky2, l), 1.0);'#10+
    '  }'#10+
    '}');
  FragmentShader.Compile;

  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  VertexShader.Delete;
  FragmentShader.Delete;

  FProgram.Use;

  { Positions }
  FVerts.New(TGLBufferType.Vertex);
  FVerts.Bind;
  FVerts.Data(RECTANGLE_VERTS);

  VertAttr.Init(FProgram, 'Position');
  VertAttr.SetConfig<TVector2>;
  VertAttr.Enable;

  { Uniforms }
  FUniTime.Init(FProgram, 'Time');
  FUniSunPos.Init(FProgram, 'SunPos');

  Uniform.Init(FProgram, 'Sun1');
  Uniform.SetValue(Vector3(0.95, 0.85, 0.60));

  Uniform.Init(FProgram, 'Sun2');
  Uniform.SetValue(Vector3(0.90, 0.80, 0.20));

  Uniform.Init(FProgram, 'Sky1');
  Uniform.SetValue(Vector3(0.90, 0.80, 0.50));

  Uniform.Init(FProgram, 'Sky2');
  Uniform.SetValue(Vector3(0.80, 0.60, 0.40));

  gl.Disable(TGLCapability.DepthTest);
end;

procedure TCartoonSunApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TCartoonSunApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  Angle, S, C: Single;
begin
  { Clear the color buffer }
  gl.Clear([TGLClear.Color]);

  { Use the program }
  FProgram.Use;

  { Update uniforms }
  FUniTime.SetValue(ATotalTimeSec);

  Angle := ATotalTimeSec * Pi * 0.1;
  FastSinCos(Angle, S, C);
  FUniSunPos.SetValue(-C, S);

  { Draw the rectangle }
  gl.DrawArrays(TGLPrimitiveType.TriangleStrip, 4);
end;

procedure TCartoonSunApp.Shutdown;
begin
  { Release resources }
  FVerts.Delete;
  FProgram.Delete;
end;

end.
