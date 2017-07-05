unit App;

{ Based on Simple_VertexShader.c from
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
  Sample.Geometry,
  Sample.App;

type
  TSimpleVSApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FAttrPosition: TGLVertexAttrib;
    FAttrTexCoord: TGLVertexAttrib;
    FUniMVPMatrix: TGLUniform;
    FCube: TCubeGeometry;
    FRotation: Single;
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

{ TSimpleVSApp }

procedure TSimpleVSApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
begin
  { Compile vertex and fragment shaders }
  VertexShader.New(TGLShaderType.Vertex,
    'uniform mat4 u_mvpMatrix;'#10+

    'attribute vec4 a_position;'#10+
    'attribute vec2 a_texcoord;'#10+

    'varying vec2 v_texcoord;'#10+

    'void main()'#10+
    '{'#10+
    '  gl_Position = u_mvpMatrix * a_position;'#10+
    '  v_texcoord = a_texcoord;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'varying vec2 v_texcoord;'#10+

    'void main()'#10+
    '{'#10+
    '  gl_FragColor = vec4(v_texcoord.x, v_texcoord.y, 1.0, 1.0);'#10+
    '}');
  FragmentShader.Compile;

  { Link shaders into program }
  FProgram.New(VertexShader, FragmentShader);
  FProgram.Link;

  { We don't need the shaders anymore. Note that the shaders won't actually be
    deleted until the program is deleted. }
  VertexShader.Delete;
  FragmentShader.Delete;

  { Initialize vertex attributes }
  FAttrPosition.Init(FProgram, 'a_position');
  FAttrTexCoord.Init(FProgram, 'a_texcoord');

  { Initialize uniform }
  FUniMVPMatrix.Init(FProgram, 'u_mvpMatrix');

  { Generate the geometry data }
  FCube.Generate(0.5);

  { Set initial rotation }
  FRotation := 45;

  { Set clear color to black }
  gl.ClearColor(0, 0, 0, 0);

  { Enable culling of back-facing polygons }
  gl.CullFace(TGLFace.Back);
  gl.Enable(TGLCapability.CullFace);
end;

procedure TSimpleVSApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TSimpleVSApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  Perspective, Rotate, Translate, Model, MVP: TMatrix4;
begin
  { Clear the color buffer }
  gl.Clear([TGLClear.Color]);

  { Use the program }
  FProgram.Use;

  { Set the data for the vertex attributes }
  FAttrPosition.SetData<TVector3>(FCube.Positions);
  FAttrPosition.Enable;

  FAttrTexCoord.SetData<TVector2>(FCube.TexCoords);
  FAttrTexCoord.Enable;

  { Calculate and set MVP matrix }
  FRotation := FMod(FRotation + (ADeltaTimeSec * 40), 360);

  Perspective.InitPerspectiveFovRH(Radians(60), Width / Height, 1, 20);

  Translate.InitTranslation(0, 0, -2);
  Rotate.InitRotation(Vector3(1, 0, 1), Radians(FRotation));
  Model := Translate * Rotate;

  MVP := Perspective * Model;

  FUniMVPMatrix.SetValue(MVP);

  { Draw the cube }
  gl.DrawElements(TGLPrimitiveType.Triangles, FCube.Indices);
end;

procedure TSimpleVSApp.Shutdown;
begin
  { Release resources }
  FProgram.Delete;
end;

end.
