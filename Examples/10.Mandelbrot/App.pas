unit App;

{ Based on 005_mandelbrot.cpp example from oglplus (http://oglplus.org/) }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App;

type
  TMandelbrotApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FVerts: TGLBuffer;
    FCoords: TGLBuffer;
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

{ TMandelbrotApp }

procedure TMandelbrotApp.Initialize;
const
  RECTANGLE_VERTS: array [0..3] of TVector2 = (
    (X: -1; Y: -1),
    (X: -1; Y:  1),
    (X:  1; Y: -1),
    (X:  1; Y:  1));
const
  RECTANGLE_COORDS: array [0..3] of TVector2 = (
    (X: -1.5; Y: -0.5),
    (X: -1.5; Y:  1.0),
    (X:  0.5; Y: -0.5),
    (X:  0.5; Y:  1.0));
const
  COLOR_MAP: array [0..4] of TVector4 = (
    (R: 0.4; G: 0.2; B: 1.0; A: 0.00),
    (R: 1.0; G: 0.2; B: 0.2; A: 0.30),
    (R: 1.0; G: 1.0; B: 1.0; A: 0.95),
    (R: 1.0; G: 1.0; B: 1.0; A: 0.98),
    (R: 0.1; G: 0.1; B: 0.1; A: 1.00));
var
  VertexShader, FragmentShader: TGLShader;
  VertAttr: TGLVertexAttrib;
  Uniform: TGLUniform;
begin
  VertexShader.New(TGLShaderType.Vertex,
    'attribute vec2 Position;'#10+
    'attribute vec2 Coord;'#10+

    'varying vec2 vertCoord;'#10+

    'void main(void)'#10+
    '{'#10+
    '  vertCoord = Coord;'#10+
    '  gl_Position = vec4(Position, 0.0, 1.0);'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision highp float;'#10+

    'varying vec2 vertCoord;'#10+

    'const int nclr = 5;'#10+

    'uniform vec4 clrs[5];'#10+

    'void main(void)'#10+
    '{'#10+
    '  vec2 z = vec2(0.0, 0.0);'#10+
    '  vec2 c = vertCoord;'#10+

    '  int i = 0, max = 128;'#10+
    '  while ((i != max) && (distance(z, c) < 2.0))'#10+
    '  {'#10+
    '    vec2 zn = vec2('#10+
    '      z.x * z.x - z.y * z.y + c.x,'#10+
    '      2.0 * z.x * z.y + c.y);'#10+
    '    z = zn;'#10+
    '    ++i;'#10+
    '  }'#10+

    '  float a = sqrt(float(i) / float(max));'#10+

    '  for (i = 0; i != (nclr - 1); ++i)'#10+
    '  {'#10+
    '    if((a > clrs[i].a) && (a <= clrs[i+1].a))'#10+
    '    {'#10+
    '      float m = (a - clrs[i].a) / (clrs[i+1].a - clrs[i].a);'#10+
    '      gl_FragColor = vec4('#10+
    '        mix(clrs[i].rgb, clrs[i+1].rgb, m),'#10+
    '        1.0'#10+
    '      );'#10+
    '      break;'#10+
    '    }'#10+
    '  }'#10+
    '}');
  FragmentShader.Compile;

  FProgram.New;
  FProgram.AttachShader(VertexShader);
  FProgram.AttachShader(FragmentShader);
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

  { Mandelbrot coordinates }
  FCoords.New(TGLBufferType.Vertex);
  FCoords.Bind;
  FCoords.Data(RECTANGLE_COORDS);

  VertAttr.Init(FProgram, 'Coord');
  VertAttr.SetConfig<TVector2>;
  VertAttr.Enable;

  { Color map }
  Uniform.Init(FProgram, 'clrs');
  Uniform.SetValues(COLOR_MAP);

  gl.Disable(TGLCapability.DepthTest);
end;

procedure TMandelbrotApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TMandelbrotApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
begin
  { Clear the color buffer }
  gl.Clear([TGLClear.Color]);

  { Use the program }
  FProgram.Use;

  { Draw the rectangle }
  gl.DrawArrays(TGLPrimitiveType.TriangleStrip, 4);
end;

procedure TMandelbrotApp.Shutdown;
begin
  { Release resources }
  FCoords.Delete;
  FVerts.Delete;
  FProgram.Delete;
end;

end.
