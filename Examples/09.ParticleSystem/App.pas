unit App;

{ Based on ParticleSystem.c from
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
  TParticleSystemApp = class(TApplication)
  private const
    PARTICLE_COUNT = 1024;
  private type
    TParticle = record
      Lifetime: Single;
      StartPosition: TVector3;
      EndPosition: TVector3;
    end;
  private
    FProgram: TGLProgram;
    FAttrLifetime: TGLVertexAttrib;
    FAttrStartPos: TGLVertexAttrib;
    FAttrEndPos: TGLVertexAttrib;
    FUniTime: TGLUniform;
    FUniCenterPos: TGLUniform;
    FUniColor: TGLUniform;
    FUniSampler: TGLUniform;
    FTexture: TGLTexture;
    FParticles: array [0..PARTICLE_COUNT - 1] of TParticle;
    FParticleTime: Single;
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
  Sample.Assets,
  Sample.Texture,
  Sample.Platform;

{ TParticleSystemApp }

procedure TParticleSystemApp.Initialize;
var
  VertexShader, FragmentShader: TGLShader;
  I: Integer;
  Angle, Radius, S, C: Single;
  Uniform: TGLUniform;
begin
  { Initialize the asset manager }
  TAssets.Initialize;

  { Compile vertex and fragment shaders }
  VertexShader.New(TGLShaderType.Vertex,
    'uniform float u_time;'#10+
    'uniform float u_pointScale;'#10+
    'uniform vec3 u_centerPosition;'#10+

    'attribute float a_lifetime;'#10+
    'attribute vec3 a_startPosition;'#10+
    'attribute vec3 a_endPosition;'#10+

    'varying float v_lifetime;'#10+

    'void main()'#10+
    '{'#10+
    '  if (u_time <= a_lifetime)'#10+
    '  {'#10+
    '    gl_Position.xyz = a_startPosition + (u_time * a_endPosition);'#10+
    '    gl_Position.xyz += u_centerPosition;'#10+
    '    gl_Position.w = 1.0;'#10+
    '  }'#10+
    '  else'#10+
    '  {'#10+
    '    gl_Position = vec4(-1000, -1000, 0, 0);'#10+
    '  }'#10+

    '  v_lifetime = 1.0 - (u_time / a_lifetime);'#10+
    '  v_lifetime = clamp(v_lifetime, 0.0, 1.0);'#10+
    '  gl_PointSize = (v_lifetime * v_lifetime) * u_pointScale;'#10+
    '}');
  VertexShader.Compile;

  FragmentShader.New(TGLShaderType.Fragment,
    'precision mediump float;'#10+

    'uniform vec4 u_color;'#10+
    'uniform sampler2D s_texture;'#10+

    'varying float v_lifetime;'#10+

    'void main()'#10+
    '{'#10+
    '  vec4 texColor;'#10+
    '  texColor = texture2D(s_texture, gl_PointCoord);'#10+
    '  gl_FragColor = vec4(u_color) * texColor;'#10+
    '  gl_FragColor.a *= v_lifetime;'#10+
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
  FAttrLifetime.Init(FProgram, 'a_lifetime');
  FAttrStartPos.Init(FProgram, 'a_startPosition');
  FAttrEndPos.Init(FProgram, 'a_endPosition');

  { Initialize uniforms }
  FUniTime.Init(FProgram, 'u_time');
  FUniCenterPos.Init(FProgram, 'u_centerPosition');
  FUniColor.Init(FProgram, 'u_color');
  FUniSampler.Init(FProgram, 's_texture');

  { The gl_PointSize vertex shader output does not take screen scale into
    account. So we scale it ourselves. }
  FProgram.Use;
  Uniform.Init(FProgram, 'u_pointScale');
  Uniform.SetValue(40.0 * TPlatform.ScreenScale);

  { Set clear color to black }
  gl.ClearColor(0, 0, 0, 0);

  { Fill in particle data array }
  for I := 0 to PARTICLE_COUNT - 1 do
  begin
    FParticles[I].Lifetime := Random;

    Angle := Random * 2 * Pi;
    Radius := Random * 2;
    FastSinCos(Angle, S, C);
    FParticles[I].EndPosition.Init(S * Radius, C * Radius, 0);

    Angle := Random * 2 * Pi;
    Radius := Random * 0.25;
    FastSinCos(Angle, S, C);
    FParticles[I].StartPosition.Init(S * Radius, C * Radius, 0);
  end;

  FParticleTime := 1;

  FTexture := LoadTexture('smoke.tga');
end;

procedure TParticleSystemApp.KeyDown(const AKey: Integer; const AShift: TShiftState);
begin
  { Terminate app when Esc key is pressed }
  if (AKey = vkEscape) then
    Terminate;
end;

procedure TParticleSystemApp.Render(const ADeltaTimeSec, ATotalTimeSec: Double);
var
  CenterPos: TVector3;
  Color: TVector4;
begin
  { Clear the color buffer }
  gl.Clear([TGLClear.Color]);

  { Use the program }
  FProgram.Use;

  { Update uniforms }
  FParticleTime := FParticleTime + ADeltaTimeSec;
  if (FParticleTime >= 1) then
  begin
    FParticleTime := 0;

    { Pick a new start location and color }
    CenterPos.Init(Random - 0.5, Random - 0.5, Random - 0.5);
    FUniCenterPos.SetValue(CenterPos);

    { Random color }
    Color.Init(Random, Random, Random, 0.5);
    FUniColor.SetValue(Color);
  end;

  { Load uniform time variable }
  FUniTime.SetValue(FParticleTime);

  { Load the vertex attributes }
  FAttrLifetime.SetData(TGLDataType.Float, 1, @FParticles[0].Lifetime, SizeOf(TParticle));
  FAttrStartPos.SetData(TGLDataType.Float, 3, @FParticles[0].StartPosition, SizeOf(TParticle));
  FAttrEndPos.SetData(TGLDataType.Float, 3, @FParticles[0].EndPosition, SizeOf(TParticle));
  FAttrLifetime.Enable;
  FAttrStartPos.Enable;
  FAttrEndPos.Enable;

  { Blend particles }
  gl.Enable(TGLCapability.Blend);
  gl.BlendFunc(TGLBlendFunc.SrcAlpha, TGLBlendFunc.One);

  { Bind the texture }
  FTexture.BindToTextureUnit(0);

  { Set the sampler texture unit to 0 }
  FUniSampler.SetValue(0);

  { Draw the particle points }
  gl.DrawArrays(TGLPrimitiveType.Points, PARTICLE_COUNT);
end;

procedure TParticleSystemApp.Shutdown;
begin
  { Release resources }
  FTexture.Delete;
  FProgram.Delete;
end;

end.
