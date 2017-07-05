unit App;

{ Based on Simple_TextureCubemap.c from
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
  Sample.App,
  Sample.Geometry;

type
  TSimpleTextureCubeMapApp = class(TApplication)
  private
    FProgram: TGLProgram;
    FAttrPosition: TGLVertexAttrib;
    FAttrNormal: TGLVertexAttrib;
    FUniSampler: TGLUniform;
    FTexture: TGLTexture;
    FSphere: TSphereGeometry;
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
  Sample.Texture;

{ TSimpleTextureCubeMapApp }

procedure TSimpleTextureCubeMapApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
begin
  { Compile vertex and fragment shaders }
  VertexShader.New(TGLShaderType.Vertex,
    'attribute vec4 a_position;'#10+
    'attribute vec3 a_normal;'#10+

    'varying vec3 v_normal;'#10+

    'void main()'#10+
    '{'#10+
    '  gl_Position = a_position;'#10+
    '  v_normal = a_normal;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'varying vec3 v_normal;'#10+

    'uniform samplerCube s_texture;'#10+

    'void main()'#10+
    '{'#10+
    '  gl_FragColor = textureCube(s_texture, v_normal);'#10+
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
  FAttrNormal.Init(FProgram, 'a_normal');

  { Initialize uniform }
  FUniSampler.Init(FProgram, 's_texture');

  { Load the texture }
  FTexture := CreateSimpleTextureCubeMap;

  { Generate the geometry data }
  FSphere.Generate(128, 0.75);

  { Set clear color to black }
  gl.ClearColor(0, 0, 0, 0);

  { Enable culling }
  gl.CullFace(TGLFace.Back);
  gl.Enable(TGLCapability.CullFace);
end;

procedure TSimpleTextureCubeMapApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TSimpleTextureCubeMapApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
begin
  { Clear the color buffer }
  gl.Clear([TGLClear.Color]);

  { Use the program }
  FProgram.Use;

  { Set the data for the vertex attributes }
  FAttrPosition.SetData<TVector3>(FSphere.Positions);
  FAttrPosition.Enable;
  FAttrNormal.SetData<TVector3>(FSphere.Normals);
  FAttrNormal.Enable;

  { Bind the texture }
  FTexture.BindToTextureUnit(0);

  { Set the texture sampler to texture unit to 0 }
  FUniSampler.SetValue(0);

  { Draw the sphere }
  FSphere.DrawWithIndices;
end;

procedure TSimpleTextureCubeMapApp.Shutdown;
begin
  { Release resources }
  FTexture.Delete;
  FProgram.Delete;
end;

end.
