unit App;

{ Based on Stencil_Test.c from
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
  TStencilOpApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FAttrPosition: TGLVertexAttrib;
    FUniColor: TGLUniform;
  public
    function NeedStencilBuffer: Boolean; override;
    procedure Initialize; override;
    procedure Render(const ADeltaTimeSec, ATotalTimeSec: Double); override;
    procedure Shutdown; override;
    procedure KeyDown(const AKey: Integer; const AShift: TShiftState); override;
  end;

implementation

uses
  {$INCLUDE 'OpenGL.inc'}
  System.UITypes;

{ TStencilOpApp }

procedure TStencilOpApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
begin
  { Compile vertex and fragment shaders }
  VertexShader.New(TGLShaderType.Vertex,
    'attribute vec4 a_position;'#10+

    'void main()'#10+
    '{'#10+
    '  gl_Position = a_position;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'uniform vec4 u_color;'#10+

    'void main()'#10+
    '{'#10+
    '  gl_FragColor = u_color;'#10+
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
  FAttrPosition.Init(FProgram, 'a_position');

  { Initialize uniform }
  FUniColor.Init(FProgram, 'u_color');

  { Set clear color to black }
  gl.ClearColor(0, 0, 0, 0);

  { Set the stencil clear value }
  gl.ClearStencil($01);

  { Set the depth clear value }
  gl.ClearDepth(0.75);

  { Enable the depth and stencil tests }
  gl.Enable(TGLCapability.DepthTest);
  gl.Enable(TGLCapability.StencilTest);
end;

procedure TStencilOpApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

function TStencilOpApp.NeedStencilBuffer: Boolean;
begin
  Result := True;
end;

procedure TStencilOpApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
const
  VERTICES: array [0..5 * 4 - 1] of TVector3 = (
   // Quad #0
   (X: -0.75; Y:  0.25; Z: 0.50),
   (X: -0.25; Y:  0.25; Z: 0.50),
   (X: -0.25; Y:  0.75; Z: 0.50),
   (X: -0.75; Y:  0.75; Z: 0.50),
   // Quad #1
   (X:  0.25; Y:  0.25; Z: 0.90),
   (X:  0.75; Y:  0.25; Z: 0.90),
   (X:  0.75; Y:  0.75; Z: 0.90),
   (X:  0.25; Y:  0.75; Z: 0.90),
   // Quad #2
   (X: -0.75; Y: -0.75; Z: 0.50),
   (X: -0.25; Y: -0.75; Z: 0.50),
   (X: -0.25; Y: -0.25; Z: 0.50),
   (X: -0.75; Y: -0.25; Z: 0.50),
   // Quad #3
   (X:  0.25; Y: -0.75; Z: 0.50),
   (X:  0.75; Y: -0.75; Z: 0.50),
   (X:  0.75; Y: -0.25; Z: 0.50),
   (X:  0.25; Y: -0.25; Z: 0.50),
   // Big Quad
   (X: -1.00; Y: -1.00; Z: 0.00),
   (X:  1.00; Y: -1.00; Z: 0.00),
   (X:  1.00; Y:  1.00; Z: 0.00),
   (X: -1.00; Y:  1.00; Z: 0.00));
const
  INDICES0: array [0..5] of UInt8 = ( 0,  1,  2,  0,  2,  3); // Quad #0
  INDICES1: array [0..5] of UInt8 = ( 4,  5,  6,  4,  6,  7); // Quad #1
  INDICES2: array [0..5] of UInt8 = ( 8,  9, 10,  8, 10, 11); // Quad #2
  INDICES3: array [0..5] of UInt8 = (12, 13, 14, 12, 14, 15); // Quad #3
  INDICES4: array [0..5] of UInt8 = (16, 17, 18, 16, 18, 19); // Big Quad
const
  TEST_COUNT = 4;
const
  COLORS: array [0..TEST_COUNT - 1] of TVector4 = (
    (R: 1; G: 0; B: 0; A: 1),
    (R: 0; G: 1; B: 0; A: 1),
    (R: 0; G: 0; B: 1; A: 1),
    (R: 1; G: 1; B: 0; A: 0));
var
  StencilValues: array [0..TEST_COUNT - 1] of Byte;
  I: Integer;
begin
  StencilValues[0] := $07; // Result of test 0
  StencilValues[1] := $00; // Result of test 1
  StencilValues[2] := $02; // Result of test 2

  { Clear the color, depth, and stencil buffers.
    At this point, the stencil buffer will be $01 for all pixels. }
  gl.Clear([TGLClear.Color, TGLClear.Depth, TGLClear.Stencil]);

  { Use the program }
  FProgram.Use;

  { Set the data for the vertex attribute }
  FAttrPosition.SetData(VERTICES);
  FAttrPosition.Enable;

  { Test 0:

    Initialize upper-left region. In this case, the stencil-buffer values will
    be replaced because the stencil test for the rendered pixels will fail the
    stencil test, which is:

      ref     mask   stencil  mask
     ($07 and $03) < ($01 and $07 )

    The value in the stencil buffer for these pixels will be $07. }
  gl.StencilFunc(TGLCompareFunc.Less, $07, $03);
  gl.StencilOp(TGLStencilOp.Replace, TGLStencilOp.Decrement, TGLStencilOp.Decrement);
  gl.DrawElements(TGLPrimitiveType.Triangles, INDICES0);

  { Test 1:

    Initialize upper-right region. Here, we'll decrement the stencil-buffer
    values where the stencil test passes but the depth test fails. The stencil
    test is:

      ref     mask   stencil  mask
     ($03 and $03) > ($01 and $03 )

    But where the geometry fails the depth test. The stencil values for these
    pixels will be $00. }
  gl.StencilFunc(TGLCompareFunc.Greater, $03, $03);
  gl.StencilOp(TGLStencilOp.Keep, TGLStencilOp.Decrement, TGLStencilOp.Keep);
  gl.DrawElements(TGLPrimitiveType.Triangles, INDICES1);

  { Test 2:

    Initialize the lower-left region. Here we'll increment (with saturation) the
    stencil value where both the stencil and depth tests pass. The stencil test
    for these pixels will be:

      ref     mask   stencil  mask
     ($01 and $03) = ($01 and $03 )

    The stencil values for these pixels will be $02. }
  gl.StencilFunc(TGLCompareFunc.Equal, $01, $03);
  gl.StencilOp(TGLStencilOp.Keep, TGLStencilOp.Increment, TGLStencilOp.Increment);
  gl.DrawElements(TGLPrimitiveType.Triangles, INDICES2);

  { Test 3:

    Finally, initialize the lower-right region. We'll invert the stencil value
    where the stencil tests fails. The stencil test for these pixels will be:

      ref     mask   stencil  mask
     ($02 and $01) = ($01 and $01 )

    The stencil value here will be set to (not ((2^s-1) and $01)), (with the $01
    being from the stencil clear value), where 's' is the number of bits in the
    stencil buffer }
  gl.StencilFunc(TGLCompareFunc.Equal, $02, $01);
  gl.StencilOp(TGLStencilOp.Invert, TGLStencilOp.Keep, TGLStencilOp.Keep);
  gl.DrawElements(TGLPrimitiveType.Triangles, INDICES3);

  { Since we don't know at compile time how many stencil bits are present, we'll
    query, and update the value correct value in the StencilValues arrays for
    the fourth tests. We'll use this value later in rendering. }
  StencilValues[3] := (not (((1 shl TGLFramebuffer.GetCurrent.GetStencilBits) - 1) and $01)) and $FF;

  { Use the stencil buffer for controlling where rendering will occur. We
    disable writing to the stencil buffer so we can test against them without
    modifying the values we generated. }
  gl.StencilMask($00);

  for I := 0 to TEST_COUNT - 1 do
  begin
    gl.StencilFunc(TGLCompareFunc.Equal, StencilValues[I], $FF);
    FUniColor.SetValue(COLORS[I]);
    gl.DrawElements(TGLPrimitiveType.Triangles, INDICES4);
  end;

  { Reset the stencil mask }
  gl.StencilMask($FF);
end;

procedure TStencilOpApp.Shutdown;
begin
  { Release resources }
  FProgram.Delete;
end;

end.
