unit App;

{ Based on Hello_Triangle.c from
  Book:      OpenGL(R) ES 2.0 Programming Guide
  Authors:   Aaftab Munshi, Dan Ginsburg, Dave Shreiner
  ISBN-10:   0321502795
  ISBN-13:   9780321502797
  Publisher: Addison-Wesley Professional
  URLs:      http://safari.informit.com/9780321563835
             http://www.opengles-book.com }

{$INCLUDE 'Sample.inc'}

interface

uses
  System.Classes,
  Neslib.Ooogles,
  Neslib.FastMath,
  Sample.App;

type
  TTriangleApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FAttrPosition: TGLVertexAttrib;
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

{ TTriangleApp }

procedure TTriangleApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
begin
  { Compile vertex and fragment shaders }
  VertexShader.New(TGLShaderType.Vertex,
    'attribute vec4 vPosition;'#10+

    'void main(void)'#10+
    '{'#10+
    '  gl_Position = vPosition;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'void main(void)'#10+
    '{'#10+
    '  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);'#10+
    '}');
  FragmentShader.Compile;

  { Link shaders into program }
  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  { We don't need the shaders anymore. Note that the shaders won't actually be
    deleted until the program is deleted. }
  VertexShader.Delete;
  FragmentShader.Delete;

  { Initialize vertex attribute }
  FAttrPosition.Init(FProgram, 'vPosition');

  { Set clear color to black }
  gl.ClearColor(0, 0, 0, 0);
end;

procedure TTriangleApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TTriangleApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
const
  VERTICES: array [0..2] of TVector3 = (
    (X:  0.0; Y:  0.5; Z: 0.0),
    (X: -0.5; Y: -0.5; Z: 0.0),
    (X:  0.5; Y: -0.5; Z: 0.0));
begin
  { Clear the color buffer }
  gl.Clear([TGLClear.Color]);

  { Use the program }
  FProgram.Use;

  { Set the data for the vertex attribute }
  FAttrPosition.SetData(VERTICES);
  FAttrPosition.Enable;

  { Draw the triangle }
  gl.DrawArrays(TGLPrimitiveType.Triangles, 3);
end;

procedure TTriangleApp.Shutdown;
begin
  { Release resources }
  FProgram.Delete;
end;

end.
