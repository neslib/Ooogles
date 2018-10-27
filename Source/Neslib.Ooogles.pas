unit Neslib.Ooogles;
{< Ooogles - Object Oriented OpenGL-ES 2.0 }

{ Copyright (c) 2017 by Erik van Bilsen
  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. }

{$INCLUDE 'Ooogles.inc'}

interface

uses
  System.SysUtils,
  {$INCLUDE 'OpenGL.inc'}
  Neslib.FastMath;

{$IF Defined(MACOS) and not Defined(IOS)}
const
  GL_RGB565 = $8D62;
{$ENDIF}

{ You @bold(must) call this procedure @bold(After) you have created and activated
  your OpenGL context. This is needed to emulate OpenGL-ES on OpenGL platforms.
  If your application uses multiple contexts, you must call InitOoogles once for
  each context (after making it current). }
procedure InitOoogles;

type
  { OpenGL error codes }
  TGLError = (
    { No error has been recorded. }
    NoError = GL_NO_ERROR,

    { An unacceptable value is specified for an enumerated argument. The
      offending command is ignored and has no other side effect than to set the
      error flag. }
    InvalidEnum = GL_INVALID_ENUM,

    { A numeric argument is out of range. The offending command is ignored and
      has no other side effect than to set the error flag. }
    InvalidValue = GL_INVALID_VALUE,

    { The specified operation is not allowed in the current state. The offending
      command is ignored and has no other side effect than to set the error
      flag. }
    InvalidOperation = GL_INVALID_OPERATION,

    { The command is trying to render to or read from the framebuffer while the
      currently bound framebuffer is not framebuffer complete. The offending
      command is ignored and has no other side effect than to set the error
      flag. }
    InvalidFramebufferOperation = GL_INVALID_FRAMEBUFFER_OPERATION,

    { There is not enough memory left to execute the command. The state of the
      GL is undefined, except for the state of the error flags, after this error
      is recorded. }
    OutOfMemory = GL_OUT_OF_MEMORY);

type
  { A buffer to clear using gl.Clear. }
  TGLClear = (
    { Reserved (only here for API compatibility) }
    _Reserved = 0,

    { To clear the depth buffer }
    Depth = 8,     // Log2(GL_DEPTH_BUFFER_BIT)

    { To clear the stencil buffer }
    Stencil = 10,  // Log2(GL_STENCIL_BUFFER_BIT)

    { To clear the color buffer }
    Color = 14);   // Log2(GL_COLOR_BUFFER_BIT)

  { A set of buffers to clear using gl.Clear. }
  TGLClearBuffers = set of TGLClear;

type
  { The type of a shader }
  TGLShaderType = (
    { A vertex shader }
    Vertex = GL_VERTEX_SHADER,

    { A fragment shader }
    Fragment = GL_FRAGMENT_SHADER);

type
  { Supported data types }
  TGLDataType = (
    { 8-bit signed integer.
      Corresponds to Delphi's Int8 or ShortInt. }
    Byte = GL_BYTE,

    { 16-bit signed integer
      Corresponds to Delphi's Int16 or SmallInt. }
    Short = GL_SHORT,

    { 32-bit signed integer
      Corresponds to Delphi's Int32 or Integer. }
    Int = GL_INT,

    { 32-bit floating-point value.
      Corresponds to Delphi's Single type. }
    Float = GL_FLOAT,

    { 8-bit unsigned integer.
      Corresponds to Delphi's UInt8 or Byte. }
    UnsignedByte = GL_UNSIGNED_BYTE,

    { 16-bit unsigned integer.
      Corresponds to Delphi's UInt16 or Word. }
    UnsignedShort = GL_UNSIGNED_SHORT,

    { 32-bit unsigned integer.
      Corresponds to Delphi's UInt32 or Cardinal. }
    UnsignedInt = GL_UNSIGNED_INT);

type
  { Supported primitive types }
  TGLPrimitiveType = (
    { Single points. }
    Points = GL_POINTS,

    { Single lines. }
    Lines = GL_LINES,

    { Connected lines. }
    LineStrip = GL_LINE_STRIP,

    { Connected lines, closed to form a polygon. }
    LineLoop = GL_LINE_LOOP,

    { Single triangles. }
    Triangles = GL_TRIANGLES,

    { A strip of triangles. }
    TriangleStrip = GL_TRIANGLE_STRIP,

    { A fan of triangles. }
    TriangleFan = GL_TRIANGLE_FAN);

type
  { Supported buffer types }
  TGLBufferType = (
    { A vertex buffer (aka array buffer).
      Contains an array of vertices. }
    Vertex = GL_ARRAY_BUFFER,

    { An index buffer (aka element array buffer).
      Contains an array of indices to vertices. }
    Index = GL_ELEMENT_ARRAY_BUFFER);

type
  { Hints how a buffer object's data is accessed. }
  TGLBufferUsage = (
    { The data stored in a buffer will be modified once and used many times. }
    StaticDraw = GL_STATIC_DRAW,

    { The data stored in a buffer will be modified once and used at most a few
      times. }
    StreamDraw = GL_STREAM_DRAW,

    { The data stored in a buffer will be modified repeatedly and used many
      times. }
    DynamicDraw = GL_DYNAMIC_DRAW);


type
  { Supported types of indices }
  TGLIndexType = (
    { 8-bit unsigned integer.
      Corresponds to Delphi's UInt8 or Byte. }
    UnsignedByte = GL_UNSIGNED_BYTE,

    { 16-bit unsigned integer.
      Corresponds to Delphi's UInt16 or Word. }
    UnsignedShort = GL_UNSIGNED_SHORT);

type
  { Supported texture types }
  TGLTextureType = (
    { A 2D texture }
    TwoD = GL_TEXTURE_2D,

    { A cube map texture }
    CubeMap = GL_TEXTURE_CUBE_MAP);

type
  { Supported pixel formats }
  TGLPixelFormat = (
    { Each element is a single alpha component. The GL converts it to floating
      point and assembles it into an RGBA element by attaching 0 for red, green,
      and blue. Each component is then clamped to the range [0,1]. }
    Alpha = GL_ALPHA,

    { Each element is an RGB triple. The GL converts it to floating point and
      assembles it into an RGBA element by attaching 1 for alpha. Each component
      is then clamped to the range [0,1]. }
    RGB = GL_RGB,

    { Each element contains all four components. The GL converts it to floating
      point, then each component is clamped to the range [0,1]. }
    RGBA = GL_RGBA,

    { Each element is a single luminance value. The GL converts it to floating
      point, then assembles it into an RGBA element by replicating the luminance
      value three times for red, green, and blue and attaching 1 for alpha. Each
      component is then clamped to the range [0,1]. }
    Luminance = GL_LUMINANCE,

    { Each element is a luminance/alpha pair. The GL converts it to floating
      point, then assembles it into an RGBA element by replicating the luminance
      value three times for red, green, and blue. Each component is then clamped
      to the range [0,1]. }
    LuminanceAlpha = GL_LUMINANCE_ALPHA);

type
  { Target indices for the six sides of a cube texture:
    * 0: Face in positive X direction
    * 1: Face in negative X direction
    * 2: Face in positive Y direction
    * 3: Face in negative Y direction
    * 4: Face in positive Z direction
    * 5: Face in negative Z direction }
  TGLCubeTarget = 0..5;

type
  { Supported pixel data types }
  TGLPixelDataType = (
    { Each byte is interpreted as one color component (red, green, blue or
      alpha). When converted to floating point, the value is divided by 255. }
    UnsignedByte = GL_UNSIGNED_BYTE,

    { A single 16-bit integer contains 5 bits for the red component, 6 bits for
      the green component and 5 bits for the blue component. When converted to
      floating point, the red and blue components are divided by 31 and the
      green component is divided by 63. }
    UnsignedShort565 = GL_UNSIGNED_SHORT_5_6_5,

    { A single 16-bit integer contains all components, with 4 bits for each
      component. When converted to floating point, every component is divided
      by 15. }
    UnsignedShort4444 = GL_UNSIGNED_SHORT_4_4_4_4,

    { A single 16-bit integer contains all components, with 5 bits for the red,
      green and blue components, and 1 bit for the alpha component. When
      converted to floating point, the red, green and blue components are
      divided by 31 and the alpha component is used as-is. }
    UnsignedShort5551 = GL_UNSIGNED_SHORT_5_5_5_1);

type
  { Texture magnification filters }
  TGLMagFilter = (
    { Returns the value of the texture element that is nearest (in Manhattan
      distance) to the center of the pixel being textured.
      This is usually the fastest method. }
    Nearest = GL_NEAREST,

    { Returns the weighted average of the four texture elements that are closest
      to the center of the pixel being textured.
      This usually provides better quality. }
    Linear = GL_LINEAR);

type
  { Texture minification filters }
  TGLMinFilter = (
    { Returns the value of the texture element that is nearest (in Manhattan
      distance) to the center of the pixel being textured.
      This is usually the fastest method. }
    Nearest = GL_NEAREST,

    { Returns the weighted average of the four texture elements that are closest
      to the center of the pixel being textured.
      This usually provides better quality than Nearest. }
    Linear = GL_LINEAR,

    { Chooses the mipmap that most closely matches the size of the pixel being
      textured and uses the Nearest criterion (the texture element nearest to
      the center of the pixel) to produce a texture value.
      This is usually the fastest method when using mipmapping. }
    NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,

    { Chooses the mipmap that most closely matches the size of the pixel being
      textured and uses the Linear criterion (a weighted average of the four
      texture elements that are closest to the center of the pixel) to produce a
      texture value. }
    LinearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST,

    { Chooses the two mipmaps that most closely match the size of the pixel
      being textured and uses the Nearest criterion (the texture element nearest
      to the center of the pixel) to produce a texture value from each mipmap.
      The final texture value is a weighted average of those two values. }
    NearestMipmapLinear = GL_NEAREST_MIPMAP_LINEAR,

    { Chooses the two mipmaps that most closely match the size of the pixel
      being textured and uses the Linear criterion (a weighted average of the
      four texture elements that are closest to the center of the pixel) to
      produce a texture value from each mipmap. The final texture value is a
      weighted average of those two values.
      This is usually the slowest (but highest quality) method when using
      mipmapping. }
    LinearMipmapLinear = GL_LINEAR_MIPMAP_LINEAR);

type
  { Texture wrapping modes }
  TGLWrapMode = (
    { Repeats the texture. Causes the integer part of the texture coordinate to
      be ignored; the GL uses only the fractional part, thereby creating a
      repeating pattern. }
    NormalRepeat = GL_REPEAT,

    { Repeats and mirrors the texture. Causes the final texture coordinate (Dst)
      to be set to the fractional part of the original texture coordinate (Src)
      if the integer part of Src is even; if the integer part of Src is odd,
      then Dst is set to 1 - Frac(Src), where Frac(Src) represents the
      fractional part of Src. }
    MirroredRepeat = GL_MIRRORED_REPEAT,

    { Clamps the texture to its edges. Causes the texture coordinate to be
      clamped to the size of the texture in the direction of clamping. }
    ClampToEdge = GL_CLAMP_TO_EDGE);

type
  { Mipmap hinting options, as used by TGLTexture.MipmapHint }
  TGLMipmapHint = (
    { The most efficient option should be chosen. }
    Fastest = GL_FASTEST,

    { The most correct, or highest quality, option should be chosen. }
    Nicest = GL_NICEST,

    { No preference. }
    DontCare = GL_DONT_CARE);

type
  { OpenGL capabilities than can be enabled and disabled (using gl.Enable and
    gl.Disable) }
  TGLCapability = (
    { If enabled, blend the computed fragment color values with the values in
      the color buffers.

      SeeAlso:
        gl.BlendFunc. }
    Blend = GL_BLEND,

    { If enabled, cull polygons based on their winding in window coordinates.

      SeeAlso:
        gl.CullFace. }
    CullFace = GL_CULL_FACE,

    { If enabled, do depth comparisons and update the depth buffer. Note that
      even if the depth buffer exists and the depth mask is non-zero, the depth
      buffer is not updated if the depth test is disabled.

      SeeAlso:
        gl.DepthFunc and gl.DepthRangef. }
    DepthTest = GL_DEPTH_TEST,

    { If enabled, dither color components or indices before they are written to
      the color buffer. }
    Dither = GL_DITHER,

    { If enabled, an offset is added to depth values of a polygon's fragments
      produced by rasterization.

      SeeAlso:
        gl.PolygonOffset. }
    PolygonOffsetFill = GL_POLYGON_OFFSET_FILL,

    { If enabled, compute a temporary coverage value where each bit is
      determined by the alpha value at the corresponding sample location. The
      temporary coverage value is then ANDed with the fragment coverage value. }
    SampleAlphaToCoverage = GL_SAMPLE_ALPHA_TO_COVERAGE,

    { If enabled, the fragment's coverage is ANDed with the temporary coverage
      value.

      SeeAlso:
        gl.SampleCoverage. }
    SampleCoverage = GL_SAMPLE_COVERAGE,

    { If enabled, discard fragments that are outside the scissor rectangle.

      SeeAlso:
        gl.Scissor. }
    ScissorTest = GL_SCISSOR_TEST,

    { If enabled, do stencil testing and update the stencil buffer.

      SeeAlso:
        gl.StencilFunc and gl.StencilOp. }
    StencilTest = GL_STENCIL_TEST);

type
  { Faces used for culling and stencilling. }
  TGLFace = (
    { Front-facing polygons are culled. }
    Front = GL_FRONT,

    { Back-facing polygons are culled (the default). }
    Back = GL_BACK,

    { Front- and back-facing polygons are culled. }
    FrontAndBack = GL_FRONT_AND_BACK);

type
  { Specifies the orientation of front-facing polygons, as used by
    gl.FrontFace. }
  TGLFaceOrientation = (
    { Clockwise winding }
    Clockwise = GL_CW,

    { Counter-clockwise winding (default) }
    CounterClockwise = GL_CCW);

type
  { Pixel storage modes, as used by gl.PixelStore. }
  TGLPixelStoreMode = (
    { Specifies the packing of pixel data downloading from the GPU into
      client memory. }
    PackAlignment = GL_PACK_ALIGNMENT,

    { Specifies the packing of pixel data when uploading from client memory to
      the GPU. }
    UnpackAlignment = GL_UNPACK_ALIGNMENT);

type
  { Allowed values for TGLPixelStorage mode, as used by gl.PixelStore. }
  TGLPixelStoreValue = (
    { Pixel data is aligned on a byte boundary }
    One = 1,

    { Pixel data is aligned on 2-byte boundary }
    Two = 2,

    { Pixel data is aligned on 4-byte boundary }
    Four = 4,

    { Pixel data is aligned on 8-byte boundary }
    Eight = 8);

type
  { Blend functions as used by gl.BlendFunc and gl.BlendFuncSeparate.
    In the descriptions of the items, the following terms are used:
    * SColor: source color (R, G and B values)
    * SAlpha: source alpha
    * DColor: destination color
    * DAlpha: destination alpha
    * RColor: resulting color
    * RAlpha: resulting alpha
    * CColor: constant color, as specified using gl.BlendColor
    * CAlpha: constant alpha, as specified using gl.BlendColor }
  TGLBlendFunc = (
    { RColor = 0, RAlpha = 0 }
    Zero = GL_ZERO,

    { RColor = 1, RAlpha = 1 }
    One = GL_ONE,

    { RColor = SColor, RAlpha = SAlpha }
    SrcColor = GL_SRC_COLOR,

    { RColor = 1 - SColor, RAlpha = 1 - SAlpha }
    OneMinusSrcColor = GL_ONE_MINUS_SRC_COLOR,

    { RColor = DColor, RAlpha = DAlpha }
    DstColor = GL_DST_COLOR,

    { RColor = 1 - DColor, RAlpha = 1 - DAlpha }
    OneMinusDstColor = GL_ONE_MINUS_DST_COLOR,

    { RColor = SAlpha, RAlpha = SAlpha }
    SrcAlpha = GL_SRC_ALPHA,

    { RColor = 1 - SAlpha, RAlpha = 1 - SAlpha }
    OneMinusSrcAlpha = GL_ONE_MINUS_SRC_ALPHA,

    { RColor = DAlpha, RAlpha = DAlpha }
    DstAlpha = GL_DST_ALPHA,

    { RColor = 1 - DAlpha, RAlpha = 1 - DAlpha }
    OneMinusDstAlpha = GL_ONE_MINUS_DST_ALPHA,

    { RColor = CColor, RAlpha = CAlpha }
    ConstantColor = GL_CONSTANT_COLOR,

    { RColor = 1 - CColor, RAlpha = 1 - CAlpha }
    OneMinusConstantColor = GL_ONE_MINUS_CONSTANT_COLOR,

    { RColor = CAlpha, RAlpha = CAlpha }
    ConstantAlpha = GL_CONSTANT_ALPHA,

    { RColor = 1 - CAlpha, RAlpha = 1 - CAlpha }
    OneMinusConstantAlpha = GL_ONE_MINUS_CONSTANT_ALPHA,

    { RColor = Min(SAlpha, 1 - DAlpha), RAlpha = 1 }
    SrcAlphaSaturate = GL_SRC_ALPHA_SATURATE);

type
  { Blend equations as used by gl.BlendEquation and gl.BlendEquationSeparate. }
  TGLBlendEquation = (
    { Result = (SrcColor * SrcWeigth) + (DstColor * DstWeight) }
    Add = GL_FUNC_ADD,

    { Result = (SrcColor * SrcWeigth) - (DstColor * DstWeight) }
    Subtract = GL_FUNC_SUBTRACT,

    { Result = (DstColor * DstWeight) - (SrcColor * SrcWeigth) }
    ReverseSubtract = GL_FUNC_REVERSE_SUBTRACT);

type
  { Compare functions as used by gl.StencilFunc and gl.DepthFunc. }
  TGLCompareFunc = (
    { The function always fails. }
    Never = GL_NEVER,

    { For stencil operations, the function passes
        if (Ref and Mask) < (Stencil and Mask).
      For depth operations, the function passes
        if the incoming depth value is less than the stored depth value. }
    Less = GL_LESS,

    { For stencil operations, the function passes
        if (Ref and Mask) <= (Stencil and Mask).
      For depth operations, the function passes
        if the incoming depth value is less than or equal to the stored depth
        value. }
    LessOrEqual = GL_LEQUAL,

    { For stencil operations, the function passes
        if (Ref and Mask) > (Stencil and Mask).
      For depth operations, the function passes
        if the incoming depth value is greater than the stored depth value. }
    Greater = GL_GREATER,

    { For stencil operations, the function passes
        if (Ref and Mask) >= (Stencil and Mask).
      For depth operations, the function passes
        if the incoming depth value is greater than or equal to the stored depth
        value. }
    GreaterOrEqual = GL_GEQUAL,

    { For stencil operations, the function passes
        if (Ref and Mask) = (Stencil and Mask).
      For depth operations, the function passes
        if the incoming depth value is equal to the stored depth value. }
    Equal = GL_EQUAL,

    { For stencil operations, the function passes
        if (Ref and Mask) <> (Stencil and Mask).
      For depth operations, the function passes
        if the incoming depth value is not equal to the stored depth value. }
    NotEqual = GL_NOTEQUAL,

    { The function always passes. }
    Always = GL_ALWAYS);

type
  { Stencil operations as used by gl.StencilOp. }
  TGLStencilOp = (
    { Keeps the current value. }
    Keep = GL_KEEP,

    { Sets the stencil buffer value to 0. }
    Zero = GL_ZERO,

    { Sets the stencil buffer value to ARef, as specified by gl.StencilFunc. }
    Replace = GL_REPLACE,

    { Increments the current stencil buffer value. Clamps to the maximum
      representable unsigned value. }
    Increment = GL_INCR,

    { Increments the current stencil buffer value. Wraps stencil buffer value to
      zero when incrementing the maximum representable unsigned value. }
    IncrementAndWrap =  GL_INCR_WRAP,

    { Decrements the current stencil buffer value. Clamps to 0. }
    Decrement = GL_DECR,

    { Decrements the current stencil buffer value. Wraps stencil buffer value to
      the maximum representable unsigned value when decrementing a stencil
      buffer value of zero. }
    DecrementAndWrap = GL_DECR_WRAP,

    { Bitwise inverts the current stencil buffer value. }
    Invert = GL_INVERT);

type
  { Specifies the color-renderable, depth-renderable, or stencil-renderable
    format of a TGLRenderbuffer. }
  TGLRenderbufferFormat = (
    { Color format with alpha support, using 4 bits per component (red, green,
      blue and alpha) }
    RGBA4 = GL_RGBA4,

    { Color format without alpha support, using 5 bits for the red and blue
      components and 6 bits for the green component. }
    RGB565 = GL_RGB565,

    { Color format with alpha support, using 5 bits for each color component
      (red, green and blue) and 1 bit for the alpha component. }
    RGB5_A1 = GL_RGB5_A1,

    { 16-bit depth format }
    Depth16 = GL_DEPTH_COMPONENT16,

    { 9-bit stencil format }
    Stencil8 = GL_STENCIL_INDEX8);

type
  { Completeness status of a TGLFramebuffer. }
  TGLFramebufferStatus = (
    { The framebuffer is complete }
    Complete = GL_FRAMEBUFFER_COMPLETE,

    { Not all framebuffer attachment points are framebuffer attachment complete.
      This means that at least one attachment point with a renderbuffer or
      texture attached has its attached object no longer in existence or has an
      attached image with a width or height of zero, or the color attachment
      point has a non-color-renderable image attached, or the depth attachment
      point has a non-depth-renderable image attached, or the stencil attachment
      point has a non-stencil-renderable image attached. }
    IncompleteAttachment = GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT,

    { Not all attached images have the same width and height. }
    IncompleteDimensions = {$IF Defined(DESKTOP_OPENGL)}
                           GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT,
                           {$ELSE}
                           GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS,
                           {$ENDIF}

    { No images are attached to the framebuffer. }
    MissingAttachment = GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT,

    { The combination of internal formats of the attached images violates an
      implementation-dependent set of restrictions. }
    Unsupported = GL_FRAMEBUFFER_UNSUPPORTED);

type
  { Attachment points of a TGLFramebuffer }
  TGLFramebufferAttachment = (
    { Attachment point for a color buffer }
    Color = GL_COLOR_ATTACHMENT0,

    { Attachment point for a depth buffer }
    Depth = GL_DEPTH_ATTACHMENT,

    { Attachment point for a stencil buffer }
    Stencil = GL_STENCIL_ATTACHMENT);

type
  { Types of objects attached to a TGLFramebuffer }
  TGLFramebufferAttachmentType = (
    { No renderbuffer or texture is attached. }
    None = GL_NONE,

    { The attachment is a renderbuffer }
    RenderBuffer = GL_RENDERBUFFER,

    { The attachment is a texture }
    Texture = GL_TEXTURE);

type
  { Supported data types for attributes }
  TGLAttrDataType = (
    { Single-precision floating-point type.
      Corresponds to Delphi's Single type. }
    Float = GL_FLOAT,

    { A vector of 2 floats.
      Corresponds to FastMath's TVector2 type. }
    Vector2 = GL_FLOAT_VEC2,

    { A vector of 3 floats.
      Corresponds to FastMath's TVector3 type. }
    Vector3 = GL_FLOAT_VEC3,

    { A vector of 4 floats.
      Corresponds to FastMath's TVector4 type. }
    Vector4 = GL_FLOAT_VEC4,

    { A 2x2 matrix of floats.
      Corresponds to FastMath's TMatrix2 type. }
    Matrix2 = GL_FLOAT_MAT2,

    { A 3x3 matrix of floats.
      Corresponds to FastMath's TMatrix3 type. }
    Matrix3 = GL_FLOAT_MAT3,

    { A 4x4 matrix of floats.
      Corresponds to FastMath's TMatrix4 type. }
    Matrix4 = GL_FLOAT_MAT4);

type
  { Information about an attribute as returned by TGLProgram.GetAttributeInfo. }
  TGLAttrInfo = record
    { The data type of the attribute variable. }
    DataType: TGLAttrDataType;

    { The size of the attribute variable, in units of type DataType. }
    Size: Integer;

    { The name of the attribute variable. }
    Name: RawByteString;
  end;

type
  { Supported data types for uniforms }
  TGLUniformDataType = (
    { Single-precision floating-point type.
      Corresponds to Delphi's Single type. }
    Float = GL_FLOAT,

    { A vector of 2 floats.
      Corresponds to FastMath's TVector2 type. }
    Vector2 = GL_FLOAT_VEC2,

    { A vector of 3 floats.
      Corresponds to FastMath's TVector3 type. }
    Vector3 = GL_FLOAT_VEC3,

    { A vector of 4 floats.
      Corresponds to FastMath's TVector4 type. }
    Vector4 = GL_FLOAT_VEC4,

    { 32-bit integer type.
      Corresponds to Delphi's Integer type. }
    Int = GL_INT,

    { A vector of 2 integers.
      Corresponds to FastMath's TIVector2 type. }
    IVector2 = GL_INT_VEC2,

    { A vector of 3 integers.
      Corresponds to FastMath's TIVector3 type. }
    IVector3 = GL_INT_VEC3,

    { A vector of 4 integers.
      Corresponds to FastMath's TIVector4 type. }
    IVector4 = GL_INT_VEC4,

    { Boolean type. }
    Bool = GL_BOOL,

    { A vector of 2 booleans. }
    BVector2 = GL_BOOL_VEC2,

    { A vector of 3 booleans. }
    BVector3 = GL_BOOL_VEC3,

    { A vector of 4 booleans. }
    BVector4 = GL_BOOL_VEC4,

    { A 2x2 matrix of floats.
      Corresponds to FastMath's TMatrix2 type. }
    Matrix2 = GL_FLOAT_MAT2,

    { A 3x3 matrix of floats.
      Corresponds to FastMath's TMatrix3 type. }
    Matrix3 = GL_FLOAT_MAT3,

    { A 4x4 matrix of floats.
      Corresponds to FastMath's TMatrix4 type. }
    Matrix4 = GL_FLOAT_MAT4,

    { A 2D texture sampler }
    Sampler2D = GL_SAMPLER_2D,

    { A cubetexture sampler }
    SamplerCube = GL_SAMPLER_CUBE);

type
  { Information about a uniform as returned by TGLProgram.GetUniformInfo. }
  TGLUniformInfo = record
    { The data type of the uniform variable. }
    DataType: TGLUniformDataType;

    { The size of the uniform variable. For arrays, this is the length of the
      array. Otherwise, the value is 1. }
    Size: Integer;

    { The name of the uniform variable. }
    Name: RawByteString;
  end;

type
  { Exception type for OpenGL related errors.

    When compiling with the DEBUG conditional define, and assertions enabled
    (the default configuration for Debug builds), every OpenGL call is checked
    for errors, and this type of exception is raised when an error occurs. }
  EGLError = class(Exception)
  {$REGION 'Internal Declarations'}
  private
    FError: TGLError;
    FErrorMethod: String;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AErrorCode: Integer; const AMethod: String);

    { The OpenGL error that happened. }
    property Error: TGLError read FError;

    { The method in which the error occurred. }
    property ErrorMethod: String read FErrorMethod;
  end;

type
  { Exception type for OpenGL shader compilation and linking errors. These types
    of errors are only checked when DEBUG is defined. }
   EGLShaderError = class(Exception);

type
  { Static class (or namespace) for OpenGL APIs that are not tied to a specific
    object. }
  gl = class // static
  {$REGION 'Internal Declarations'}
  private
    class function GetString(const AName: GLenum): RawByteString; static;
  {$ENDREGION 'Internal Declarations'}
  public
    (* Errors *)

    { Returns the last error that happened.
      You usually don't need to call this method yourself since all OpenGL calls
      are error checked automatically when compiling in DEBUG mode with
      Assertions enabled.

      Returns:
        The last error that happened.

      @bold(OpenGL API): glGetError }
    class function GetError: TGLError; inline; static;
  public
    (* Coordinate Transformations *)

    { Set the viewport.

      Parameters:
        ALeft: (optional) X-coordinate of the lower left corner of the viewport
          rectangle, in pixels. The initial value is 0.
        ABottom: (optional) Y-coordinate of the lower left corner of the viewport
          rectangle, in pixels. The initial value is 0.
        AWidth: width of the viewport.
        AHeight: height of the viewport.

      Raises:
        TGLError.InvalidValue if either AWidth or AHeight is negative.

      When a GL context is first attached to a window, width and height are set
      to the dimensions of that window.

      This method specifies the affine transformation of X and Y from normalized
      device coordinates to window coordinates.

      Viewport width and height are silently clamped to a range that depends on
      the implementation. To query this range, call GetMaxViewportDimensions.

      @bold(OpenGL API): glViewport

      SeeAlso:
        GetViewport, GetMaxViewportDimensions }
    class procedure Viewport(const ALeft, ABottom, AWidth, AHeight: Integer); overload; inline; static;
    class procedure Viewport(const AWidth, AHeight: Integer); overload; inline; static;

    { Returns the current viewport. Initially the ALeft and ABottom window
      coordinates are both set to 0, and AWidth and AHeight are set to the width
      and height of the window into which the GL will do its rendering.

      @bold(OpenGL API): glGetIntegerv(GL_VIEWPORT)

      SeeAlso:
        Viewport }
    class procedure GetViewport(out ALeft, ABottom, AWidth, AHeight: Integer); inline; static;

    { Returns the maximum supported width and height of the viewport. These must
      be at least as large as the visible dimensions of the display being
      rendered to.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_VIEWPORT_DIMS)

      SeeAlso:
        Viewport }
    class procedure GetMaxViewportDimensions(out AMaxWidth, AMaxHeight: Integer); inline; static;

    { Specify mapping of depth values from normalized device coordinates to
      window coordinates.

      Parameters:
        ANearValue: specifies the mapping of the near clipping plane to window
          coordinates. The initial value is 0.
        AFarValue: specifies the mapping of the far clipping plane to window
          coordinates. The initial value is 1.

      After clipping and division by W, depth coordinates range from -1 to 1,
      corresponding to the near and far clipping planes. This method specifies a
      linear mapping of the normalized depth coordinates in this range to window
      depth coordinates. Regardless of the actual depth buffer implementation,
      window coordinate depth values are treated as though they range from 0
      through 1 (like color components). Thus, the values accepted by DepthRange
      are both clamped to this range before they are accepted.

      The setting of (0, 1) maps the near plane to 0 and the far plane to 1.
      With this mapping, the depth buffer range is fully utilized.

      @bold(Note): it is not necessary that ANearVal be less than AFarVal.
      Reverse mappings such as ANearVal = 1, and AFarVal = 0 are acceptable.

      @bold(OpenGL API): glDepthRangef

      SeeAlso:
        GetDepthRange, DepthFunc, PolygonOffset, Viewport }
    class procedure DepthRange(const ANearVal, AFarVal: Single); inline; static;

    { Gets the near and far clipping planes.

      Parameters:
        ANearValue: is set to the mapping of the near clipping plane.
        AFarValue: is set to the mapping of the far clipping plane.

      @bold(OpenGL API): glGetFloatv(GL_DEPTH_RANGE)

      SeeAlso:
        DepthRange }
    class procedure GetDepthRange(out ANearVal, AFarVal: Single); inline; static;
  public
    (* Whole Framebuffer Operations *)

    { Specify clear values used by gl.Clear to clear the color buffers.

      Parameters:
        ARed: red component.
        AGreen: green component.
        ABlue: blue component.
        AAlpha: alpha component.

      All values are clamped to the range 0..1.

      @bold(OpenGL API): glClearColor

      SeeAlso:
        Clear, GetClearColor }
    class procedure ClearColor(const ARed, AGreen, ABlue, AAlpha: Single); overload; inline; static;

    { Specify clear values used by gl.Clear to clear the color buffers.

      Parameters:
        AColor: the clear color.

      The R, G, B and A values in AColor are clamped to the range 0..1.

      @bold(OpenGL API): glClearColor

      SeeAlso:
        Clear, GetClearColor }
    class procedure ClearColor(const AColor: TVector4); overload; inline; static;

    { Returns the current color used to clear the color buffers.

      @bold(OpenGL API): glGetFloatv(GL_COLOR_CLEAR_VALUE)

      SeeAlso:
        ClearColor }
    class function GetClearColor: TVector4; inline; static;

    { Enable and disable writing of frame buffer color components.

      Parameters:
        ARed: whether red can or cannot be written into the frame buffer.
        AGreen: whether green can or cannot be written into the frame buffer.
        ABlue: whether blue can or cannot be written into the frame buffer.
        AAlpha: whether alpha can or cannot be written into the frame buffer.

      The initial values of the parameters are all True, indicating that the
      color components can be written.

      This method specifies whether the individual color components in the frame
      buffer can or cannot be written. If red is False, for example, no change
      is made to the red component of any pixel in any of the color buffers,
      regardless of the drawing operation attempted.

      Changes to individual bits of components cannot be controlled. Rather,
      changes are either enabled or disabled for entire color components.

      @bold(OpenGL API): glColorMask

      SeeAlso:
        GetColorMask, Clear, DepthMask, StencilMask }
    class procedure ColorMask(const ARed, AGreen, ABlue, AAlpha: Boolean); inline; static;

    { Get whether writing of frame buffer color components is enabled.

      Parameters:
        ARed: is set to True of red can be written. False otherwise.
        AGreen: is set to True of green can be written. False otherwise.
        ABlue: is set to True of blue can be written. False otherwise.
        AAlpha: is set to True of alpha can be written. False otherwise.

      @bold(OpenGL API): glGetIntegerv(GL_COLOR_WRITEMASK)

      SeeAlso:
        ColorMask }
    class procedure GetColorMask(out ARed, AGreen, ABlue, AAlpha: Boolean); inline; static;

    { Specify the clear value used by gl.Clear to clear the depth buffer.

      Parameters:
        ADepth: the depth value used when the depth buffer is cleared. The
          initial value is 1. The value is clamped to the range 0..1.

      @bold(OpenGL API): glClearDepthf/glClearDepth

      SeeAlso:
        Clear, GetClearDepth }
    class procedure ClearDepth(const ADepth: Single); inline; static;

    { Gets the current clear depth value.

      Returns:
        The current clear depth value.

      @bold(OpenGL API): glGetFloatv(GL_DEPTH_CLEAR_VALUE)

      SeeAlso:
        ClearDepth }
    class function GetClearDepth: Single; inline; static;

    { Enable or disable writing into the depth buffer.

      Parameters:
        AEnable: specifies whether the depth buffer is enabled for writing. If
          False, depth buffer writing is disabled. Otherwise, it is enabled.
          Initially, depth buffer writing is enabled.

      @bold(OpenGL API): glDepthMask

      SeeAlso:
        GetDepthMask, ColorMask, DepthFunc, DepthRange, StencilMask }
    class procedure DepthMask(const AEnable: Boolean); inline; static;

    { Checks whether writing into the depth buffer is enabled.

      Returns:
        True if writing into the depth buffer is enabled. False otherwise.

      @bold(OpenGL API): glGetIntegerv(GL_DEPTH_WRITEMASK)

      SeeAlso:
        DepthMask }
    class function GetDepthMask: Boolean; inline; static;

    { Specify the index value used by gl.Clear to clear the stencil buffer.

      Parameters:
        AIndex: the index used when the stencil buffer is cleared. The initial
          value is 0. Only the lowest TGLFramebuffer.GetStencilBits bits of the
          index are used.

      @bold(OpenGL API): glClearStencil

      SeeAlso:
        Clear, GetClearStencil, TGLFramebuffer.GetStencilBits, StencilFunc,
        StencilFuncSeparate, StencilMask, StencilMaskSeparate, StencilOp,
        StencilOpSeparate }
    class procedure ClearStencil(const AIndex: Integer); inline; static;

    { Returns the index to which the stencil bitplanes are cleared. The initial
      value is 0.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_CLEAR_VALUE)

      SeeAlso:
        ClearStencil }
    class function GetClearStencil: Integer; inline; static;

    { Control the front and back writing of individual bits in the stencil
      planes.

      Parameters:
        AMask: specifies a bit mask to enable and disable writing of individual
          bits in the stencil planes. Initially, the mask is all 1's.

      StencilMask controls the writing of individual bits in the stencil planes.
      The least significant n bits of AMask, where n is the number of bits in
      the stencil buffer, specify a mask. Where a 1 appears in the mask, it's
      possible to write to the corresponding bit in the stencil buffer. Where a
      0 appears, the corresponding bit is write-protected. Initially, all bits
      are enabled for writing.

      There can be two separate mask writemasks; one affects back-facing
      polygons, and the other affects front-facing polygons as well as other
      non-polygon primitives. StencilMask sets both front and back stencil
      writemasks to the same values. Use StencilMaskSeparate to set front and
      back stencil writemasks to different values.

      @bold(Note): StencilMask is the same as calling gl.StencilMaskSeparate
      with face set to FrontAndBack.

      @bold(OpenGL API): glStencilMask

      SeeAlso:
        GetStencilWriteMask, GetStencilBackWriteMask,
        TGLFramebuffer.GetStencilBits, ColorMask, DepthMask, StencilFunc,
        StencilFuncSeparate, StencilMaskSeparate, StencilOp, StencilOpSeparate }
    class procedure StencilMask(const AMask: Cardinal); inline; static;

    { Control the front and/or back writing of individual bits in the stencil
      planes.

      Parameters:
        AFace: specifies whether front and/or back stencil writemask is updated.
        AMask: specifies a bit mask to enable and disable writing of individual
          bits in the stencil planes. Initially, the mask is all 1's.

      See StencilMask for more details.

      @bold(OpenGL API): glStencilMaskSeparate

      SeeAlso:
        GetStencilWriteMask, GetStencilBackWriteMask,
        TGLFramebuffer.GetStencilBits, ColorMask, DepthMask, StencilFunc,
        StencilFuncSeparate, StencilMask, StencilOp, StencilOpSeparate }
    class procedure StencilMaskSeparate(const AFace: TGLFace;
      const AMask: Cardinal); inline; static;

    { Get the mask that controls writing of the stencil bitplanes for
      front-facing polygons and non-polygons. The initial value is all 1's.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_WRITEMASK)

      SeeAlso:
        StencilMask, StencilMaskSeparate }
    class function GetStencilWriteMask: Cardinal; inline; static;

    { Get the mask that controls writing of the stencil bitplanes for
      back-facing polygons. The initial value is all 1's.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_BACK_WRITEMASK)

      SeeAlso:
        StencilMask, StencilMaskSeparate }
    class function GetStencilBackWriteMask: Cardinal; inline; static;

    { Clear buffers to preset values.

      Parameters:
        ABuffers: the buffers to be cleared.

      The value to which each buffer is cleared depends on the setting of the
      clear value for that buffer, as set by ClearColor, ClearStencil and
      ClearDepth.

      The pixel ownership test, the scissor test, dithering, and the buffer
      writemasks affect the operation of Clear. The scissor box bounds the
      cleared region. Blend function, stenciling, fragment shading, and
      depth-buffering are ignored by Clear.

      @bold(OpenGL API): glClear

      SeeAlso:
        ClearColor, GetClearColor, ClearStencil, GetClearStencil, ClearDepth.
        GetClearDepth, ColorMask, DepthMask, Scissor, StencilMask }
    class procedure Clear(const ABuffers: TGLClearBuffers); inline; static;
  public
    (* Per-Fragment Operations *)

    { Specify pixel arithmetic using blend functions.

      Parameters:
        ASrcFactor: specifies how the red, green, blue, and alpha source
          blending factors are computed. The initial value is One.
        ADstFactor: specifies how the red, green, blue, and alpha destination
          blending factors are computed. The initial value is Zero.

      Pixels can be drawn using a function that blends the incoming (source)
      RGBA values with the RGBA values that are already in the frame buffer (the
      destination values). Blending is initially disabled. Use Enable and
      Disable with argument TGLCapability.Blend to enable and disable blending.

      BlendFunc defines the operation of blending when it is enabled. ASrcFactor
      specifies which method is used to scale the source color components.
      ADstFactor specifies which method is used to scale the destination color
      components. See TGLBlendFunc for a description of the possible operations.

      @bold(Note): incoming (source) alpha is correctly thought of as a material
      opacity, ranging from 1.0, representing complete opacity, to 0.0,
      representing complete transparency.

      @bold(Note): transparency is best implemented using blend function
      (SrcAlpha, OneMinusSrcAlpha) with primitives sorted from farthest to
      nearest. Note that this transparency calculation does not require the
      presence of alpha bitplanes in the frame buffer.

      @bold(OpenGL API): glBlendFunc

      SeeAlso:
        GetBlendSrcRgb, GetBlendSrcAlpha, GetBlendDstRgb, GetBlendDstAlpha,
        BlendColor, BlendEquation, BlendEquationSeparate, Clear, Enable,
        StencilFunc, BlendFuncSeparate }
    class procedure BlendFunc(const ASrcFactor, ADstFactor: TGLBlendFunc); inline; static;

    { Specify pixel arithmetic for RGB and alpha components separately.

      Parameters:
        ASrcRgb: specifies how the red, green and blue source blending factors
          are computed. The initial value is One.
        ADstRgb: specifies how the red, green and blue destination blending
          factors are computed. The initial value is Zero.
        ASrcAlpha: specifies how the alpha source blending factor is computed.
          The initial value is One.
        ADstAlpha: specifies how the alpha destination blending factor is
          computed. The initial value is Zero.

      Pixels can be drawn using a function that blends the incoming (source)
      RGBA values with the RGBA values that are already in the frame buffer (the
      destination values). Blending is initially disabled. Use Enable and
      Disable with argument TGLCapability.Blend to enable and disable blending.

      BlendFuncSeparate defines the operation of blending when it is enabled.
      ASrcRgb specifies which method is used to scale the source RGB-color
      components. ADstRGB specifies which method is used to scale the
      destination RGB-color components. Likewise, ASrcAlpha specifies which
      method is used to scale the source alpha color component, and ADstAlpha
      specifies which method is used to scale the destination alpha component.
      See TGLBlendFunc for a description of the possible operations.

      @bold(Note): incoming (source) alpha is correctly thought of as a material
      opacity, ranging from 1.0, representing complete opacity, to 0.0,
      representing complete transparency.

      @bold(OpenGL API): glBlendFuncSeparate

      SeeAlso:
        GetBlendSrcRgb, GetBlendSrcAlpha, GetBlendDstRgb, GetBlendDstAlpha,
        BlendColor, BlendEquation, BlendEquationSeparate, Clear, Enable,
        StencilFunc, BlendFunc }
    class procedure BlendFuncSeparate(const ASrcRgb, ADstRgb, ASrcAlpha,
      ADstAlpha: TGLBlendFunc); inline; static;

    { Gets the current RGB source blend function.

      Returns:
        The blend function.

      @bold(OpenGL API): glGetIntegerv(GL_BLEND_SRC_RGB)

      SeeAlso:
        BlendFunc, BlendFuncSeparate }
    class function GetBlendSrcRgb: TGLBlendFunc; inline; static;

    { Gets the current alpha source blend function.

      Returns:
        The blend function.

      @bold(OpenGL API): glGetIntegerv(GL_BLEND_SRC_ALPHA)

      SeeAlso:
        BlendFunc, BlendFuncSeparate }
    class function GetBlendSrcAlpha: TGLBlendFunc; inline; static;

    { Gets the current RGB destination blend function.

      Returns:
        The blend function.

      @bold(OpenGL API): glGetIntegerv(GL_BLEND_DST_RGB)

      SeeAlso:
        BlendFunc, BlendFuncSeparate }
    class function GetBlendDstRgb: TGLBlendFunc; inline; static;

    { Gets the current alpha destination blend function.

      Returns:
        The blend function.

      @bold(OpenGL API): glGetIntegerv(GL_BLEND_DST_ALPHA)

      SeeAlso:
        BlendFunc, BlendFuncSeparate }
    class function GetBlendDstAlpha: TGLBlendFunc; inline; static;

    { Specify the equation used for both the RGB blend equation and the Alpha
      blend equation.

      Parameters:
        AEquation: specifies how source and destination colors are combined.

      The blend equations determine how a new pixel (the "source" color) is
      combined with a pixel already in the framebuffer (the "destination"
      color). This function sets both the RGB blend equation and the alpha blend
      equation to a single equation.

      These equations use the source and destination blend factors specified by
      either BlendFunc or BlendFuncSeparate. See BlendFunc or BlendFuncSeparate
      for a description of the various blend factors.

      See TGLBlendEquation for a description of the available options.
      The results of these equations are clamped to the range 0..1.

      The Add equation is useful for antialiasing and transparency, among other
      things.

      Initially, both the RGB blend equation and the alpha blend equation are
      set to Add.

      @bold(OpenGL API): glBlendEquation

      SeeAlso:
        GetBlendEquationRgb, GetBlendEquationAlpha, BlendColor,
        BlendEquationSeparate, BlendFunc, BlendFuncSeparate }
    class procedure BlendEquation(const AEquation: TGLBlendEquation); inline; static;

    { Set the RGB blend equation and the alpha blend equation separately.

      Parameters:
        AEquationRgb: specifies how the red, green, and blue components of the
          source and destination colors are combined.
        AEquationAlpha: specifies how the alpha component of the source and
          destination colors are combined

      The blend equations determine how a new pixel (the "source" color) is
      combined with a pixel already in the framebuffer (the "destination"
      color). This function specifies one blend equation for the RGB-color
      components and one blend equation for the alpha component.

      These equations use the source and destination blend factors specified by
      either BlendFunc or BlendFuncSeparate. See BlendFunc or BlendFuncSeparate
      for a description of the various blend factors.

      See TGLBlendEquation for a description of the available options.
      The results of these equations are clamped to the range 0..1.

      The Add equation is useful for antialiasing and transparency, among other
      things.

      Initially, both the RGB blend equation and the alpha blend equation are
      set to Add.

      @bold(OpenGL API): glBlendEquation

      SeeAlso:
        GetBlendEquationRgb, GetBlendEquationAlpha, BlendColor, BlendEquation,
        BlendFunc, BlendFuncSeparate }
    class procedure BlendEquationSeparate(const AEquationRgb,
      AEquationAlpha: TGLBlendEquation); inline; static;

    { Gets the current RGB blend equation.

      Returns:
        The blend equation.

      @bold(OpenGL API): glGetIntegerv(GL_BLEND_EQUATION_RGB)

      SeeAlso:
        BlendEquation, BlendEquationSeparate }
    class function GetBlendEquationRgb: TGLBlendEquation; inline; static;

    { Gets the current alpha blend equation.

      Returns:
        The blend equation.

      @bold(OpenGL API): glGetIntegerv(GL_BLEND_EQUATION_ALPHA)

      SeeAlso:
        BlendEquation, BlendEquationSeparate }
    class function GetBlendEquationAlpha: TGLBlendEquation; inline; static;

    { Set the blend color.

      Parameters:
        ARed: red component.
        AGreen: green component.
        ABlue: blue component.
        AAlpha: alpha component.

      The blend color may be used to calculate the source and destination
      blending factors. The color components are clamped to the range 0..1
      before being stored. See BlendFunc for a complete description of the
      blending operations. Initially the blend color is set to (0, 0, 0, 0).

      @bold(OpenGL API): glBlendColor

      SeeAlso:
        GetBlendColor, BlendEquation, BlendFunc }
    class procedure BlendColor(const ARed, AGreen, ABlue, AAlpha: Single); overload; inline; static;

    { Set the blend color.

      Parameters:
        AColor: the blend color.

      The blend color may be used to calculate the source and destination
      blending factors. The color components are clamped to the range 0..1
      before being stored. See BlendFunc for a complete description of the
      blending operations. Initially the blend color is set to (0, 0, 0, 0).

      @bold(OpenGL API): glBlendColor

      SeeAlso:
        GetBlendColor, BlendEquation, BlendFunc }
    class procedure BlendColor(const AColor: TVector4); overload; inline; static;

    { Gets the current blend color.

      Returns:
        The blend color.

      @bold(OpenGL API): glGetFloatv(GL_BLEND_COLOR)

      SeeAlso:
        BlendColor }
    class function GetBlendColor: TVector4; inline; static;

    { Set front and back function and reference value for stencil testing.

      Parameters:
        AFunc: the test function. Initial value is TGLCompareFunc.Always.
        ARef: (optional) value that specifies the reference value for the
          stencil test. ARef is clamped to the range [0, 2n - 1], where n is the
          number of bitplanes in the stencil buffer. The initial value is 0.
        AMask: (optional) value that specifies a mask that is ANDed with both
          the reference value and the stored stencil value when the test is
          done. The initial value is all 1's.

      Stenciling, like depth-buffering, enables and disables drawing on a
      per-pixel basis. Stencil planes are first drawn into using GL drawing
      primitives, then geometry and images are rendered using the stencil planes
      to mask out portions of the screen. Stenciling is typically used in
      multipass rendering algorithms to achieve special effects, such as decals,
      outlining, and constructive solid geometry rendering.

      The stencil test conditionally eliminates a pixel based on the outcome of
      a comparison between the reference value and the value in the stencil
      buffer. To enable and disable the test, call gl.Enable and gl.Disable with
      argument TGLCapability.StencilTest. To specify actions based on the
      outcome of the stencil test, call gl.StencilOp or gl.StencilOpSeparate.

      There can be two separate sets of AFunc, ARef, and AMask parameters; one
      affects back-facing polygons, and the other affects front-facing polygons
      as well as other non-polygon primitives. StencilFunc sets both front and
      back stencil state to the same values. Use StencilFuncSeparate to set
      front and back stencil state to different values.

      AFunc is an enum that determines the stencil comparison function. It
      accepts one of eight values (see TGLCompareFunc).

      ARef is an integer reference value that is used in the stencil comparison.
      It is clamped to the range [0, 2n - 1], where n is the number of bitplanes
      in the stencil buffer.

      AMask is bitwise ANDed with both the reference value and the stored
      stencil value, with the ANDed values participating in the comparison.

      @bold(Note): initially, the stencil test is disabled. If there is no
      stencil buffer, no stencil modification can occur and it is as if the
      stencil test always passes.

      @bold(Note): StencilFunc is the same as calling StencilFuncSeparate with
      AFace set to FrontAndBack.

      @bold(OpenGL API): glStencilFunc

      SeeAlso:
        GetStencilFunc, GetStencilValueMask, GetStencilRef, GetStencilBackFunc,
        GetStencilBackValueMask, GetStencilBackRef,
        TGLFramebuffer.GetStencilBits, BlendFunc, DepthFunc, Enable,
        StencilFuncSeparate, StencilMask, StencilMaskSeparate, StencilOp,
        StencilOpSeparate }
    class procedure StencilFunc(const AFunc: TGLCompareFunc;
      const ARef: Integer = 0; const AMask: Cardinal = $FFFFFFFF); inline; static;

    { Set front and/or back function and reference value for stencil testing.

      Parameters:
        AFace: specifies whether front and/or back stencil state is updated.
        AFunc: the test function. Initial value is TGLCompareFunc.Always.
        ARef: (optional) value that specifies the reference value for the
          stencil test. ARef is clamped to the range [0, 2n - 1], where n is the
          number of bitplanes in the stencil buffer. The initial value is 0.
        AMask: (optional) value that specifies a mask that is ANDed with both
          the reference value and the stored stencil value when the test is
          done. The initial value is all 1's.

      See StencilFunc for more details.

      @bold(OpenGL API): glStencilFuncSeparate

      SeeAlso:
        GetStencilFunc, GetStencilValueMask, GetStencilRef, GetStencilBackFunc,
        GetStencilBackValueMask, GetStencilBackRef,
        TGLFramebuffer.GetStencilBits, BlendFunc, DepthFunc, Enable,
        StencilFunc, StencilMask, StencilMaskSeparate, StencilOp,
        StencilOpSeparate }
    class procedure StencilFuncSeparate(const AFace: TGLFace;
      const AFunc: TGLCompareFunc; const ARef: Integer = 0;
      const AMask: Cardinal = $FFFFFFFF); inline; static;

    { Get what function is used to compare the stencil reference value with the
      stencil buffer value for front-facing polygons and non-polygons. The
      initial value is Always.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_FUNC)

      SeeAlso:
        StencilFunc, StencilFuncSeparate }
    class function GetStencilFunc: TGLCompareFunc; inline; static;

    { Get the mask that is used to mask both the stencil reference value and the
      stencil buffer value before they are compared for front-facing polygons
      and non-polygons. The initial value is all 1's.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_VALUE_MASK)

      SeeAlso:
        StencilFunc, StencilFuncSeparate }
    class function GetStencilValueMask: Cardinal; inline; static;

    { Get the reference value that is compared with the contents of the stencil
      buffer for front-facing polygons and non-polygons. The initial value is 0.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_REF)

      SeeAlso:
        StencilFunc, StencilFuncSeparate }
    class function GetStencilRef: Integer; inline; static;

    { Get what function is used for back-facing polygons to compare the stencil
      reference value with the stencil buffer value. The initial value is
      Always.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_BACK_FUNC)

      SeeAlso:
        StencilFunc, StencilFuncSeparate }
    class function GetStencilBackFunc: TGLCompareFunc; inline; static;

    { Get the mask that is used for back-facing polygons to mask both the
      stencil reference value and the stencil buffer value before they are
      compared. The initial value is all 1's.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_BACK_VALUE_MASK)

      SeeAlso:
        StencilFunc, StencilFuncSeparate }
    class function GetStencilBackValueMask: Cardinal; inline; static;

    { Get the reference value that is compared with the contents of the stencil
      buffer for back-facing polygons. The initial value is 0.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_REF)

      SeeAlso:
        StencilFunc, StencilFuncSeparate }
    class function GetStencilBackRef: Integer; inline; static;

    { Set front and back stencil test actions.

      Parameters:
        AStencilFail: (optional) value that specifies the action to take when
          the stencil test fails. The initial value is Keep.
        ADepthFail: (optional) value that specifies the action to take when
          the stencil test passes, but the depth test fails. The initial value
          is Keep.
        ABothPass: (optional) value that specifies the action to take when both
          the stencil test and depth test pass, or when the stencil test passes
          and either there is no depth buffer or depth testing is not enabled.
          The initial value is Keep.

      Stenciling, like depth-buffering, enables and disables drawing on a
      per-pixel basis. You draw into the stencil planes using GL drawing
      primitives, then render geometry and images, using the stencil planes to
      mask out portions of the screen. Stenciling is typically used in multipass
      rendering algorithms to achieve special effects, such as decals,
      outlining, and constructive solid geometry rendering.

      The stencil test conditionally eliminates a pixel based on the outcome of
      a comparison between the value in the stencil buffer and a reference
      value. To enable and disable the test, call gl.Enable and gl.Disable with
      argument TGLCapability.StencilTest; to control it, call gl.StencilFunc or
      gl.StencilFuncSeparate.

      There can be two separate sets of AStencilFail, ADepthFail and ABothPass
      parameters; one affects back-facing polygons, and the other affects
      front-facing polygons as well as other non-polygon primitives. StencilOp
      sets both front and back stencil state to the same values. Use
      gl.StencilOpSeparate to set front and back stencil state to different
      values.

      StencilOp takes three arguments that indicate what happens to the stored
      stencil value while stenciling is enabled. If the stencil test fails, no
      change is made to the pixel's color or depth buffers, and AStencilFail
      specifies what happens to the stencil buffer contents.

      Stencil buffer values are treated as unsigned integers. When incremented
      and decremented, values are clamped to 0 and 2n - 1, where n is the value
      returned by TGLFramebuffer.GetStencilBits.

      The other two arguments to StencilOp specify stencil buffer actions that
      depend on whether subsequent depth buffer tests succeed (ABothPass) or
      fail (ADepthFail) (see DepthFunc). Note that ADepthFail is ignored when
      there is no depth buffer, or when the depth buffer is not enabled. In
      these cases, AStencilFail and ABothPass specify stencil action when the
      stencil test fails and passes, respectively.

      @bold(Note): initially the stencil test is disabled. If there is no
      stencil buffer, no stencil modification can occur and it is as if the
      stencil tests always pass, regardless of any call to StencilOp.

      @bold(Note): StencilOp is the same as calling gl.StencilOpSeparate with
      face set to FrontAndBack.

      @bold(OpenGL API): glStencilOp

      SeeAlso:
        GetStencilFail, GetStencilPassDepthPass, GetStencilPassDepthFail,
        GetStencilBackFail, GetStencilBackPassDepthPass,
        GetStencilBackPassDepthFail, TGLFramebuffer.GetStencilBits, BlendFunc,
        DepthFunc, Enable, StencilFunc, StencilFuncSeparate, StencilMask,
        StencilMaskSeparate, StencilOpSeparate }
    class procedure StencilOp(
      const AStencilFail: TGLStencilOp = TGLStencilOp.Keep;
      const ADepthFail: TGLStencilOp = TGLStencilOp.Keep;
      const ABothPass: TGLStencilOp = TGLStencilOp.Keep); inline; static;

    { Set front and/or back stencil test actions.

      Parameters:
        AFace: specifies whether front and/or back stencil state is updated.
        AStencilFail: (optional) value that specifies the action to take when
          the stencil test fails. The initial value is Keep.
        ADepthFail: (optional) value that specifies the action to take when
          the stencil test passes, but the depth test fails. The initial value
          is Keep.
        ABothPass: (optional) value that specifies the action to take when both
          the stencil test and depth test pass, or when the stencil test passes
          and either there is no depth buffer or depth testing is not enabled.
          The initial value is Keep.

      See StencilOp for more details.

      @bold(OpenGL API): glStencilOpSeparate

      SeeAlso:
        GetStencilFail, GetStencilPassDepthPass, GetStencilPassDepthFail,
        GetStencilBackFail, GetStencilBackPassDepthPass,
        GetStencilBackPassDepthFail, TGLFramebuffer.GetStencilBits, BlendFunc,
        DepthFunc, Enable, StencilFunc, StencilFuncSeparate, StencilMask,
        StencilMaskSeparate, StencilOp }
    class procedure StencilOpSeparate(
      const AFace: TGLFace;
      const AStencilFail: TGLStencilOp = TGLStencilOp.Keep;
      const ADepthFail: TGLStencilOp = TGLStencilOp.Keep;
      const ABothPass: TGLStencilOp = TGLStencilOp.Keep); inline; static;

    { Get what action is taken when the stencil test fails for front-facing
      polygons and non-polygons. The initial value is Keep.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_FAIL)

      SeeAlso:
        StencilOp, StencilOpSeparate }
    class function GetStencilFail: TGLStencilOp; inline; static;

    { Get what action is taken when the stencil test passes and the depth test
      passes for front-facing polygons and non-polygons. The initial value is
      Keep.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_PASS_DEPTH_PASS)

      SeeAlso:
        StencilOp, StencilOpSeparate }
    class function GetStencilPassDepthPass: TGLStencilOp; inline; static;

    { Get what action is taken when the stencil test passes, but the depth test
      fails for front-facing polygons and non-polygons. The initial value is
      Keep.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_PASS_DEPTH_FAIL)

      SeeAlso:
        StencilOp, StencilOpSeparate }
    class function GetStencilPassDepthFail: TGLStencilOp; inline; static;

    { Get what action is taken for back-facing polygons when the stencil test
      fails. The initial value is Keep.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_BACK_FAIL)

      SeeAlso:
        StencilOp, StencilOpSeparate }
    class function GetStencilBackFail: TGLStencilOp; inline; static;

    { Get what action is taken for back-facing polygons when the stencil test
      passes and the depth test passes. The initial value is Keep.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_BACK_PASS_DEPTH_PASS)

      SeeAlso:
        StencilOp, StencilOpSeparate }
    class function GetStencilBackPassDepthPass: TGLStencilOp; inline; static;

    { Get what action is taken for back-facing polygons when the stencil test
      passes, but the depth test fails. The initial value is Keep.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_BACK_PASS_DEPTH_FAIL)

      SeeAlso:
        StencilOp, StencilOpSeparate }
    class function GetStencilBackPassDepthFail: TGLStencilOp; inline; static;

    { Specify the value used for depth buffer comparisons.

      Parameters:
        AFunc: specifies the depth comparison function. The initial value is
          TGLCompareFunc.Less.

      This method specifies the function used to compare each incoming pixel
      depth value with the depth value present in the depth buffer. The
      comparison is performed only if depth testing is enabled. (See gl.Enable
      and gl.Disable of TGLCapability.DepthTest.)

      Initially, depth testing is disabled. If depth testing is disabled or no
      depth buffer exists, it is as if the depth test always passes.

      @bold(Note): even if the depth buffer exists and the depth mask is
      non-zero, the depth buffer is not updated if the depth test is disabled.

      @bold(OpenGL API): glDepthFunc

      SeeAlso:
        GetDepthFunc, Enable, DepthRange, PolygonOffset }
    class procedure DepthFunc(const AFunc: TGLCompareFunc); inline; static;

    { Gets the current depth function.

      Returns:
        The current depth function.

      @bold(OpenGL API): glGetIntegerv(GL_DEPTH_FUNC)

      SeeAlso:
        DepthFunc }
    class function GetDepthFunc: TGLCompareFunc; inline; static;

    { Define the scissor box.

      Parameters:
        ALeft: X-coordinate of the lower left corner of the scissor box. The
          initial value is 0.
        ABottom: Y-coordinate of the lower left corner of the scissor box. The
          initial value is 0.
        AWidth: width of the scissor box.
        AHeight: height of the scissor box.

      Raises:
        TGLError.InvalidValue if either AWidth or AHeight is negative.

      When a GL context is first attached to a window, the width and height are
      set to the dimensions of that window.

      This method defines a rectangle, called the scissor box, in window
      coordinates. The first two arguments, ALeft and ABottom, specify the lower
      left corner of the box. AWidth and AHeight specify the width and height of
      the box.

      To enable and disable the scissor test, call Enable and Disable with
      TGLCapability.ScissorTest. The test is initially disabled. While the test
      is enabled, only pixels that lie within the scissor box can be modified by
      drawing commands. Window coordinates have integer values at the shared
      corners of frame buffer pixels. Scissor(0, 0, 1, 1) allows modification of
      only the lower left pixel in the window, and Scissor(0, 0, 0, 0) doesn't
      allow modification of any pixels in the window.

      When the scissor test is disabled, it is as though the scissor box
      includes the entire window.

      @bold(OpenGL API): glScissor

      SeeAlso:
        GetScissor, Enable, Viewport }
    class procedure Scissor(const ALeft, ABottom, AWidth, AHeight: Integer); inline; static;

    { Get the current scissor box.

      Parameters:
        ALeft: is set to the X-coordinate of the lower left corner of the
          scissor box.
        ABottom: is set to the Y-coordinate of the lower left corner of the
          scissor box.
        AWidth: is set to the width of the scissor box.
        AHeight: is set to the height of the scissor box.

      @bold(OpenGL API): glGetIntegerv(GL_SCISSOR_BOX)

      SeeAlso:
        Scissor }
    class procedure GetScissor(out ALeft, ABottom, AWidth, AHeight: Integer); inline; static;

    { Specify multisample coverage parameters.

      Parameters:
        AValue: sample coverage value. The value is clamped to the range 0..1.
          The initial value is 1.0.
        AInvert: (optional) value representing if the coverage masks should be
          inverted. Defaults to False.

      Multisampling samples a pixel multiple times at various
      implementation-dependent subpixel locations to generate antialiasing
      effects. Multisampling transparently antialiases points, lines, and
      polygons if it is enabled.

      AValue is used in constructing a temporary mask used in determining which
      samples will be used in resolving the final fragment color. This mask is
      bitwise-anded with the coverage mask generated from the multisampling
      computation. If the AInvert flag is set, the temporary mask is inverted
      (all bits flipped) and then the bitwise-and is computed.

      If an implementation does not have any multisample buffers available, or
      multisampling is disabled, rasterization occurs with only a single sample
      computing a pixel's final RGB color.

      Provided an implementation supports multisample buffers, and multisampling
      is enabled, then a pixel's final color is generated by combining several
      samples per pixel. Each sample contains color, depth, and stencil
      information, allowing those operations to be performed on each sample.

      @bold(OpenGL API): glSampleCoverage

      SeeAlso:
        GetSampleCoverageValue, GetSampleCoverageInvert,
        GetSampleAlphaToCoverage, GetSampleCoverage,
        TGLFramebuffer.GetSampleBuffers, TGLFramebuffer.GetSamples, Enable }
    class procedure SampleCoverage(const AValue: Single;
      const AInvert: Boolean = False); inline; static;

    { Get the current sample coverage value.

      Returns:
        The current sample coverage value.

      @bold(OpenGL API): glGetFloatv(GL_SAMPLE_COVERAGE_VALUE)

      SeeAlso:
        SampleCoverage, GetSampleCoverageInvert }
    class function GetSampleCoverageValue: Single; inline; static;

    { Get the current sample coverage invert flag.

      Returns:
        The current sample coverage invert flag.

      @bold(OpenGL API): glGetIntegerv(GL_SAMPLE_COVERAGE_INVERT)

      SeeAlso:
        SampleCoverage, GetSampleCoverageValue }
    class function GetSampleCoverageInvert: Boolean; inline; static;

    { Get a boolean value indicating if the fragment coverage value should be
      ANDed with a temporary coverage value based on the current sample coverage
      value. The initial value is False.

      @bold(OpenGL API): glGetIntegerv(GL_SAMPLE_COVERAGE)

      SeeAlso:
        SampleCoverage }
    class function GetSampleCoverage: Boolean; inline; static;

    { Get a boolean value indicating if the fragment coverage value should be
      ANDed with a temporary coverage value based on the fragment's alpha value.
      The initial value is False.

      @bold(OpenGL API): glGetIntegerv(GL_SAMPLE_ALPHA_TO_COVERAGE)

      SeeAlso:
        SampleCoverage }
    class function GetSampleAlphaToCoverage: Boolean; inline; static;
  public
    (* Vertex Arrays *)

    { Render primitives from array data, @bold(without) using indices.

      Parameters:
        AType: specifies what kind of primitives to render.
        AFirst: (optional) the starting index in the enabled arrays.
        ACount: the number of elements to be rendered.

      DrawArrays specifies multiple geometric primitives with very few
      subroutine calls. Instead of calling a GL procedure to pass each
      individual vertex attribute, you can use TGLVertexAttrib to prespecify
      separate arrays of vertices, normals, and colors and use them to construct
      a sequence of primitives with a single call to DrawArrays.

      When DrawArrays is called, it uses ACount sequential elements from each
      enabled array to construct a sequence of geometric primitives, beginning
      with element AFirst. AType specifies what kind of primitives are
      constructed and how the array elements construct those primitives.

      To enable and disable a generic vertex attribute array, call
      TGLVertexAttrib.Enable and TGLVertexAttrib.Disable.

      @bold(Note): if the current program object, as set by TGLProgram.Use, is
      invalid, rendering results are undefined. However, no error is generated
      for this case.

      Raises:
        TGLError.InvalidValue if ACount is negative.
        TGLError.InvalidFramebufferOperation if the currently bound
          framebuffer is not framebuffer complete.

      @bold(OpenGL API): glDrawArrays

      SeeAlso:
        TGLFramebuffer.Status, TGLVertexAttrib, TGLVertexAttrib.Enable,
        TGLVertexAttrib.Disable, DrawElements, TGLProgram.Use }
    class procedure DrawArrays(const AType: TGLPrimitiveType;
      const ACount: Integer); overload; inline; static;
    class procedure DrawArrays(const AType: TGLPrimitiveType;
      const AFirst, ACount: Integer); overload; inline; static;

    { Render primitives from array data, using supplied indices.

      Parameters:
        AType: specifies what kind of primitives to render.
        AIndices: array of indices (of type UInt8 or UInt16).
        AFirst: (optional) index to the first index in AIndices to use.
          Defaults to 0.
        ACount: (optional) number of indices in AIndices to use, starting at
          AFirst. Defaults to 0 (all remaining indices).

      DrawElements specifies multiple geometric primitives with very few
      subroutine calls. Instead of calling a GL function to pass each vertex
      attribute, you can use TGLVertexAttrib to prespecify separate arrays of
      vertex attributes and use them to construct a sequence of primitives
      with a single call to DrawElements.

      When DrawElements is called, it uses AIndices to located vertices in
      the vertex array. AType specifies what kind of primitives are
      constructed and how the array elements construct these primitives. If
      more than one array is enabled, each is used.

      To enable and disable a generic vertex attribute array, call
      TGLVertexAttrib.Enable and TGLVertexAttrib.Disable.

      @bold(Note): if the current program object, as set by TGLProgram.Use, is
      invalid, rendering results are undefined. However, no error is generated
      for this case.

      Raises:
        TGLError.InvalidFramebufferOperation if the currently bound
          framebuffer is not framebuffer complete.

      @bold(OpenGL API): glDrawElements

      SeeAlso:
        TGLFramebuffer.Status, TGLVertexAttrib, TGLVertexAttrib.Enable,
        TGLVertexAttrib.Disable, DrawArrays, TGLProgram.Use }
    class procedure DrawElements(const AType: TGLPrimitiveType;
      const AIndices: array of UInt8; const AFirst: Integer = 0;
      const ACount: Integer = 0); overload; static;
    class procedure DrawElements(const AType: TGLPrimitiveType;
      const AIndices: TArray<UInt8>; const AFirst: Integer = 0;
      const ACount: Integer = 0); overload; inline; static;
    class procedure DrawElements(const AType: TGLPrimitiveType;
      const AIndices: array of UInt16; const AFirst: Integer = 0;
      const ACount: Integer = 0); overload; static;
    class procedure DrawElements(const AType: TGLPrimitiveType;
      const AIndices: TArray<UInt16>; const AFirst: Integer = 0;
      const ACount: Integer = 0); overload; inline; static;

    { Render primitives from array data, using indices from a bound index
      buffer.

      Parameters:
        AType: specifies what kind of primitives to render.
        ACount: the number of indices used to render.
        AIndexType: the type of the indices in the bound index buffer. Only
          8-bit (UnsignedByte) and 16-bit (UnsignedShort) indices are supported.

      DrawElements specifies multiple geometric primitives with very few
      subroutine calls. Instead of calling a GL function to pass each vertex
      attribute, you can use TGLVertexAttrib to prespecify separate arrays of
      vertex attributes and use them to construct a sequence of primitives
      with a single call to DrawElements.

      AType specifies what kind of primitives are constructed and how the array
      elements construct these primitives. If more than one array is enabled,
      each is used.

      To enable and disable a generic vertex attribute array, call
      TGLVertexAttrib.Enable and TGLVertexAttrib.Disable.

      @bold(Note): if the current program object, as set by TGLProgram.Use, is
      invalid, rendering results are undefined. However, no error is generated
      for this case.

      Raises:
        TGLError.InvalidFramebufferOperation if the currently bound
          framebuffer is not framebuffer complete.

      @bold(OpenGL API): glDrawElements

      SeeAlso:
        TGLFramebuffer.Status, TGLVertexAttrib, TGLVertexAttrib.Enable,
        TGLVertexAttrib.Disable, DrawArrays, TGLProgram.Use }
    class procedure DrawElements(const AType: TGLPrimitiveType;
      const ACount: Integer; const AIndexType: TGLIndexType); overload; inline; static;
  public
    (* Rasterization *)

    { Specify whether front- or back-facing polygons can be culled.

      Parameters:
        AMode: whether front- or back-facing polygons are candidates for
          culling.

      This method specifies whether front- or back-facing polygons are culled
      (as specified by AMode) when polygon culling is enabled. Polygon culling
      is initially disabled. To enable and disable polygon culling, call the
      gl.Enable and gl.Disable methods with the argument TGLCapability.CullFace.

      gl.FrontFace specifies which of the clockwise and counterclockwise
      polygons are front-facing and back-facing.

      @bold(Note): if mode is TGLFace.FrontAndBack, no polygons are drawn,
      but other primitives such as points and lines are drawn.

      @bold(OpenGL API): glCullFace

      SeeAlso:
        GetCullFace, Enable, Disable, IsEnabled, FrontFace. }
    class procedure CullFace(const AMode: TGLFace); inline; static;

    { Gets the current cull face mode.

      Returns:
        The current cull face mode.

      @bold(OpenGL API): glGetIntegerv(GL_CULL_FACE_MODE)

      SeeAlso:
        CullFace }
    class function GetCullFace: TGLFace; inline; static;

    { Define front- and back-facing polygons.

      Parameters:
        AOrientation: the orientation of front-facing polygons. Initial value
         is TGLFaceOrientation.CounterClockwise.

      In a scene composed entirely of opaque closed surfaces, back-facing
      polygons are never visible. Eliminating these invisible polygons has the
      obvious benefit of speeding up the rendering of the image. To enable and
      disable elimination of back-facing polygons, call gl.Enable and gl.Disable
      with argument TGLCapability.CullFace.

      The projection of a polygon to window coordinates is said to have
      clockwise winding if an imaginary object following the path from its first
      vertex, its second vertex, and so on, to its last vertex, and finally back
      to its first vertex, moves in a clockwise direction about the interior of
      the polygon. The polygon's winding is said to be counterclockwise if the
      imaginary object following the same path moves in a counterclockwise
      direction about the interior of the polygon. glFrontFace specifies whether
      polygons with clockwise winding in window coordinates, or counterclockwise
      winding in window coordinates, are taken to be front-facing. Passing
      TGLFaceOrientation.CounterClockwise selects counterclockwise polygons as
      front-facing; TGLFaceOrientation.Clockwise selects clockwise polygons as
      front-facing. By default, counterclockwise polygons are taken to be
      front-facing.

      @bold(OpenGL API): glFrontFace

      SeeAlso:
        GetFrontFace, Enable, Disable, IsEnabled, CullFace. }
    class procedure FrontFace(const AOrientation: TGLFaceOrientation); inline; static;

    { Gets the current front face orientation.

      Returns:
        The current front face orientation.

      @bold(OpenGL API): glGetIntegerv(GL_FRONT_FACE)

      SeeAlso:
        FrontFace }
    class function GetFrontFace: TGLFaceOrientation; inline; static;

    { Specify the width of rasterized lines.

      Parameters:
        AWidth: the width of rasterized lines. The initial value is 1.

      Raises:
        TGLError.InvalidValue if AWidth is less than or equal to 0.

      The actual width is determined by rounding the supplied width to the
      nearest integer. (If the rounding results in the value 0, it is as if the
      line width were 1.)

      There is a range of supported line widths. Only width 1 is guaranteed to
      be supported; others depend on the implementation. To query the range of
      supported widths, call GetAliasedLineWidthRange.

      @bold(Note): the line width specified by LineWidth is always returned when
      GetLineWidth is queried. Clamping and rounding have no effect on the
      specified value.

      @bold(OpenGL API): glLineWidth

      SeeAlso:
        GetLineWidth, GetAliasedLineWidthRange, Enable }
    class procedure LineWidth(const AWidth: Single); inline; static;

    { Get the current line width.

      Returns:
        The current line width.

      @bold(OpenGL API): glGetFloatv(GL_LINE_WIDTH)

      SeeAlso:
        LineWidth }
    class function GetLineWidth: Single; inline; static;

    { Set the scale and units used to calculate polygon depth values.

      Parameters:
        AFactor: a scale factor that is used to create a variable depth offset
          for each polygon. The initial value is 0.
        AUnits: is multiplied by an implementation-specific value to create a
          constant depth offset. The initial value is 0.

      When TGLCapability.PolygonOffsetFill is enabled, each fragment's depth
      value will be offset after it is interpolated from the depth values of the
      appropriate vertices. The value of the offset is (AFactor × DZ) +
      (r × AUnits), where DZ is a measurement of the change in depth relative to
      the screen area of the polygon, and r is the smallest value that is
      guaranteed to produce a resolvable offset for a given implementation. The
      offset is added before the depth test is performed and before the value is
      written into the depth buffer.

      PolygonOffset is useful for rendering hidden-line images, for applying
      decals to surfaces, and for rendering solids with highlighted edges.

      @bold(OpenGL API): glPolygonOffset

      SeeAlso:
        Enable, Disable, IsEnabled, DepthFunc, GetPolygonOffsetFactor,
        GetPolygonOffsetUnits }
    class procedure PolygonOffset(const AFactor, AUnits: Single); inline; static;

    { Gets the current polygon offset factor.

      Returns:
        The polygon offset factor.

      @bold(OpenGL API): glGetFloatv(GL_POLYGON_OFFSET_FACTOR)

      SeeAlso:
        PolygonOffset, GetPolygonOffsetUnits }
    class function GetPolygonOffsetFactor: Single; inline; static;

    { Gets the current polygon offset units.

      Returns:
        The polygon offset units.

      @bold(OpenGL API): glGetFloatv(GL_POLYGON_OFFSET_UNITS)

      SeeAlso:
        PolygonOffset, GetPolygonOffsetFactor }
    class function GetPolygonOffsetUnits: Single; inline; static;

    { Set pixel storage alignment.

      Parameters:
        AMode: the mode to set.
        AValue: the alignment value to set for the mode.

      This method sets pixel storage modes that affect the operation of
      subsequent TGLFramebuffer.ReadPixels as well as the unpacking of texture
      patterns (see TGLTexture.Upload and TGLTexture.SubUpload).

      The PackAlignment mode affects how pixel data is downloaded from the GPU
      into client memory. The UnpackAlignment mode affects how pixel data is
      uploaded from client memory to the GPU.

      @bold(OpenGL API): glPixelStorei

      SeeAlso:
        TGLFramebuffer.ReadPixels, TGLTexture.Upload, TGLTexture.SubUpload,
        GetPixelStore }
    class procedure PixelStore(const AMode: TGLPixelStoreMode;
      const AValue: TGLPixelStoreValue); inline; static;

    { Returns to current pixel storage alignment.

      Parameters:
        AMode: the mode for which to return the storage value.

      Returns:
        The storage alignment for the given node.

      @bold(OpenGL API): glGetIntegerv(GL_PACK_ALIGNMENT/GL_UNPACK_ALIGNMENT)

      SeeAlso:
        PixelStore }
    class function GetPixelStore(const AMode: TGLPixelStoreMode): TGLPixelStoreValue; inline; static;

    { Gets the smallest and largest supported widths for aliased lines.

      Parameters:
        AMin: is set to the smallest supported line width.
        AMax: is set to the largest supported line width.

      The returned range always includes value 1.0.

      @bold(OpenGL API): glGetIntegerv(GL_ALIASED_LINE_WIDTH_RANGE)

      SeeAlso:
        LineWidth, GetLineWidth }
    class procedure GetAliasedLineWidthRange(out AMin, AMax: Single); inline; static;

    { Gets the smallest and largest supported sizes for aliased points.

      Parameters:
        AMin: is set to the smallest supported point size.
        AMax: is set to the largest supported point size.

      The returned range always includes value 1.0.

      @bold(OpenGL API): glGetIntegerv(GL_ALIASED_POINT_SIZE_RANGE) }
    class procedure GetAliasedPointSizeRange(out AMin, AMax: Single); inline; static;
  public
    (* State *)

    { Enable a server-side GL capability.

      Parameters:
        ACapability: the GL capability to enable.

      Use IsEnabled to determine the current setting of any capability. The
      initial value for each capability with the exception of
      TGLCapability.Dither is False. The initial value for TGLCapability.Dither
      is True.

      @bold(OpenGL API): glEnable

      SeeAlso:
        IsEnabled, TGLTexture.BindToTextureUnit, BlendFunc, CullFace, DepthFunc,
        DepthRange, LineWidth, PolygonOffset, Scissor, StencilFunc, StencilOp,
        TGLTexture  }
    class procedure Enable(const ACapability: TGLCapability); inline; static;

    { Disable a server-side GL capability.

      Parameters:
        ACapability: the GL capability to disable.

      Use IsEnabled to determine the current setting of any capability. The
      initial value for each capability with the exception of
      TGLCapability.Dither is False. The initial value for TGLCapability.Dither
      is True.

      @bold(OpenGL API): glDisable

      SeeAlso:
        IsEnabled, TGLTexture.BindToTextureUnit, BlendFunc, CullFace, DepthFunc,
        DepthRange, LineWidth, PolygonOffset, Scissor, StencilFunc, StencilOp,
        TGLTexture  }
    class procedure Disable(const ACapability: TGLCapability); inline; static;

    { Checks if a server-side GL capability is enabled.

      Parameters:
        ACapability: the GL capability to check.

      Returns:
        True if ACapability is currently enabled. False otherwise.

      @bold(OpenGL API): glIsEnabled

      SeeAlso:
        Enable, Disable }
    class function IsEnabled(const ACapability: TGLCapability): Boolean; inline; static;
  public
    (* Special Functions *)

    { Block until all GL execution is complete.

      This method does not return until the effects of all previously called GL
      commands are complete. Such effects include all changes to GL state, all
      changes to connection state, and all changes to the frame buffer contents.

      @bold(Note): Finish requires a round trip to the server.

      @bold(OpenGL API): glFinish

      SeeAlso:
        Flush }
    class procedure Finish; inline; static;

    { Force execution of GL commands in finite time.

      Different GL implementations buffer commands in several different
      locations, including network buffers and the graphics accelerator itself.
      This method empties all of these buffers, causing all issued commands to
      be executed as quickly as they are accepted by the actual rendering
      engine. Though this execution may not be completed in any particular time
      period, it does complete in finite time.

      Because any GL program might be executed over a network, or on an
      accelerator that buffers commands, all programs should call Flush whenever
      they count on having all of their previously issued commands completed.
      For example, call Flush before waiting for user input that depends on the
      generated image.

      @bold(Note): Flush can return at any time. It does not wait until the
      execution of all previously issued GL commands is complete.

      @bold(OpenGL API): glFlush

      SeeAlso:
        Finish }
    class procedure Flush; inline; static;
  public
    (* Information Functions *)

    { Get an estimate of the number of bits of subpixel resolution that are used
      to position rasterized geometry in window coordinates. The value must be
      at least 4.

      @bold(OpenGL API): glGetIntegerv(GL_SUBPIXEL_BITS) }
    class function GetSubpixelBits: Integer; inline; static;

    { Get the company responsible for this GL implementation. This name does not
      change from release to release.

      Because the GL does not include queries for the performance
      characteristics of an implementation, some applications are written to
      recognize known platforms and modify their GL usage based on known
      performance characteristics of these platforms. GetVendor and GetRenderer
      together uniquely specify a platform. They do not change from release to
      release and should be used by platform-recognition algorithms.

      @bold(OpenGL API): glGetString(GL_VENDOR)

      SeeAlso:
        GetRenderer }
    class function GetVendor: RawByteString; inline; static;

    { Get the name of the renderer. This name is typically specific to a
      particular configuration of a hardware platform. It does not change from
      release to release.

      Because the GL does not include queries for the performance
      characteristics of an implementation, some applications are written to
      recognize known platforms and modify their GL usage based on known
      performance characteristics of these platforms. GetVendor and GetRenderer
      together uniquely specify a platform. They do not change from release to
      release and should be used by platform-recognition algorithms.

      @bold(OpenGL API): glGetString(GL_RENDERER)

      SeeAlso:
        GetVendor }
    class function GetRenderer: RawByteString; inline; static;

    { Get a version or release number of the form
      OpenGL<space>ES<space><version number><space><vendor-specific information>.

      @bold(OpenGL API): glGetString(GL_VERSION) }
    class function GetVersion: RawByteString; inline; static;

    { Get a version or release number for the shading language of the form
      OpenGL<space>ES<space>GLSL<space>ES<space><version number><space><vendor-specific information>.

      @bold(OpenGL API): glGetString(GL_SHADING_LANGUAGE_VERSION) }
    class function GetShadingLanguageVersion: RawByteString; inline; static;

    { Get a space-separated list of supported extensions to GL.

      Some applications want to make use of features that are not part of the
      standard GL. These features may be implemented as extensions to the
      standard GL. This method returns a space-separated list of supported GL
      extensions. (Extension names never contain a space character.)

      @bold(OpenGL API): glGetString(GL_EXTENSIONS) }
    class function GetExtensions: RawByteString; inline; static;
  end;

type
  { A vertex or fragment shader }
  TGLShader = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: GLuint;
  private
    {$IFDEF DESKTOP_OPENGL}
    class function GlslEsToGlsl(const ASource: RawByteString): RawByteString; static;
    {$ENDIF}
  {$REGION 'Internal Declarations'}
  public
    { Creates a shader object.

      Parameters:
        AType: the type of shader to be created.
        ASource: (optional) GLSL-ES source code for the shader. When specified,
          SetSource will be called.

      A shader object is used to maintain the source code that define a shader.

      AType indicates the type of shader to be created. Two types of shaders are
      supported. A shader of type TGLShaderType.Vertex is a shader that is
      intended to run on the programmable vertex processor. A shader of type
      TGLShaderType.Fragment is a shader that is intended to run on the
      programmable fragment processor.

      @bold(Note): like texture objects, the name space for shader objects may
      be shared across a set of contexts, as long as the server sides of the
      contexts share the same address space. If the name space is shared across
      contexts, any attached objects and the data associated with those attached
      objects are shared as well.

      @bold(Note): applications are responsible for providing the
      synchronization across API calls when objects are accessed from different
      execution threads.

      @bold(OpenGL API): glCreateShader

      SeeAlso:
        SetSource, GetSource, TGLProgram.AttachShader, TGLProgram.DetachShader,
        Compile, Delete }
    procedure New(const AType: TGLShaderType); overload; inline;
    procedure New(const AType: TGLShaderType; const ASource: RawByteString); overload; inline;

    { Deletes the shader. This frees the memory and invalidates the name
      associated with the shader object specified by shader. This command
      effectively undoes the effects of a call to New.

      If a shader object to be deleted is attached to a program object, it will
      be flagged for deletion, but it will not be deleted until it is no longer
      attached to any program object, for any rendering context (i.e., it must
      be detached from wherever it was attached before it will be deleted).

      To determine whether an object has been flagged for deletion, call
      IsFlaggedForDeletion.

      @bold(OpenGL API): glDeleteShader

      SeeAlso:
        New, TGLProgram.New, TGLProgram.DetachShader, TGLProgram.Use }
    procedure Delete; inline;

    { Set or replace the source code in a shader object.

      Parameters:
        ASource: the GLSL-ES source code of the shader.

      Any source code previously stored in the shader object is completely
      replaced.

      Raises:
        TGLError.InvalidOperation if a shader compiler is not supported.

      @bold(Note): when used with Desktop OpenGL, the source code may be
      modified to make it compatible with Desktop GLSL.

      @bold(OpenGL API): glShaderSource

      SeeAlso:
        GetSource, Compile, New, Delete }
    procedure SetSource(const ASource: RawByteString); inline;

    { Get the source code string from a shader object.

      Returns:
        The shader source code.

      @bold(OpenGL API): glGetShaderSource

      SeeAlso:
        SetSource, New }
    function GetSource: RawByteString; inline;

    { Compiles the shader;

      Returns:
        In RELEASE mode: True on success, False on failure.
        In DEBUG mode: True on success or an EGLError exception will be raised
          on failure.

      Raises:
        TGLError.InvalidOperation if a shader compiler is not supported.
        EGLShaderError when the source code contains errors and cannot be
          compiled.

      @bold(Note): in DEBUG mode, any compiler warnings will be output to the
      debug console.

      @bold(OpenGL API): glCompileShader, glGetShaderInfoLog,
        glGetShaderiv(GL_COMPILE_STATUS/GL_INFO_LOG_LENGTH)

      SeeAlso:
        New, TGLProgram.Link, SetSource, TGLShader.ReleaseCompiler. }
    function Compile: Boolean;

    { Gets the type of the shader.

      Returns:
        The shader type.

      @bold(OpenGL API): glGetShaderiv(GL_SHADER_TYPE)

      SeeAlso:
        New, Delete }
    function GetType: TGLShaderType; inline;

    { Get the delete status.

      Returns:
        True if the shader is currently flagged for deletion. False otherwise.

      @bold(OpenGL API): glGetShaderiv(GL_DELETE_STATUS)

      SeeAlso:
        New, Delete, Compile, SetSource }
    function GetDeleteStatus: Boolean; inline;

    { Get the compile status.

      Returns:
        True if the last compile operation was successful. False otherwise.

      @bold(OpenGL API): glGetShaderiv(GL_COMPILE_STATUS)

      SeeAlso:
        New, Delete, Compile, SetSource }
    function GetCompileStatus: Boolean; inline;

    { Get the maximum number four-element floating-point vectors available for
      interpolating varying variables used by vertex and fragment shaders.
      Varying variables declared as matrices or arrays will consume multiple
      interpolators. The value must be at least 8.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_VARYING_VECTORS) }
    class function GetMaxVaryingVectors: Integer; inline; static;

    { Get the maximum number of 4-component generic vertex attributes accessible
      to a vertex shader. The value must be at least 8.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_VERTEX_ATTRIBS) }
    class function GetMaxVertexAttribs: Integer; inline; static;

    { Release resources allocated by the shader compiler.

      For implementations that support a shader compiler, this method frees
      resources allocated by the shader compiler. This is a hint from the
      application that additional shader compilations are unlikely to occur, at
      least for some period of time, and that the resources consumed by the
      shader compiler may be released and put to better use elsewhere.

      However, if a call to Compile is made after a call to ReleaseCompiler, the
      shader compiler must be restored to service the compilation request as if
      ReleaseCompiler had never been called.

      @bold(OpenGL API): glReleaseShaderCompiler

      SeeAlso:
        Compile }
    class procedure ReleaseCompiler; inline; static;

    { OpenGL handle to the shader object. }
    property Handle: GLuint read FHandle;
  end;

type
  { A program that combines a vertex shader and a fragment shader. }
  TGLProgram = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: GLuint;
  {$REGION 'Internal Declarations'}
  public
    { Creates a program object.

      Parameters:
        AVertexShader: (optional) vertex shader to attach.
        AFragmentShader: (optional) fragment shader to attach.

      A program object is an object to which shader objects can be attached.
      This provides a mechanism to specify the shader objects that will be
      linked to create a program. It also provides a means for checking the
      compatibility of the shaders that will be used to create a program (for
      instance, checking the compatibility between a vertex shader and a
      fragment shader). When no longer needed as part of a program object,
      shader objects can be detached.

      One or more executables are created in a program object by successfully
      attaching shader objects to it with AttachShader, successfully compiling
      the shader objects with TGLShader.Compile, and successfully linking the
      program object with Link. These executables are made part of current state
      when Use is called. Program objects can be deleted by calling Delete. The
      memory associated with the program object will be deleted when it is no
      longer part of current rendering state for any context.

      @bold(Note): like texture objects, the name space for program objects may
      be shared across a set of contexts, as long as the server sides of the
      contexts share the same address space. If the name space is shared across
      contexts, any attached objects and the data associated with those attached
      objects are shared as well.

      @bold(Note): applications are responsible for providing the
      synchronization across API calls when objects are accessed from different
      execution threads.

      @bold(OpenGL API): glCreateProgram

      SeeAlso:
        TGLShader, TGLVertexAttrib, TGLUniform, AttachShader, DetachShader,
        Link, Use, Validate }
    procedure New; overload; inline;
    procedure New(const AVertexShader, AFragmentShader: TGLShader); overload; inline;

    { Deletes the program. This frees the memory and invalidates the name
      associated with the program object specified by program. This command
      effectively undoes the effects of a call to New.

      If a program object is in use as part of current rendering state, it will
      be flagged for deletion, but it will not be deleted until it is no longer
      part of current state for any rendering context. If a program object to be
      deleted has shader objects attached to it, those shader objects will be
      automatically detached but not deleted unless they have already been
      flagged for deletion by a previous call to TGLShader.Delete.

      To determine whether a program object has been flagged for deletion, call
      IsFlaggedForDeletion.

      @bold(OpenGL API): glDeleteProgram

      SeeAlso:
        New, DetachShader, Use }
    procedure Delete; inline;

    { Attach a shader object to the program.

      Parameters:
        AShader: the shader object to be attached.

      Raises:
        TGLError.InvalidOperation if AShader is already attached to the program,
        or if another shader object of the same type as shader is already
        attached to the program.

      In order to create an executable, there must be a way to specify the list
      of things that will be linked together. Program objects provide this
      mechanism. Shaders that are to be linked together in a program object must
      first be attached to that program object. This method attaches the shader
      object specified by AShader to the program. This indicates that shader
      will be included in link operations that will be performed on program.

      All operations that can be performed on a shader object are valid whether
      or not the shader object is attached to a program object. It is
      permissible to attach a shader object to a program object before source
      code has been loaded into the shader object or before the shader object
      has been compiled. Multiple shader objects of the same type may not be
      attached to a single program object. However, a single shader object may
      be attached to more than one program object. If a shader object is deleted
      while it is attached to a program object, it will be flagged for deletion,
      and deletion will not occur until DetachShader is called to detach it from
      all program objects to which it is attached.

      @bold(OpenGL API): glAttachShader

      SeeAlso:
        GetAttachedShaders, TGLShader.Compile, DetachShader, Link,
        TGLShader.SetSource }
    procedure AttachShader(const AShader: TGLShader); inline;

    { Attaches a vertex shader and fragment shader in a single call.

      Parameters:
        AVertexShader: the vertex shader to attach.
        AFragmentShader: the fragment shader to attach.

      This method is just a shortcut for calling AttachShader twice. }
    procedure AttachShaders(const AVertexShader, AFragmentShader: TGLShader); inline;

    { Detach a shader object from a program object.

      Parameters:
        AShader: the shader object to be dettached.

      Raises:
        TGLError.InvalidOperation if AShader is not attached to this program.

      This command can be used to undo the effect of the command AttachShader.

      If shader has already been flagged for deletion by a call to
      TGLShader.Delete and it is not attached to any other program object, it
      will be deleted after it has been detached.

      @bold(OpenGL API): glDetachShader

      SeeAlso:
        GetAttachedShaders, AttachShader }
    procedure DetachShader(const AShader: TGLShader); inline;

    { Return the shader objects attached to the program.

      Returns:
        An array of attached shaders.

      @bold(OpenGL API): glGetAttachedShaders

      SeeAlso:
        AttachShader, DetachShader }
    function GetAttachedShaders: TArray<TGLShader>; inline;

    { Links the program.

      Returns:
        In RELEASE mode: True on success, False on failure.
        In DEBUG mode: True on success or an EGLError exception will be raised
          on failure.

      Raises:
        EGLShaderError when the shaders cannot be linked.

      A shader object of type TGLShaderType.Vertex attached to program is used
      to create an executable that will run on the programmable vertex
      processor. A shader object of type TGLShaderType.Fragment attached to
      program is used to create an executable that will run on the programmable
      fragment processor.

      As a result of a successful link operation, all active user-defined
      uniform variables belonging to program will be initialized to 0, and each
      of the program object's active uniform variables can be accessed using
      TGLUniform. Also, any active user-defined attribute variables that have
      not been bound to a generic vertex attribute index will be bound to one at
      this time.

      Linking of a program object can fail for a number of reasons as specified
      in the OpenGL ES Shading Language Specification. This will result in a
      EGLShaderError exception (in DEBUG mode). The following lists some of the
      conditions that will cause a link error.
      * A vertex shader and a fragment shader are not both present in the
        program object.
      * The number of active attribute variables supported by the implementation
        has been exceeded.
      * The storage limit for uniform variables has been exceeded.
      * The number of active uniform variables supported by the implementation
        has been exceeded.
      * The main function is missing for the vertex shader or the fragment
        shader.
      * A varying variable actually used in the fragment shader is not declared
        in the same way (or is not declared at all) in the vertex shader.
      * A reference to a function or variable name is unresolved.
      * A shared global is declared with two different types or two different
        initial values.
      * One or more of the attached shader objects has not been successfully
        compiled (via TGLShader.Compile).
      * Binding a generic attribute matrix caused some rows of the matrix to
        fall outside the allowed maximum number of vertex attributes.
      * Not enough contiguous vertex attribute slots could be found to bind
        attribute matrices.

      When a program object has been successfully linked, the program object can
      be made part of current state by calling Use.

      This method will also install the generated executables as part of the
      current rendering state if the link operation was successful and the
      specified program object is already currently in use as a result of a
      previous call to Use. If the program object currently in use is relinked
      unsuccessfully, its link status will be set to False, but the executables
      and associated state will remain part of the current state until a
      subsequent call to Use removes it from use. After it is removed from use,
      it cannot be made part of current state until it has been successfully
      relinked.

      After the link operation, applications are free to modify attached shader
      objects, compile attached shader objects, detach shader objects, delete
      shader objects, and attach additional shader objects. None of these
      operations affects the information log or the program that is part of the
      program object.

      @bold(Note): if the link operation is unsuccessful, any information about
      a previous link operation on program is lost (i.e., a failed link does not
      restore the old state of program). Certain information can still be
      retrieved from program even after an unsuccessful link operation.

      @bold(OpenGL API): glLinkProgram, glGetProgramInfoLog,
        glGetProgramiv(GL_LINK_STATUS/GL_INFO_LOG_LENGTH)

      SeeAlso:
        TGLVertexAttrib, TGLUniform, GetAttachedShaders, AttachShader,
        TGLShader.Compile, New, Delete, DetachShader, Use, Validate }
    function Link: Boolean;

    { Validates the program.

      Returns:
        In RELEASE mode: True on success, False on failure.
        In DEBUG mode: True on success or an EGLError exception will be raised
          on failure.

      Raises:
        EGLShaderError with any validation errors.

      This method checks to see whether the executables contained in program can
      execute given the current OpenGL state. The validation information
      (exception message) may consist of an empty string, or it may be a string
      containing information about how the current program object interacts with
      the rest of current OpenGL state. This provides a way for OpenGL
      implementers to convey more information about why the current program is
      inefficient, suboptimal, failing to execute, and so on.

      If validation is successful, the program is guaranteed to execute given
      the current state. Otherwise, the program is guaranteed to not execute.

      This function is typically useful only during application development. The
      informational string stored in the exception message is completely
      implementation dependent; therefore, an application should not expect
      different OpenGL implementations to produce identical information strings.

      @bold(Note): this function mimics the validation operation that OpenGL
      implementations must perform when rendering commands are issued while
      programmable shaders are part of current state. The error
      TGLError.InvalidOperation will be generated by gl.DrawArrays or
      gl.DrawElements if any two active samplers in the current program object
      are of different types, but refer to the same texture image unit.

      @bold(Note): it may be difficult or cause a performance degradation for
      applications to catch these errors when rendering commands are issued.
      Therefore, applications are advised to make calls to Validate to detect
      these issues during application development.

      @bold(OpenGL API): glValidateProgram, glGetProgramInfoLog,
        glGetProgramiv(GL_VALIDATE_STATUS/GL_INFO_LOG_LENGTH)

      SeeAlso:
        Link, Use}
    function Validate: Boolean;

    { Installs the program object as part of current rendering state.

      Raises:
        TGLError.InvalidOperation if the program could not be made part of the
          current state.

      Executables for each stage are created in a program object by successfully
      attaching shader objects to it with AttachShader, successfully compiling
      the shader objects with Compile, and successfully linking the program
      object with Link.

      A program object will contain executables that will run on the vertex and
      fragment processors if it contains one shader object of type
      TGLShaderType.Vertex and one shader object of type TGLShaderType.Fragment
      that have both been successfully compiled and linked.

      While a program object is in use, applications are free to modify attached
      shader objects, compile attached shader objects, attach shader objects,
      and detach or delete shader objects. None of these operations will affect
      the executables that are part of the current state. However, relinking the
      program object that is currently in use will install the program object as
      part of the current rendering state if the link operation was successful
      (see Link). If the program object currently in use is relinked
      unsuccessfully, its link status will be set to False, but the executables
      and associated state will remain part of the current state until a
      subsequent call to Use removes it from use. After it is removed from use,
      it cannot be made part of current state until it has been successfully
      relinked.

      @bold(Note): like texture objects and buffer objects, the name space for
      program objects may be shared across a set of contexts, as long as the
      server sides of the contexts share the same address space. If the name
      space is shared across contexts, any attached objects and the data
      associated with those attached objects are shared as well.

      @bold(Note): applications are responsible for providing the
      synchronization across API calls when objects are accessed from different
      execution threads.

      @bold(OpenGL API): glUseProgram

      SeeAlso:
        TGLVertexAttrib, TGLUniform, GetAttachedShaders, AttachShader,
        TGLShader.Compile, New, Delete, DetachShader, Link, Validate }
    procedure Use; inline;

    { Return information about an active attribute variable.

      Parameters:
        AIndex: the index of the attribute variable to be queried.

      Returns:
        Information about attribute at the given index.

      Raises:
        TGLError.InvalidValue if AIndex is greater than or equal to the number
        of active attribute variables in program.

      This method returns information about an active attribute variable in the
      program object specified by program. The number of active attributes can
      be obtained by calling GetActiveAttributes. A value of 0 for AIndex
      selects the first active attribute variable. Permissible values for AIndex
      range from 0 to the number of active attribute variables minus 1.

      Attribute variables have arbitrary names and obtain their values through
      numbered generic vertex attributes. An attribute variable is considered
      active if it is determined during the link operation that it may be
      accessed during program execution. Therefore, the program should have
      previously been linked by calling Link, but it is not necessary for it to
      have been linked successfully.

      This method will return as much information as it can about the specified
      active attribute variable. If no information is available, the returned
      name will be an empty string. This situation could occur if this function
      is called after a link operation that failed.

      @bold(OpenGL API): glGetActiveAttrib

      SeeAlso:
        GetActiveAttributes, TGLShader.GetMaxVertexAttribs, TGLVertexAttrib.Bind,
        GetUniformInfo, TGLProgram.Link, TGLVertexAttrib.SetValue,
        TGLVertexAttrib.SetConfig, TGLVertexAttrib.SetData }
    function GetAttributeInfo(const AIndex: Integer): TGLAttrInfo; inline;

    { Return information about an active uniform variable.

      Parameters:
        AIndex: the index of the uniform variable to be queried.

      Returns:
        Information about uniform at the given index.

      Raises:
        TGLError.InvalidValue if AIndex is greater than or equal to the number
          of active uniforms in the program.

      The number of active uniform variables can be obtained by calling
      GetActiveUniforms. A value of 0 for index selects the first active uniform
      variable. Permissible values for index range from 0 to the number of
      active uniform variables minus 1.

      Shaders may use either built-in uniform variables, user-defined uniform
      variables, or both. Built-in uniform variables have a prefix of "gl_" and
      reference existing OpenGL state or values derived from such state (e.g.,
      gl_DepthRange). User-defined uniform variables have arbitrary names and
      obtain their values from the application through calls to
      TGLUniform.SetValue. A uniform variable (either built-in or user-defined)
      is considered active if it is determined during the link operation that it
      may be accessed during program execution. Therefore, program should have
      previously been linked by calling Link, but it is not necessary for it to
      have been linked successfully.

      Only one active uniform variable will be reported for a uniform array.

      Uniform variables that are declared as structures or arrays of structures
      will not be returned directly by this function. Instead, each of these
      uniform variables will be reduced to its fundamental components containing
      the "." and "[]" operators such that each of the names is valid as an
      argument to TGLUniform.Init. Each of these reduced uniform variables is
      counted as one active uniform variable and is assigned an index. A valid
      name cannot be a structure, an array of structures, or a subcomponent of a
      vector or matrix.

      Uniform variables other than arrays will have a Size of 1. Structures and
      arrays of structures will be reduced as described earlier, such that each
      of the names returned will be a data type in the earlier list. If this
      reduction results in an array, the size returned will be as described for
      uniform arrays; otherwise, the size returned will be 1.

      The list of active uniform variables may include both built-in uniform
      variables (which begin with the prefix "gl_") as well as user-defined
      uniform variable names.

      This function will return as much information as it can about the
      specified active uniform variable. If no information is available, the
      returned name will be an empty string. This situation could occur if this
      function is called after a link operation that failed.

      @bold(OpenGL API): glGetActiveUniform

      SeeAlso:
        TGLUniform.GetMaxVertexUniformVectors,
        TGLUniform.GetMaxFragmentUniformVectors, GetActiveUniforms,
        GetAttributeInfo, TGLUniform.GetValue, TGLUniform.Init, Link,
        TGLUniform.SetValue, Use }
    function GetUniformInfo(const AIndex: Integer): TGLUniformInfo; inline;

    { Get the delete status.

      Returns:
        True if the program is currently flagged for deletion. False otherwise.

      @bold(OpenGL API): glGetProgramiv(GL_DELETE_STATUS)

      SeeAlso:
        AttachShader, New, Delete, Link, Validate, GetLinkStatus,
        GetValidateStatus, GetAttachedShaders, GetActiveAttributes,
        GetActiveUniforms }
    function GetDeleteStatus: Boolean; inline;

    { Get the link status.

      Returns:
        True if the last link operation was successful. False otherwise.

      @bold(OpenGL API): glGetProgramiv(GL_LINK_STATUS)

      SeeAlso:
        AttachShader, New, Delete, Link, Validate, GetDeleteStatus,
        GetValidateStatus, GetAttachedShaders, GetActiveAttributes,
        GetActiveUniforms }
    function GetLinkStatus: Boolean; inline;

    { Get the validate status.

      Returns:
        True if the last validate operation was successful. False otherwise.

      @bold(OpenGL API): glGetProgramiv(GL_VALIDATE_STATUS)

      SeeAlso:
        AttachShader, New, Delete, Link, Validate, GetDeleteStatus,
        GetLinkStatus, GetAttachedShaders, GetActiveAttributes,
        GetActiveUniforms }
    function GetValidateStatus: Boolean; inline;

    { Get the number of active attribute variables in the program.

      Returns:
        The number of active attributes.

      @bold(OpenGL API): glGetProgramiv(GL_ACTIVE_ATTRIBUTES)

      SeeAlso:
        AttachShader, New, Delete, Link, Validate, GetDeleteStatus,
        GetLinkStatus, GetValidateStatus, GetAttachedShaders,
        GetActiveUniforms }
    function GetActiveAttributes: Integer; inline;

    { Get the number of active uniform variables in the program.

      Returns:
        The number of active uniforms.

      @bold(OpenGL API): glGetProgramiv(GL_ACTIVE_UNIFORMS)

      SeeAlso:
        AttachShader, New, Delete, Link, Validate, GetDeleteStatus,
        GetLinkStatus, GetValidateStatus, GetAttachedShaders,
        GetActiveAttributes }
    function GetActiveUniforms: Integer; inline;

    { Get the program that is currently active.

      Returns:
        The currently active program. Its Handle will be 0 if there is no
        program active.

      @bold(OpenGL API): glGetProgramiv(GL_CURRENT_PROGRAM)

      SeeAlso:
        Use }
    class function GetCurrent: TGLProgram; inline; static;

    { OpenGL handle to the program object. }
    property Handle: GLuint read FHandle;
  end;

type
  { A (vertex) array buffer or element array (index) buffer }
  TGLBuffer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: GLuint;
    FType: GLenum;
  {$REGION 'Internal Declarations'}
  public
    { Creates a buffer.

      Parameters:
        AType: the type of buffer to create.

      No buffer objects are associated with the buffer until they are first
      bound by calling Bind.

      @bold(OpenGL API): glGenBuffers

      SeeAlso:
        Bind, Delete }
    procedure New(const AType: TGLBufferType); inline;

    { Deletes the buffer.

      If a buffer object that is currently bound is deleted, the binding reverts
      to 0 (the absence of any buffer object, which reverts to client memory
      usage).

      @bold(OpenGL API): glDeleteBuffers

      SeeAlso:
        Bind, New }
    procedure Delete; inline;

    { Binds the buffer.

      When a buffer object is bound to a target, the previous binding for that
      target is automatically broken.

      The state of a buffer object immediately after it is first bound is a
      zero-sized memory buffer with TGLBufferUsage.StaticDraw usage.

      While a buffer object name is bound, GL operations on the target to which
      it is bound affect the bound buffer object, and queries of the target to
      which it is bound return state from the bound buffer object.

      A buffer object binding created Bind remains active until a different
      buffer object name is bound to the same target, or until the bound buffer
      object is deleted with Delete.

      Once created, a named buffer object may be re-bound to any target as often
      as needed. However, the GL implementation may make choices about how to
      optimize the storage of a buffer object based on its initial binding
      target.

      @bold(OpenGL API): glBindBuffer

      SeeAlso:
        GetCurrentArrayBuffer, GetCurrentElementArrayBuffer, New, Delete,
        Unbind, IsBound }
    procedure Bind; inline;

    { Unbinds the buffer.

      This effectively unbinds any buffer object previously bound, and restores
      client memory usage for that buffer object target.

      While the buffer is unbound, as in the initial state, attempts to modify
      or query state on the target to which it is bound generates an
      TGLError.InvalidOperation error.

      @bold(OpenGL API): glBindBuffer

      SeeAlso:
        Bind, IsBound }
    procedure Unbind; inline;

    { Checks if this buffer is currently bound.

      Returns:
        True if this is the currently bound buffer, False otherwise. }
    function IsBound: Boolean; inline;

    { Create and initialize a buffer object's data store.

      Parameters:
        AData: untyped value to copy to the buffer.
        ASize: size of the data in bytes.
        AUsage: (optional) expected usage pattern of the data store.
          Defaults to TGLBufferUsage.StaticDraw.

      There are overloaded versions of this method where AData is an array of
      values of generic type T. In that case, there is no ASize parameter.

      Raises:
        TGLError.InvalidValue if ASize is negative.
        TGLError.InvalidOperation if no buffer is bound.
        TGLError.OutOfMemory if the GL is unable to create a data store with
          the specified ASize.

      Any pre-existing data store is deleted.

      AUsage is a hint to the GL implementation as to how a buffer object's data
      store will be accessed. This enables the GL implementation to make more
      intelligent decisions that may significantly impact buffer object
      performance. It does not, however, constrain the actual usage of the data
      store.

      @bold(Note): clients must align data elements consistent with the
      requirements of the client platform, with an additional base-level
      requirement that an offset within a buffer to a datum comprising N be a
      multiple of N.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this buffer is not bound.

      @bold(OpenGL API): glBufferData

      SeeAlso:
        GetSize, GetUsage, Bind, Unbind, SubData }
    procedure Data(const AData; const ASize: NativeInt;
      const AUsage: TGLBufferUsage = TGLBufferUsage.StaticDraw); overload; inline;
    procedure Data<T: record>(const AData: array of T;
      const AUsage: TGLBufferUsage = TGLBufferUsage.StaticDraw); overload;
    procedure Data<T: record>(const AData: TArray<T>;
      const AUsage: TGLBufferUsage = TGLBufferUsage.StaticDraw); overload; inline;

    { Update a subset of a buffer object's data store.

      Parameters:
        AOffset: the offset into the buffer object's data store where data
          replacement will begin, measured in bytes.
        AData: untyped value to copy to the buffer.
        ASize: size of the data in bytes.
        AUsage: (optional) expected usage pattern of the data store.
          Defaults to TGLBufferUsage.StaticDraw.

      There are overloaded versions of this method where AData is an array of
      values of generic type T. In that case, there is no ASize parameter (but
      AOffset is still measured in bytes).

      Raises:
        TGLError.InvalidValue if AOffset or ASize is negative, or if together
          they define a region of memory that extends beyond the buffer object's
          allocated data store.
        TGLError.InvalidOperation if no buffer is bound.

      This method redefines some or all of the data store for the buffer object
      currently bound to target. Data starting at byte offset AOffset and
      extending for ASize bytes is copied to the data store from the memory
      pointed to by AData. An error is thrown if offset and size together define
      a range beyond the bounds of the buffer object's data store.

      @bold(Note): when replacing the entire data store, consider using SubData
      rather than completely recreating the data store with Data. This avoids
      the cost of reallocating the data store.

      @bold(Note): consider using multiple buffer objects to avoid stalling the
      rendering pipeline during data store updates. If any rendering in the
      pipeline makes reference to data in the buffer object being updated by
      SubData, especially from the specific region being updated, that rendering
      must drain from the pipeline before the data store can be updated.

      @bold(Note): clients must align data elements consistent with the
      requirements of the client platform, with an additional base-level
      requirement that an offset within a buffer to a datum comprising N be a
      multiple of N.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this buffer is not bound.

      @bold(OpenGL API): glBufferSubData

      SeeAlso:
        Bind, Unbind, Data }
    procedure SubData(const AOffset: NativeInt; const AData;
      const ASize: NativeInt); overload; inline;
    procedure SubData<T: record>(const AOffset: NativeInt;
      const AData: array of T); overload;
    procedure SubData<T: record>(const AOffset: NativeInt;
      const AData: TArray<T>); overload; inline;

    { Get the size of the buffer in bytes.

      Returns:
        The size of the buffer in bytes.

      Raises:
        TGLError.InvalidOperation if no buffer is bound.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this buffer is not bound.

      @bold(OpenGL API): glGetBufferParameteriv(GL_BUFFER_SIZE)

      SeeAlso:
        Bind, Data }
    function GetSize: Integer; inline;

    { Get the buffer object's usage pattern.

      Returns:
        The usage pattern.

      Raises:
        TGLError.InvalidOperation if no buffer is bound.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this buffer is not bound.

      @bold(OpenGL API): glGetBufferParameteriv(GL_BUFFER_USAGE)

      SeeAlso:
        Bind, Data }
    function GetUsage: TGLBufferUsage; inline;

    { Gets the currently bound array buffer (aka Vertex Buffer).

      Returns
        The currently bound array buffer.

      @bold(OpenGL API): glGetIntegerv(GL_ARRAY_BUFFER_BINDING)

      SeeAlso:
        GetCurrentElementArrayBuffer }
    class function GetCurrentArrayBuffer: TGLBuffer; inline; static;

    { Gets the currently bound element array buffer (aka Index Buffer).

      Returns
        The currently bound element array buffer.

      @bold(OpenGL API): glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING)

      SeeAlso:
        GetCurrentArrayBuffer }
    class function GetCurrentElementArrayBuffer: TGLBuffer; inline; static;

    { OpenGL handle to the buffer object. }
    property Handle: GLuint read FHandle;
  end;

type
  { Represents a single vertex attribute in a TGLProgram.
    These are variables marked with @code(attribute) in a vertex shader. }
  TGLVertexAttrib = record
  {$REGION 'Internal Declarations'}
  private
    FLocation: GLint;
  private
    class procedure GetTypeInfo<T: record>(out ADataType: TGLDataType;
      out ANumValuesPerVertex: Integer); static;
  {$REGION 'Internal Declarations'}
  public
    { Initializes the vertex attribute.

      Parameters:
        AProgram: the program containing the attribute.
        AAttrName: the (case-sensitive) name of the attribute as used in the
          vertex shader of the program.

      Raises:
        TGLError.InvalidOperation if AProgram is not a valid program or has
        not been successfully linked.

      Queries the previously linked program object specified by AProgram for the
      attribute variable specified by AAttrName and initializes the attribute
      with the index of the generic vertex attribute that is bound to that
      attribute variable. If AName is a matrix attribute variable, the index of
      the first column of the matrix is used.

      The association between an attribute variable name and a generic attribute
      index can be specified at any time by calling Bind. Attribute bindings do
      not go into effect until TGLProgram.Link is called. After a program object
      has been linked successfully, the index values for attribute variables
      remain fixed until the next link command occurs. The attribute values can
      only be queried after a link if the link was successful.

      This method uses the binding that actually went into effect the last time
      TGLProgram.Link was called for the specified program object. Attribute
      bindings that have been specified since the last link operation are not
      used.

      @bold(Note): in DEBUG mode, a warning will be logged to the debug console
      of AProgram does not contain an attribute named AAttrName, of AAttrName
      starts with the reserved prefix "gl_".

      @bold(OpenGL API): glGetAttribLocation

      SeeAlso:
        SetConfig, SetData, Enable, Disable, Bind }
    procedure Init(const AProgram: TGLProgram;
      const AAttrName: RawByteString); inline;

    { Initializes the vertex attribute by binding a user-defined attribute name
      to an attribute location.

      Parameters:
        AProgram: the program containing the attribute.
        ALocation: the location of the attribute to be bound
        AAttrName: the (case-sensitive) name of the vertex shader attribute to
          which ALocation is to be bound.

      Raises:
        TGLError.InvalidOperation if AProgram is not a valid program.
        TGLError.InvalidOperation if AAttrName starts with the reserved
          prefix "gl_".
        TGLError.InvalidValue is ALocation is greater than or equal to the
          maximum number of supported vertex attributes.

      This method is used to associate a user-defined attribute variable in the
      program object specified by AProgram with a generic vertex attribute
      index. The name of the user-defined attribute variable is passed in
      AAttrName. The generic vertex attribute index to be bound to this variable
      is specified by ALocation. When AProgram is made part of current state,
      values provided via the generic vertex attribute index will modify the
      value of the user-defined attribute variable specified by AAttrName.

      If AAttrName refers to a matrix attribute variable, ALocation refers to
      the first column of the matrix. Other matrix columns are then
      automatically bound to locations ALocation+1 for a matrix of type
      TMatrix2; ALocation+1 and ALocation+2 for a matrix of type TMatrix3; and
      ALocation+1, ALocation+2, and ALocation+3 for a matrix of type TMatrix4.

      This method makes it possible for vertex shaders to use descriptive names
      for attribute variables rather than generic numbered variables. The values
      sent to each generic attribute index are part of current state, just like
      standard vertex attributes such as color, normal, and vertex position. If
      a different program object is made current by calling TGLProgram.Use, the
      generic vertex attributes are tracked in such a way that the same values
      will be observed by attributes in the new program object that are also
      bound to ALocation.

      Attribute variable name-to-generic attribute index bindings for a program
      object can be explicitly assigned at any time by calling Bind. Attribute
      bindings do not go into effect until TGLProgram.Link is called. After a
      program object has been linked successfully, the index values for generic
      attributes remain fixed (and their values can be queried) until the next
      link command occurs.

      Applications are not allowed to bind any of the standard OpenGL vertex
      attributes using this command, as they are bound automatically when
      needed. Any attribute binding that occurs after the program object has
      been linked will not take effect until the next time the program object is
      linked.

      @bold(Note): Bind can be called before any vertex shader objects are bound
      to the specified program object. It is also permissible to bind a generic
      attribute index to an attribute variable name that is never used in a
      vertex shader.

      @bold(Note): if AAttrName was bound previously, that information is lost.
      Thus you cannot bind one user-defined attribute variable to multiple
      indices, but you can bind multiple user-defined attribute variables to the
      same index.

      @bold(Note): applications are allowed to bind more than one user-defined
      attribute variable to the same generic vertex attribute index. This is
      called aliasing, and it is allowed only if just one of the aliased
      attributes is active in the executable program, or if no path through the
      shader consumes more than one attribute of a set of attributes aliased to
      the same location. The compiler and linker are allowed to assume that no
      aliasing is done and are free to employ optimizations that work only in
      the absence of aliasing. OpenGL implementations are not required to do
      error checking to detect aliasing. Because there is no way to bind
      standard attributes, it is not possible to alias generic attributes with
      conventional ones (except for generic attribute 0).

      @bold(Note): active attributes that are not explicitly bound will be bound
      by the linker when TGLProgram.Link is called. The locations assigned can
      be queried by calling Init.

      @bold(OpenGL API): glBindAttribLocation

      SeeAlso:
        TGLShader.GetMaxVertexAttribs, GetSize, GetDataType, Enable, Disable,
        TGLProgram.Use, SetValue, Init }
    procedure Bind(const AProgram: TGLProgram;
      const ALocation: Cardinal; const AAttrName: RawByteString); inline;

    { Sets up the attribute for use with a TGLBuffer (of type
      TGLBufferType.Vertex). That is, this attribute will be part of a VBO
      (Vertex Buffer Object). When this attribute is @bold(not) part of a VBO,
      then you should use SetData instead.

      Parameters:
        ADataType: the data type of the each component of the vertex attribute.
          For example, an attribute of type @code(vec3) contains components
          of type TGLDataType.Float.
        ANumValuesPerVertex: the number of values (components) of the vertex
          attribute. For example, an attribute of type @code(vec3) contains 3
          values. Valid values are 1, 2, 3 and 4.
        AStride: (optional) byte offset between consecutive vertex attributes.
          If stride is 0 (the default), the generic vertex attributes are
          understood to be tightly packed in the array.
        AOffset: (optional) byte offset into the buffer object's data store.
          Defaults to 0.

      There is an overloaded version that has a type parameter T instead of the
      ADataType and ANumValuesPerVertex parameters. In that case T must be of an
      integral or floating-point type, or of type TVector2, TVector3 or
      TVector4.

      Raises:
        TGLError.InvalidValue if ANumValuesPerVertex is not 1, 2, 3 or 4.
        TGLError.InvalidValue if AStride is negative.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if no TGLBuffer of type TGLBufferType.Vertex
      is bound.

      @bold(OpenGL API): glVertexAttribPointer

      SeeAlso:
        Enable, Disable, IsEnabled, GetDataType, GetSize, IsNormalized,
        GetStride, TGLBuffer.Bind, gl.DrawArrays, gl.DrawElements, SetData }
    procedure SetConfig(const ADataType: TGLDataType;
      const ANumValuesPerVertex: Integer; const AStride: NativeInt = 0;
      const AOffset: NativeInt = 0); overload; inline;
    procedure SetConfig<T: record>(const AStride: NativeInt = 0;
      const AOffset: NativeInt = 0); overload; inline;

    { Sets up the attribute for use with client data. When this attribute is
      part of a VBO, then you should use SetConfig instead (which is more
      efficient than using client data).

      Parameters:
        ADataType: the data type of the each component of the vertex attribute.
          For example, an attribute of type @code(vec3) contains components
          of type TGLDataType.Float.
        ANumValuesPerVertex: the number of values (components) of the vertex
          attribute. For example, an attribute of type @code(vec3) contains 3
          values. Valid values are 1, 2, 3 and 4.
        AData: pointer to the client data containing the vertices.
        AStride: (optional) byte offset between consecutive vertex attributes.
          If stride is 0 (the default), the generic vertex attributes are
          understood to be tightly packed in the array.
        ANormalized: (optional) flag that specifies whether integer values will
          be normalized. If set to True, integer values are be mapped to the
          range [-1,1] (for signed values) or [0,1] (for unsigned values) when
          they are accessed and converted to floating point. Otherwise
          (default), values will be converted to floats directly without
          normalization.

      There are overloaded versions of this method where AData is an array of
      values of generic type T. In that case, there are no ADataType and
      ANumValuesPerVertex parameters, since those are implied from T. Also, T
      must be of an integral or floating-point type, or of type TVector2,
      TVector3 or TVector 4. These overloads are less efficient though.

      Raises:
        TGLError.InvalidValue if ANumValuesPerVertex is not 1, 2, 3 or 4.
        TGLError.InvalidValue if AStride is negative.

      @bold(OpenGL API): glVertexAttribPointer

      SeeAlso:
        Enable, Disable, IsEnabled, GetDataType, GetSize, IsNormalized,
        GetStride, gl.DrawArrays, gl.DrawElements, SetConfig }
    procedure SetData(const ADataType: TGLDataType;
      const ANumValuesPerVertex: Integer; const AData: Pointer;
      const AStride: NativeInt = 0; const ANormalized: Boolean = False); overload; inline;
    procedure SetData<T: record>(const AData: array of T;
      const AStride: NativeInt = 0; const ANormalized: Boolean = False); overload;
    procedure SetData<T: record>(const AData: TArray<T>;
      const AStride: NativeInt = 0; const ANormalized: Boolean = False); overload; inline;

    { Enables this vertex attribute.

      If enabled, the values in the generic vertex attribute array will be
      accessed and used for rendering when calls are made to vertex array
      commands such as gl.DrawArrays or gl.DrawElements.

      @bold(OpenGL API): glEnableVertexAttribArray

      SeeAlso:
        Disable, IsEnabled, SetConfig, SetData, gl.DrawArrays, gl.DrawElements }
    procedure Enable; inline;

    { Disables this vertex attribute.

      @bold(OpenGL API): glDisableVertexAttribArray

      SeeAlso:
        Enable, IsEnabled, SetConfig, SetData, gl.DrawArrays, gl.DrawElements }
    procedure Disable; inline;

    { Get the buffer object currently bound to the binding point corresponding
      to the generic vertex attribute. If no buffer object is bound, the Handle
      of the returned value is 0.

      @bold(OpenGL API): glGetVertexAttribiv(GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING)

      SeeAlso:
        Bind, SetConfig }
    function GetBuffer: TGLBuffer; inline;

    { Get whether the vertex attribute is enabled or not.

      Returns:
        True if the vertex attribute is enabled. False otherwise.

      @bold(OpenGL API): glGetVertexAttribiv(GL_VERTEX_ATTRIB_ARRAY_ENABLED)

      SeeAlso:
        Enable, Disable }
    function IsEnabled: Boolean; inline;

    { Get the size of the vertex attribute. The size is the number of values for
      each element of the vertex attribute array, and it will be 1, 2, 3, or 4.
      The initial value is 4.

      @bold(OpenGL API): glGetVertexAttribiv(GL_VERTEX_ATTRIB_ARRAY_SIZE)

      SeeAlso:
        SetConfig, SetData, GetStride, GetDataType, IsNormalized }
    function GetSize: Integer; inline;

    { Get the array stride for (number of bytes between successive elements in)
      the vertex attribute. A value of 0 indicates that the array elements are
      stored sequentially in memory. The initial value is 0.

      @bold(OpenGL API): glGetVertexAttribiv(GL_VERTEX_ATTRIB_ARRAY_STRIDE)

      SeeAlso:
        SetConfig, SetData, GetSize, GetDataType, IsNormalized }
    function GetStride: Integer; inline;

    { Get the data type of the vertex attribute.

      @bold(OpenGL API): glGetVertexAttribiv(GL_VERTEX_ATTRIB_ARRAY_TYPE)

      SeeAlso:
        SetConfig, SetData, GetSize, GetStride, IsNormalized }
    function GetDataType: TGLDataType; inline;

    { Get whether data for the vertex attribute is normalized when converted to
      floating-point.

      Returns:
        True if vertex data will be normalized. False otherwise.

      @bold(OpenGL API): glGetVertexAttribiv(GL_VERTEX_ATTRIB_ARRAY_NORMALIZED)

      SeeAlso:
        SetConfig, SetData, GetSize, GetStride, GetDataType }
    function IsNormalized: Boolean; inline;

    { Specify the value of a generic vertex attribute

      There are many overloaded versions for the different data types of the
      vertex attribute.

      When the vertex attribute is a vector, you can set its value by either
      passing 2, 3 or 4 values, or by passing a single value of type TVector2,
      TVector3 or TVector4.

      Generic attributes are defined as four-component values that are organized
      into an array. The first entry of this array is numbered 0, and the size
      of the array is implementation-dependent and can be queried with
      TGLShader.GetMaxVertexAttribs.

      When less than 4 Single-type values are passed, the remaining components
      will be set to 0, except for the 4th component, which will be set to 1.

      A user-defined attribute variable declared in a vertex shader can be bound
      to a generic attribute index by calling Bind. This allows an application
      to use descriptive variable names in a vertex shader. A subsequent change
      to the specified generic vertex attribute will be immediately reflected as
      a change to the corresponding attribute variable in the vertex shader.

      The binding between a generic vertex attribute index and a user-defined
      attribute variable in a vertex shader is part of the state of a program
      object, but the current value of the generic vertex attribute is not. The
      value of each generic vertex attribute is part of current state and it is
      maintained even if a different program object is used.

      An application may freely modify generic vertex attributes that are not
      bound to a named vertex shader attribute variable. These values are simply
      maintained as part of current state and will not be accessed by the vertex
      shader. If a generic vertex attribute bound to an attribute variable in a
      vertex shader is not updated while the vertex shader is executing, the
      vertex shader will repeatedly use the current value for the generic vertex
      attribute.

      @bold(Note): it is possible for an application to bind more than one
      attribute name to the same generic vertex attribute index. This is
      referred to as aliasing, and it is allowed only if just one of the aliased
      attribute variables is active in the vertex shader, or if no path through
      the vertex shader consumes more than one of the attributes aliased to the
      same location. OpenGL implementations are not required to do error checking
      to detect aliasing, they are allowed to assume that aliasing will not
      occur, and they are allowed to employ optimizations that work only in the
      absence of aliasing.

      @bold(OpenGL API): glVertexAttrib*

      SeeAlso:
        Bind, SetConfig, SetData }
    procedure SetValue(const AValue: Single); overload; inline;
    procedure SetValue(const AValue0, AValue1: Single); overload; inline;
    procedure SetValue(const AValue0, AValue1, AValue2: Single); overload; inline;
    procedure SetValue(const AValue0, AValue1, AValue2, AValue3: Single); overload; inline;
    procedure SetValue(const AValue: TVector2); overload; inline;
    procedure SetValue(const AValue: TVector3); overload; inline;
    procedure SetValue(const AValue: TVector4); overload; inline;
    procedure SetValue(const AValue: TMatrix2); overload; inline;
    procedure SetValue(const AValue: TMatrix3); overload; inline;
    procedure SetValue(const AValue: TMatrix4); overload; inline;

    { Get the current value for the generic vertex attribute.

      @bold(OpenGL API): glGetVertexAttribfv(GL_CURRENT_VERTEX_ATTRIB) }
    function GetValue: TVector4;

    { When the vertex attribute is used with a TGLBuffer (that is, when
      SetConfig is used), then this method returns the byte offset into the
      buffer objects's data store for this vertex attribute. This equals the
      AOffset parameter passed to SetConfig.

      When the vertex attribute is used with client data (that is, when SetData
      is used), then the returned value is undefined.

      @bold(OpenGL API): glGetVertexAttribPointerv

      SeeAlso:
        SetConfig, SetData, GetData }
    function GetOffset: Integer; inline;

    { When the vertex attribute is used with client data (that is, when SetData
      is used), then this method returns a pointer to the client data. This
      equals the AData parameter passed to SetData.

      When the vertex attribute is used with a TGLBuffer (that is, when
      SetConfig is used), then the returned value is undefined.

      @bold(OpenGL API): glGetVertexAttribPointerv

      SeeAlso:
        SetConfig, SetData, GetOffset }
    function GetData: Pointer; inline;

    { The location of this attribute in the vertex shader of the program. }
    property Location: GLint read FLocation;
  end;

type
  { Represents a uniform in a TGLProgram.
    These are variables marked with @code(uniform) in a vertex or fragment
    shader. }
  TGLUniform = record
  {$REGION 'Internal Declarations'}
  private
    FLocation: GLint;
    FProgram: GLuint;
  {$REGION 'Internal Declarations'}
  public
    { Initializes the uniform.

      Parameters:
        AProgram: the program containing the uniform.
        AUniformName: the (case-sensitive) name of the uniform as used in the
          vertex or fragment shader of the program.

      Raises:
        TGLError.InvalidOperation if AProgram is not a valid program or has
        not been successfully linked.

      AUniformName must be an active uniform variable name in program that is
      not a structure, an array of structures, or a subcomponent of a vector or
      a matrix.

      Uniform variables that are structures or arrays of structures may be
      queried by using separate TGLUniform records for each field within the
      structure. The array element operator "[]" and the structure field
      operator "." may be used in name in order to select elements within an
      array or fields within a structure. The result of using these operators is
      not allowed to be another structure, an array of structures, or a
      subcomponent of a vector or a matrix. Except if the last part of name
      indicates a uniform variable array, the location of the first element of
      an array can be retrieved by using the name of the array, or by using the
      name appended by "[0]".

      The actual locations assigned to uniform variables are not known until the
      program object is linked successfully.

      @bold(Note): in DEBUG mode, a warning will be logged to the debug console
      of AProgram does not contain a uniform named AUniformName.

      @bold(OpenGL API): glGetUniformLocation

      SeeAlso:
        SetValue }
    procedure Init(const AProgram: TGLProgram;
      const AUniformName: RawByteString); inline;

    { Sets the value of the uniform. There are many overloaded versions for the
      different data types of the uniform.

      When the uniform is a vector, you can set its value by either passing 2,
      3 or 4 values, or by passing a single value of type TVector2, TVector3 or
      TVector4.

      This method modifies the value of a uniform variable. It operates on the
      program object that was made part of current state by calling
      TGLProgram.Use.

      All active uniform variables defined in a program object are initialized
      to 0 when the program object is linked successfully. They retain the
      values assigned to them by a call to SetValue until the next successful
      link operation occurs on the program object, when they are once again
      initialized to 0.

      @bold(Note): for sampler uniforms, the value must be of an integer type.

      Raises:
        TGLError.InvalidOperation if there is no current program in use.
        TGLError.InvalidOperation if the number and types of the parameters
          does not match the declaration in the shader.
        TGLError.InvalidOperation if the uniform is of a sampler type, and
          the parameter is not of an integer type.

      @bold(OpenGL API): glUniform*

      SeeAlso:
        Init, TGLProgram.Link, TGLProgram.Use, GetValue }
    procedure SetValue(const AValue: Single); overload; inline;
    procedure SetValue(const AValue0, AValue1: Single); overload; inline;
    procedure SetValue(const AValue0, AValue1, AValue2: Single); overload; inline;
    procedure SetValue(const AValue0, AValue1, AValue2, AValue3: Single); overload; inline;
    procedure SetValue(const AValue: TVector2); overload; inline;
    procedure SetValue(const AValue: TVector3); overload; inline;
    procedure SetValue(const AValue: TVector4); overload; inline;
    procedure SetValue(const AValue: TMatrix2); overload; inline;
    procedure SetValue(const AValue: TMatrix3); overload; inline;
    procedure SetValue(const AValue: TMatrix4); overload; inline;

    procedure SetValue(const AValue: Integer); overload; inline;
    procedure SetValue(const AValue0, AValue1: Integer); overload; inline;
    procedure SetValue(const AValue0, AValue1, AValue2: Integer); overload; inline;
    procedure SetValue(const AValue0, AValue1, AValue2, AValue3: Integer); overload; inline;
    procedure SetValue(const AValue: TIVector2); overload; inline;
    procedure SetValue(const AValue: TIVector3); overload; inline;
    procedure SetValue(const AValue: TIVector4); overload; inline;

    { Behaves like SetValue, but operates on a single uniform variable or a
      uniform variable array.

      Parameters:
        AValues: array of values to set.

      If AValues contains just a single value, then this method can be used to
      modify either a single uniform variable or a uniform variable array.

      If AValues contains more than one value, then this method can only be used
      to modify a uniform variable array.

      @bold(OpenGL API): glUniform*v

      See SetValue for more notes and information. }
    procedure SetValues(const AValues: array of Single); overload;
    procedure SetValues(const AValues: TArray<Single>); overload; inline;
    procedure SetValues(const AValues: array of TVector2); overload;
    procedure SetValues(const AValues: TArray<TVector2>); overload; inline;
    procedure SetValues(const AValues: array of TVector3); overload;
    procedure SetValues(const AValues: TArray<TVector3>); overload; inline;
    procedure SetValues(const AValues: array of TVector4); overload;
    procedure SetValues(const AValues: TArray<TVector4>); overload; inline;

    procedure SetValues(const AValues: array of Integer); overload;
    procedure SetValues(const AValues: TArray<Integer>); overload; inline;
    procedure SetValues(const AValues: array of TIVector2); overload;
    procedure SetValues(const AValues: TArray<TIVector2>); overload; inline;
    procedure SetValues(const AValues: array of TIVector3); overload;
    procedure SetValues(const AValues: TArray<TIVector3>); overload; inline;
    procedure SetValues(const AValues: array of TIVector4); overload;
    procedure SetValues(const AValues: TArray<TIVector4>); overload; inline;

    procedure SetValues(const AValues: array of TMatrix2); overload;
    procedure SetValues(const AValues: TArray<TMatrix2>); overload; inline;
    procedure SetValues(const AValues: array of TMatrix3); overload;
    procedure SetValues(const AValues: TArray<TMatrix3>); overload; inline;
    procedure SetValues(const AValues: array of TMatrix4); overload;
    procedure SetValues(const AValues: TArray<TMatrix4>); overload; inline;

    { Return the value of a uniform variable.

      Parameters:
        AValue: is set to the returned value.

      This method returns in AValue the value of the uniform variable. The type
      of the uniform variable determines the type of value that is returned. It
      is the responsibility of the caller to make sure that the type of AValue
      matches the type of the uniform variable in the shader.

      The uniform variable values can only be queried after a link if the link
      was successful.

      Raises:
        TGLError.InvalidOperation if the program is not successfully linked.

      @bold(OpenGL API): glGetUniform*

      SeeAlso:
        Init, TGLProgram.Link, TGLProgram.Use, SetValue }
    procedure GetValue(out AValue: Single); overload; inline;
    procedure GetValue(out AValue0, AValue1: Single); overload; inline;
    procedure GetValue(out AValue0, AValue1, AValue2: Single); overload; inline;
    procedure GetValue(out AValue0, AValue1, AValue2, AValue3: Single); overload; inline;
    procedure GetValue(out AValue: TVector2); overload; inline;
    procedure GetValue(out AValue: TVector3); overload; inline;
    procedure GetValue(out AValue: TVector4); overload; inline;
    procedure GetValue(out AValue: TMatrix2); overload; inline;
    procedure GetValue(out AValue: TMatrix3); overload; inline;
    procedure GetValue(out AValue: TMatrix4); overload; inline;

    procedure GetValue(out AValue: Integer); overload; inline;
    procedure GetValue(out AValue0, AValue1: Integer); overload; inline;
    procedure GetValue(out AValue0, AValue1, AValue2: Integer); overload; inline;
    procedure GetValue(out AValue0, AValue1, AValue2, AValue3: Integer); overload; inline;
    procedure GetValue(out AValue: TIVector2); overload; inline;
    procedure GetValue(out AValue: TIVector3); overload; inline;
    procedure GetValue(out AValue: TIVector4); overload; inline;

    { Get the maximum number of four-element floating-point, integer, or boolean
      vectors that can be held in uniform variable storage for a vertex
      shader. The value must be at least 128.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_VERTEX_UNIFORM_VECTORS)

      SeeAlso:
        SetValue, SetValues, GetMaxFragmentUniformVectors }
    class function GetMaxVertexUniformVectors: Integer; inline; static;

    { Get the maximum number of four-element floating-point, integer, or boolean
      vectors that can be held in uniform variable storage for a fragment
      shader. The value must be at least 16.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_FRAGMENT_UNIFORM_VECTORS)

      SeeAlso:
        SetValue, SetValues, GetMaxVertexUniformVectors }
    class function GetMaxFragmentUniformVectors: Integer; inline; static;

    { The location of this uniform in the program. }
    property Location: GLint read FLocation;
  end;

type
  { A texture }
  TGLTexture = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: GLuint;
    FType: GLenum;
  private
    function GetTarget(const ACubeTarget: TGLCubeTarget): GLuint; inline;
  {$REGION 'Internal Declarations'}
  public
    { Creates a texture.

      Parameters:
        AType: (optional) type of texture to create. Defaults to a 2D texture.

      @bold(OpenGL API): glGenTextures

      SeeAlso:
        Bind, Delete, Upload, Copy }
    procedure New(const AType: TGLTextureType = TGLTextureType.TwoD); inline;

    { Deletes the texture.

      After a texture is deleted, it has no contents or dimensionality. If a
      texture that is currently bound is deleted, the binding reverts to 0 (the
      default texture).

      @bold(OpenGL API): glDeleteTextures

      SeeAlso:
        Bind, New }
    procedure Delete; inline;

    { Binds the texture.

      Lets you create or use a named texture. Binds the texture name to the
      target of the current active texture unit. When a texture is bound to a
      target, the previous binding for that target is automatically broken.

      When a texture is first bound, it assumes the specified target: A first
      bound texture of type TGLTextureType.TwoD becomes a two-dimensional
      texture and a first bound texture of type TGLTextureType.CubeMap becomes a
      cube-mapped texture. The state of a two-dimensional texture immediately
      after it is first bound is equivalent to the state of the default texture
      at GL initialization.

      While a texture is bound, GL operations on the target to which it is bound
      affect the bound texture, and queries of the target to which it is bound
      return state from the bound texture. In effect, the texture targets become
      aliases for the textures currently bound to them, and the texture name
      zero refers to the default textures that were bound to them at
      initialization.

      A texture binding remains active until a different texture is bound to the
      same target, or until the bound texture is deleted with Delete.

      Once created, a named texture may be re-bound to its same original target
      as often as needed. It is usually much faster to use Bind to bind an
      existing named texture to one of the texture targets than it is to reload
      the texture image using Upload.

      @bold(OpenGL API): glBindTexture

      SeeAlso:
        New, Delete, Unbind, IsBound, BindToTextureUnit, UnbindFromTextureUnit }
    procedure Bind; inline;

    { Unbinds the texture.

      @bold(OpenGL API): glBindTexture

      SeeAlso:
        Bind, IsBound, BindToTextureUnit, UnbindFromTextureUnit }
    procedure Unbind; inline;

    { Checks if this texture is currently bound.

      Returns:
        True if this is the currently bound texture, False otherwise. }
    function IsBound: Boolean; inline;

    { Actives a texture unit and binds this texture to that unit.

      Parameters:
        ATextureUnit: index of the texture unit to make active. The number of
          texture units is implementation dependent, but must be at least 8.

      Raises:
        TGLError.InvalidEnum if ATextureUnit is greater than the number of
        supported texture units.

      Once the texture unit is active, it binds the texture by calling Bind.

      @bold(OpenGL API): glActiveTexture, glBindTexture

      SeeAlso:
        Bind, Unbind, IsBound, UnbindFromTextureUnit, GetMaxTextureUnits,
        GetMaxCombinedTextureUnits }
    procedure BindToTextureUnit(const ATextureUnit: Cardinal); inline;

    { Actives a texture unit and unbinds this texture from that unit.

      Parameters:
        ATextureUnit: index of the texture unit to make active. The number of
          texture units is implementation dependent, but must be at least 8.

      Raises:
        TGLError.InvalidEnum if ATextureUnit is greater than the number of
        supported texture units.

      Once the texture unit is active, it unbinds the texture by calling Unbind.

      @bold(OpenGL API): glActiveTexture, glBindTexture

      SeeAlso:
        Bind, Unbind, IsBound, BindToTextureUnit, GetMaxTextureUnits,
        GetMaxCombinedTextureUnits }
    procedure UnbindFromTextureUnit(const ATextureUnit: Cardinal); inline;

    { Generate a complete set of mipmaps for this texture object.

      Computes a complete set of mipmap arrays derived from the zero level
      array. Array levels up to and including the 1x1 dimension texture image
      are replaced with the derived arrays, regardless of previous contents. The
      zero level texture image is left unchanged.

      The internal formats of the derived mipmap arrays all match those of the
      zero level texture image. The dimensions of the derived arrays are
      computed by halving the width and height of the zero level texture image,
      then in turn halving the dimensions of each array level until the 1x1
      dimension texture image is reached.

      The contents of the derived arrays are computed by repeated filtered
      reduction of the zero level array. No particular filter algorithm is
      required, though a box filter is recommended. MipmapHint may be called to
      express a preference for speed or quality of filtering.

      Raises:
        TGLError.InvalidOperation if this is a cube map texture, but its
          six faces do not share indentical widths, heights, formats, and types.
        TGLError.InvalidOperation if either the width or height of the zero
          level array is not a power of two.
        TGLError.InvalidOperation if the zero level array is stored in a
          compressed internal format.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glGenerateMipmap

      SeeAlso:
        Bind, Unbind, TGLFrameBuffer.AttachTexture, MipmapHint, Upload }
    procedure GenerateMipmap; inline;

    { Sets the minification filter for this texture.

      Parameters:
        AMinFilter: the minification filter.

      The texture minifying function is used whenever the pixel being textured
      maps to an area greater than one texture element. There are six defined
      minifying functions. Two of them use the nearest one or nearest four
      texture elements to compute the texture value. The other four use mipmaps.

      A mipmap is an ordered set of arrays representing the same image at
      progressively lower resolutions. If the texture has dimensions W × H,
      there are Floor(Log2(Max(W, H)) + 1) mipmap levels. The first mipmap level
      is the original texture, with dimensions W × H. Each subsequent mipmap
      level has half the dimensions of the previous level, until the final
      mipmap is reached, which has dimension 1 × 1.

      To define the mipmap levels, call Upload, UploadCompressed or Copy with
      the ALevel argument indicating the order of the mipmaps. Level 0 is the
      original texture; level Floor(Log2(Max(W, H))) is the final 1 × 1 mipmap.

      As more texture elements are sampled in the minification process, fewer
      aliasing artifacts will be apparent. While the Nearest and Linear
      minification functions can be faster than the other four, they sample only
      one or four texture elements to determine the texture value of the pixel
      being rendered and can produce moire patterns or ragged transitions. The
      initial value of the minification filter is NearestMipmapLinear.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glTexParameteri(GL_TEXTURE_MIN_FILTER)

      SeeAlso:
        Bind, Unbind, BindToTextureUnit, UnbindFromTextureUnit, Upload,
        SubUpload, Copy, SubCopy, gl.PixelStore, GetMinFilter, MagFilter }
    procedure MinFilter(const AMinFilter: TGLMinFilter); inline;

    { Gets the minification filter for this texture.

      Returns:
        The minification filter.

      @bold(OpenGL API): glGetTexParameteriv(GL_TEXTURE_MIN_FILTER)

      SeeAlso:
        MinFilter }
    function GetMinFilter: TGLMinFilter; inline;

    { Sets the magnification filter for this texture.

      Parameters:
        AMagFilter: the magnification filter.

      The texture magnification function is used when the pixel being textured
      maps to an area less than or equal to one texture element. It sets the
      texture magnification function to either Nearest or Linear. Nearest is
      generally faster than Linear, but it can produce textured images with
      sharper edges because the transition between texture elements is not as
      smooth. The initial value of the magnification filter is Linear.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glTexParameteri(GL_TEXTURE_MAG_FILTER)

      SeeAlso:
        Bind, Unbind, BindToTextureUnit, UnbindFromTextureUnit, Upload,
        SubUpload, Copy, SubCopy, gl.PixelStore, GetMagFilter, MinFilter }
    procedure MagFilter(const AMagFilter: TGLMagFilter); inline;

    { Gets the magnification filter for this texture.

      Returns:
        The magnification filter.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glGetTexParameteriv(GL_TEXTURE_MAG_FILTER)

      SeeAlso:
        MagFilter }
    function GetMagFilter: TGLMagFilter; inline;

    { Sets the wrap mode for texture coordinate S (horizontal).

      Parameters:
        AWrap: the wrap mode.

      See TGLWrapMode for options and their effects.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glTexParameteri(GL_TEXTURE_WRAP_S)

      SeeAlso:
        Bind, Unbind, BindToTextureUnit, UnbindFromTextureUnit, GetWrapS,
        WrapT }
    procedure WrapS(const AWrap: TGLWrapMode); inline;

    { Gets the wrap mode for texture coordinate S.

      Returns:
        The wrap mode.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glGetTexParameteriv(GL_TEXTURE_WRAP_S)

      SeeAlso:
        WrapS }
    function GetWrapS: TGLWrapMode; inline;

    { Sets the wrap mode for texture coordinate T (vertical).

      Parameters:
        AWrap: the wrap mode.

      See TGLWrapMode for options and their effects.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glTexParameteri(GL_TEXTURE_WRAP_T)

      SeeAlso:
        Bind, Unbind, BindToTextureUnit, UnbindFromTextureUnit, GetWrapT,
        WrapS }
    procedure WrapT(const AWrap: TGLWrapMode); inline;

    { Gets the wrap mode for texture coordinate T.

      Returns:
        The wrap mode.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glGetTexParameteriv(GL_TEXTURE_WRAP_T)

      SeeAlso:
        WrapT }
    function GetWrapT: TGLWrapMode; inline;

    { Uploads an image to the texture. This creates the texture in memory.

      Parameters:
        AFormat: the format of the texel data.
        AWidth: the width of the texture image. All implementations support 2D
          texture images that are at least 64 texels wide and cube-mapped
          texture images that are at least 16 texels wide.
        AHeight: the height of the texture image. All implementations support 2D
          texture images that are at least 64 texels high and cube-mapped
          texture images that are at least 16 texels high.
        AData: pointer to the image data in memory.
        ALevel: (optional) level-of-detail number if updating separate mipmap
          levels. Level 0 (default) is the base image level. Level N is the Nth
          mipmap reduction image.
        AType: (optional) data type the texel data. Defaults to UnsignedByte.
        ACubeTarget: (optional) if this texture is a cube texture, then this
          parameter specifies which of the 6 cube faces to update. This
          parameter is ignored for 2D textures.

      Raises:
        TGLError.InvalidValue if this is a cube map texture and the AWidth and
          AHeight parameters are not equal.
        TGLError.InvalidValue if ALevel is less than 0 or greater than the
          maximum level.
        TGLError.InvalidValue if AWidth or AHeight is less than 0 or greater
          than the maximum texture size.
        TGLError.InvalidOperation if AType is UnsignedShort565 and AFormat is
          not RGB.
        TGLError.InvalidOperation if AType is UnsignedShort4444 or
          UnsignedShort5551 and AFormat is not RGBA.

      Texturing maps a portion of a specified texture image onto each graphical
      primitive for which texturing is active. Texturing is active when the
      current fragment shader or vertex shader makes use of built-in texture
      lookup functions.

      To define texture images, call Upload. The arguments describe the
      parameters of the texture image, such as height, width, level-of-detail
      number (see MinFilter), and format. The other arguments describe how the
      image is represented in memory.

      Data is read from AData as a sequence of unsigned bytes or shorts,
      depending on AType. Color components are converted to floating point based
      on the AType.

      AWidth × AHeight texels are read from memory, starting at location AData.
      By default, these texels are taken from adjacent memory locations, except
      that after all width texels are read, the read pointer is advanced to the
      next four-byte boundary. The four-byte row alignment is specified by
      gl.PixelStore with argument UnpackAlignment, and it can be set to one,
      two, four, or eight bytes.

      The first element corresponds to the lower left corner of the texture
      image. Subsequent elements progress left-to-right through the remaining
      texels in the lowest row of the texture image, and then in successively
      higher rows of the texture image. The final element corresponds to the
      upper right corner of the texture image.

      @bold(Note): AData may be a nil pointer. In this case, texture memory is
      allocated to accommodate a texture of AWidth × AHeight pixels. You can
      then upload subtextures to initialize this texture memory. The image is
      undefined if the user tries to apply an uninitialized portion of the
      texture image to a primitive.

      @bold(Note): This method specifies a two-dimensional or cube-map texture
      for the current texture unit, specified with BindToTextureUnit.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glTexImage2D

      SeeAlso:
        BindToTextureUnit, UploadCompressed, SubUpload, SubUploadCompressed,
        Copy, SubCopy, gl.PixelStore, GetMaxTextureSize,
        GetMaxCubeMapTextureSize }
    procedure Upload(const AFormat: TGLPixelFormat; const AWidth,
      AHeight: Integer; const AData: Pointer; const ALevel: Integer = 0;
      const AType: TGLPixelDataType = TGLPixelDataType.UnsignedByte;
      const ACubeTarget: TGLCubeTarget = 0); inline;

    { Uploads a part of an image to the texture. This updates the texture in
      memory.

      Parameters:
        AFormat: the format of the texel data.
        AXOffset: texel offset in the X direction within the texture array.
        AYOffset: texel offset in the Y direction within the texture array.
        AWidth: the width of the texture subimage.
        AHeight: the height of the texture subimage.
        AData: pointer to the image data in memory.
        ALevel: (optional) level-of-detail number if updating separate mipmap
          levels. Level 0 (default) is the base image level. Level N is the Nth
          mipmap reduction image.
        AType: (optional) data type the texel data. Defaults to UnsignedByte.
        ACubeTarget: (optional) if this texture is a cube texture, then this
          parameter specifies which of the 6 cube faces to update. This
          parameter is ignored for 2D textures.

      Raises:
        TGLError.InvalidValue if ALevel is less than 0 or greater than the
          maximum level.
        TGLError.InvalidValue if AXOffset < 0 or AXOffset + AWidth is greater
          than the width of this texture.
        TGLError.InvalidValue if AYOffset < 0 or AYOffset + AHeight is greater
          than the height of this texture.
        TGLError.InvalidValue if AWidth or AHeight is less than 0.
        TGLError.InvalidOperation if the texture array has not been defined by
          a previous Upload of Copy operation whose AFormat matches the AFormat
          parameter of this method.
        TGLError.InvalidOperation if AType is UnsignedShort565 and AFormat is
          not RGB.
        TGLError.InvalidOperation if AType is UnsignedShort4444
          or UnsignedShort5551 and AFormat is not RGBA.

      This method redefines a contiguous subregion of an existing
      two-dimensional texture image. The texels referenced by data replace the
      portion of the existing texture array with X indices AXOffset and
      AXOffset + AWidth - 1, inclusive, and Y indices AYOffset and
      AYOffset + AHeight - 1, inclusive. This region may not include any texels
      outside the range of the texture array as it was originally specified. It
      is not an error to specify a subtexture with zero width or height, but
      such a specification has no effect.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glTexSubImage2D

      SeeAlso:
        BindToTextureUnit, Upload, UploadCompressed, SubUploadCompressed,
        Copy, SubCopy, gl.PixelStore, GetMaxTextureSize,
        GetMaxCubeMapTextureSize }
    procedure SubUpload(const AFormat: TGLPixelFormat; const AXOffset, AYOffset,
      AWidth, AHeight: Integer; const AData: Pointer; const ALevel: Integer = 0;
      const AType: TGLPixelDataType = TGLPixelDataType.UnsignedByte;
      const ACubeTarget: TGLCubeTarget = 0); inline;

    { Uploads a compressed image to the texture. This creates the texture in
      memory.

      Parameters:
        AFormat: the compressed format of the texel data.
        AWidth: the width of the texture image. All implementations support 2D
          texture images that are at least 64 texels wide and cube-mapped
          texture images that are at least 16 texels wide.
        AHeight: the height of the texture image. All implementations support 2D
          texture images that are at least 64 texels high and cube-mapped
          texture images that are at least 16 texels high.
        AData: pointer to the compressed image data in memory.
        ADataSize: the size of the compressed image data in bytes.
        ALevel: (optional) level-of-detail number if updating separate mipmap
          levels. Level 0 (default) is the base image level. Level N is the Nth
          mipmap reduction image.
        ACubeTarget: (optional) if this texture is a cube texture, then this
          parameter specifies which of the 6 cube faces to update. This
          parameter is ignored for 2D textures.

      Raises:
        TGLError.InvalidEnum if AFormat is not a supported format returned
          in GetCompressedTextureFormats.
        TGLError.InvalidValue if ALevel is less than 0 or greater than the
          maximum level.
        TGLError.InvalidValue if AWidth or AHeight is less than 0 or greater
          than the maximum texture size.
        TGLError.InvalidValue if ADataSize is not consistent with the format,
          dimensions, and contents of the specified compressed image data.
        TGLError.InvalidOperation if parameter combinations are not supported
          by the specific compressed internal format as specified in the
          specific texture compression extension.
        Other Undefined results, including abnormal program termination, are
          generated if data is not encoded in a manner consistent with the
          extension specification defining the internal compression format.

      Texturing maps a portion of a specified texture image onto each graphical
      primitive for which texturing is active. Texturing is active when the
      current fragment shader or vertex shader makes use of built-in texture
      lookup functions.

      This method defines a two-dimensional texture image or cube-map texture
      image using compressed image data from client memory. The texture image is
      decoded according to the extension specification defining the specified
      AFormat. OpenGL ES defines no specific compressed texture formats, but
      does provide a mechanism to obtain symbolic constants for such formats
      provided by extensions. The list of specific compressed texture formats
      supported can be obtained by GetCompressedTextureFormats.

      @bold(Note): a GL implementation may choose to store the texture array at
      any internal resolution it chooses.

      @bold(Note): this method specifies a two-dimensional or cube-map texture
      for the current texture unit, specified with BindToTextureUnit.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glCompressedTexImage2D

      SeeAlso:
        BindToTextureUnit, Upload, SubUpload, SubUploadCompressed, Copy,
        SubCopy, GetMaxTextureSize, GetMaxCubeMapTextureSize,
        GetCompressedTextureFormats }
    procedure UploadCompressed(const AFormat: Cardinal; const AWidth,
      AHeight: Integer; const AData: Pointer; const ADataSize: Integer;
      const ALevel: Integer = 0; const ACubeTarget: TGLCubeTarget = 0); inline;

    { Uploads a part of a compressed image to the texture. This updates the
      texture in memory.

      Parameters:
        AFormat: the compressed format of the texel data.
        AXOffset: texel offset in the X direction within the texture array.
        AYOffset: texel offset in the Y direction within the texture array.
        AWidth: the width of the texture subimage.
        AHeight: the height of the texture subimage.
        AData: pointer to the compressed image data in memory.
        ADataSize: the size of the compressed image data in bytes.
        ALevel: (optional) level-of-detail number if updating separate mipmap
          levels. Level 0 (default) is the base image level. Level N is the Nth
          mipmap reduction image.
        ACubeTarget: (optional) if this texture is a cube texture, then this
          parameter specifies which of the 6 cube faces to update. This
          parameter is ignored for 2D textures.

      Raises:
        TGLError.InvalidEnum if AFormat is not a supported format returned
          in GetCompressedTextureFormats.
        TGLError.InvalidValue if ALevel is less than 0 or greater than the
          maximum level.
        TGLError.InvalidValue if AXOffset < 0 or AXOffset + AWidth is greater
          than the width of this texture.
        TGLError.InvalidValue if AYOffset < 0 or AYOffset + AHeight is greater
          than the height of this texture.
        TGLError.InvalidValue if AWidth or AHeight is less than 0.
        TGLError.InvalidValue if ADataSize is not consistent with the format,
          dimensions, and contents of the specified compressed image data.
        TGLError.InvalidOperation if the texture array has not been defined by
          a previous UploadCompressed operation whose AFormat matches the format
          of this method.
        TGLError.InvalidOperation if parameter combinations are not supported
          by the specific compressed internal format as specified in the
          specific texture compression extension.
        Other Undefined results, including abnormal program termination, are
          generated if data is not encoded in a manner consistent with the
          extension specification defining the internal compression format.

      Texturing maps a portion of a specified texture image onto each graphical
      primitive for which texturing is active. Texturing is active when the
      current fragment shader or vertex shader makes use of built-in texture
      lookup functions.

      This method redefines a contiguous subregion of an existing
      two-dimensional texture image. The texels referenced by AData replace the
      portion of the existing texture array with X indices AXOffset and
      AXoffset + AWidth - 1, and the Y indices AYOffset and
      AYOffset + AHeight - 1, inclusive. This region may not include any texels
      outside the range of the texture array as it was originally specified. It
      is not an error to specify a subtexture with width of 0, but such a
      specification has no effect.

      AFormat must be the same extension-specified compressed-texture format
      previously specified by UploadCompressed.

      @bold(Note): this method specifies a two-dimensional or cube-map texture
      for the current texture unit, specified with BindToTextureUnit.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glCompressedTexSubImage2D

      SeeAlso:
        BindToTextureUnit, Upload, SubUpload, UploadCompressed, Copy, SubCopy,
        GetMaxTextureSize, GetMaxCubeMapTextureSize,
        GetCompressedTextureFormats }
    procedure SubUploadCompressed(const AFormat: Cardinal; const AXOffset,
      AYOffset, AWidth, AHeight: Integer; const AData: Pointer;
      const ADataSize: Integer; const ALevel: Integer = 0;
      const ACubeTarget: TGLCubeTarget = 0); inline;

    { Copies pixels from the current framebuffer into the texture.

      Parameters:
        AFormat: the format of the texel data.
        ALeft: window coordinate of the left corner of the rectangular region
          of pixels to be copied.
        ABottom: window coordinate of the bottom corner of the rectangular
          region of pixels to be copied.
        AWidth: the width of the texture image. All implementations support 2D
          texture images that are at least 64 texels wide and cube-mapped
          texture images that are at least 16 texels wide.
        AHeight: the height of the texture image. All implementations support 2D
          texture images that are at least 64 texels high and cube-mapped
          texture images that are at least 16 texels high.
        ALevel: (optional) level-of-detail number if updating separate mipmap
          levels. Level 0 (default) is the base image level. Level N is the Nth
          mipmap reduction image.
        ACubeTarget: (optional) if this texture is a cube texture, then this
          parameter specifies which of the 6 cube faces to update. This
          parameter is ignored for 2D textures.

      Raises:
        TGLError.InvalidValue if this is a cube map texture and the AWidth
          and AHeight parameters are not equal.
        TGLError.InvalidValue if ALevel is less than 0 or greater than the
          maximum level.
        TGLError.InvalidValue if AWidth or AHeight is less than 0 or greater
          than then maximum texture size.
        TGLError.InvalidOperation if the currently bound framebuffer's format
          does not contain a superset of the components required by the base
          format of AFormat.

      This method defines a two-dimensional texture image or cube-map texture
      image with pixels from the current framebuffer (rather than from client
      memory, as is the case for Upload).

      The screen-aligned pixel rectangle with lower left corner at (ALeft,
      ABottom) and with a width of AWidth and a height of AHeight defines the
      texture array at the mipmap level specified by ALevel. AFormat specifies
      the internal format of the texture array.

      The pixels in the rectangle are processed exactly as if
      TGLFramebuffer.ReadPixels had been called with format set to RGBA, but the
      process stops just after conversion of RGBA values. Subsequent processing
      is identical to that described for Upload, beginning with the clamping of
      the R, G, B, and A values to the range 0-1 and then conversion to the
      texture's internal format for storage in the texel array.

      The components required for AFormat must be a subset of those present in
      the framebuffer's format. For example, a RGBA framebuffer can be used to
      supply components for any AFormat. However, a RGB framebuffer can only be
      used to supply components for RGB or Luminance base internal format
      textures, not Alpha, LuminanceAlpha or RGBA textures.

      Pixel ordering is such that lower ALeft and ABottom screen coordinates
      correspond to lower S and T texture coordinates.

      If any of the pixels within the specified rectangle are outside the
      framebuffer associated with the current rendering context, then the values
      obtained for those pixels are undefined.

      @bold(Note): a GL implementation may choose to store the texture array at
      any internal resolution it chooses.

      @bold(Note): an image with height or width of 0 indicates a NULL texture.

      @bold(Note): This method specifies a two-dimensional or cube-map texture
      for the current texture unit, specified with BindToTextureUnit.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glCopyTexImage2D

      SeeAlso:
        BindToTextureUnit, TGLFrameBuffer.Status, Upload, UploadCompressed,
        SubUpload, SubUploadCompressed, SubCopy, GetMaxTextureSize,
        GetMaxCubeMapTextureSize }
    procedure Copy(const AFormat: TGLPixelFormat; const ALeft, ABottom, AWidth,
      AHeight: Integer; const ALevel: Integer = 0;
      const ACubeTarget: TGLCubeTarget = 0); inline;

    { Copies pixels from a part of the current framebuffer into the texture.

      Parameters:
        AXOffset: texel offset in the X direction within the texture array.
        AYOffset: texel offset in the Y direction within the texture array.
        ALeft: window coordinate of the left corner of the rectangular region
          of pixels to be copied.
        ABottom: window coordinate of the bottom corner of the rectangular
          region of pixels to be copied.
        AWidth: the width of the texture subimage.
        AHeight: the height of the texture subimage.
        ALevel: (optional) level-of-detail number if updating separate mipmap
          levels. Level 0 (default) is the base image level. Level N is the Nth
          mipmap reduction image.
        ACubeTarget: (optional) if this texture is a cube texture, then this
          parameter specifies which of the 6 cube faces to update. This
          parameter is ignored for 2D textures.

      Raises:
        TGLError.InvalidValue if ALevel is less than 0 or greater than the
          maximum level.
        TGLError.InvalidValue if AXOffset < 0 or AXOffset + AWidth is greater
          than the width of this texture.
        TGLError.InvalidValue if AYOffset < 0 or AYOffset + AHeight is greater
          than the height of this texture.
        TGLError.InvalidValue if AWidth or AHeight is less than 0.
        TGLError.InvalidOperation if the texture array has not been defined by
          a previous Upload of Copy operation whose AFormat matches the AFormat
          parameter of this method.
        TGLError.InvalidOperation if the currently bound framebuffer's format
          does not contain a superset of the components required by the base
          format of AFormat.
        TGLError.InvalidFramebufferOperation if the currently bound
          framebuffer is not framebuffer complete.

      This method replaces a rectangular portion of a two-dimensional texture
      image or cube-map texture image with pixels from the current framebuffer
      (rather than from client memory, as is the case for SubUpload).

      The screen-aligned pixel rectangle with lower left corner at ALeft,
      ABottom and with width AWidth and height AHeight replaces the portion of
      the texture array with X indices AXOffset through AXOffset + AWidth - 1,
      inclusive, and Y indices AYOffset through AYOffset + AHeight - 1,
      inclusive, at the mipmap level specified by level.

      The pixels in the rectangle are processed exactly as if
      TGLFramebuffer.ReadPixels had been called with format set to RGBA, but the
      process stops just after conversion of RGBA values. Subsequent processing
      is identical to that described for SubUpload, beginning with the clamping
      of the R, G, B, and A values to the range 0-1 and then conversion to the
      texture's internal format for storage in the texel array.

      The destination rectangle in the texture array may not include any texels
      outside the texture array as it was originally specified. It is not an
      error to specify a subtexture with zero width or height, but such a
      specification has no effect.

      If any of the pixels within the specified rectangle are outside the
      framebuffer associated with the current rendering context, then the values
      obtained for those pixels are undefined.

      No change is made to the internalformat, width, or height parameters of
      the texture array or to texel values outside the specified subregion.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this texture is not bound.

      @bold(OpenGL API): glCopyTexSubImage2D

      SeeAlso:
        BindToTextureUnit, TGLFrameBuffer.Status, Upload, UploadCompressed,
        SubUploadCompressed, Copy, GetMaxTextureSize, GetMaxCubeMapTextureSize }
    procedure SubCopy(const AXOffset, AYOffset, ALeft, ABottom, AWidth,
      AHeight: Integer; const ALevel: Integer = 0;
      const ACubeTarget: TGLCubeTarget = 0); inline;

    { Get the 2D texture that is currently bound for the active multitexture
      unit.

      Returns:
        The currently bound 2D texture. Its Handle will be 0 if there is no
        2D texture bound.

      @bold(OpenGL API): glGetProgramiv(GL_TEXTURE_BINDING_2D)

      SeeAlso:
        Bind, GetCurrentCubeMapTexture }
    class function GetCurrent2DTexture: TGLTexture; inline; static;

    { Get the cubemap texture that is currently bound for the active
      multitexture unit.

      Returns:
        The currently bound cubemap texture. Its Handle will be 0 if there is no
        cubemap texture bound.

      @bold(OpenGL API): glGetProgramiv(GL_TEXTURE_BINDING_CUBE_MAP)

      SeeAlso:
        Bind, GetCurrent2DTexture }
    class function GetCurrentCubemapTexture: TGLTexture; inline; static;

    { Gets the active texture unit.

      Returns:
        The index active multitexture unit, ranging from 0 to
        GetMaxTextureUnits - 1.

      @bold(OpenGL API): glGetIntegerv(GL_ACTIVE_TEXTURE)

      SeeAlso:
        BindToTextureUnit, GetMaxTextureUnits, GetMaxCombinedTextureUnits }
    class function GetActiveTextureUnit: Integer; inline; static;

    { Gets a list of symbolic constants indicating which compressed texture
      formats are available. May be empty.

      Returns:
        A list of compressed texture formats.

      @bold(OpenGL API): glGetIntegerv(GL_NUM_COMPRESSED_TEXTURE_FORMATS/GL_COMPRESSED_TEXTURE_FORMATS)

      SeeAlso:
        UploadCompressed, SubUploadCompressed }
    class function GetCompressedTextureFormats: TArray<Cardinal>; inline; static;

    { Sets an implementation-specific hint for generating mipmaps.

      Parameters:
        AHint: the preference for generating mipmaps.

      @bold(Note): this is a global setting that effects all textures.

      @bold(OpenGL API): glHint

      SeeAlso:
        GenerateMipmap, GetMipmapHint }
    class procedure MipmapHint(const AHint: TGLMipmapHint); inline; static;

    { Gets the current implementation-specific hint for generating mipmaps.

      Returns:
        The mipmap generation preference.

      @bold(OpenGL API): glGetIntegerv(GL_GENERATE_MIPMAP_HINT)

      SeeAlso:
        GenerateMipmap, MipmapHint }
    class function GetMipmapHint: TGLMipmapHint; inline; static;

    { Gets the maximum supported texture image units that can be used to access
      texture maps from the fragment shader. The value must be at least 8.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS)

      SeeAlso:
        BindToTextureUnit, GetMaxCombinedTextureUnits, GetMaxVertexTextureUnits }
    class function GetMaxTextureUnits: Integer; inline; static;

    { Gets the maximum supported texture image units that can be used to access
      texture maps from the vertex shader and the fragment processor combined.
      If both the vertex shader and the fragment processing stage access the
      same texture image unit, then that counts as using two texture image units
      against this limit. The value must be at least 8.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS)

      SeeAlso:
        BindToTextureUnit, GetMaxTextureUnits, GetMaxVertexTextureUnits }
    class function GetMaxCombinedTextureUnits: Integer; inline; static;

    { Gets the maximum supported texture image units that can be used to access
      texture maps from the vertex shader. The value may be 0.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS)

      SeeAlso:
        BindToTextureUnit, GetMaxTextureUnits, GetMaxCombinedTextureUnits }
    class function GetMaxVertexTextureUnits: Integer; inline; static;

    { Gets a rough estimate of the largest texture that the GL can handle. The
      value must be at least 64.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_TEXTURE_SIZE)

      SeeAlso:
        Upload }
    class function GetMaxTextureSize: Integer; inline; static;

    { Gets a rough estimate of the largest cube-map texture that the GL can
      handle. The value must be at least 16.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE)

      SeeAlso:
        Upload }
    class function GetMaxCubeMapTextureSize: Integer; inline; static;

    { OpenGL handle to the texture object. }
    property Handle: GLuint read FHandle;
  end;

type
  { A renderbuffer. Serves as storage for a TGLFramebuffer. }
  TGLRenderbuffer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: GLuint;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a renderbuffer.

      No renderbuffer objects are associated with the returned renderbuffer
      object names until they are first bound by calling Bind.

      @bold(OpenGL API): glGenRenderbuffers

      SeeAlso:
        Bind, Delete }
    procedure New; inline;

    { Deletes the renderbuffer.

      After a renderbuffer object is deleted, it has no contents, and its name
      is free for reuse (for example by New).

      If a renderbuffer object that is currently bound is deleted, the binding
      reverts to 0 (the absence of any renderbuffer object). Additionally,
      special care must be taken when deleting a renderbuffer object if the
      image of the renderbuffer is attached to a framebuffer object. In this
      case, if the deleted renderbuffer object is attached to the currently
      bound framebuffer object, it is automatically detached. However,
      attachments to any other framebuffer objects are the responsibility of the
      application.

      @bold(OpenGL API): glDeleteRenderbuffers

      SeeAlso:
        Bind, New }
    procedure Delete; inline;

    { Binds the renderbuffer.

      A renderbuffer is a data storage object containing a single image of a
      renderable internal format. A renderbuffer's image may be attached to a
      framebuffer object to use as a destination for rendering and as a source
      for reading.

      Bind lets you create or use a named renderbuffer object. When a
      renderbuffer object is bound, the previous binding is automatically
      broken.

      The state of a renderbuffer object immediately after it is first bound is
      a zero-sized memory buffer with format RGBA4 and zero-sized red, green,
      blue, alpha, depth, and stencil pixel depths.

      A renderbuffer object binding created with Bind remains active until a
      different renderbuffer object name is bound, or until the bound
      renderbuffer object is deleted with Delete.

      @bold(OpenGL API): glBindRenderbuffer

      SeeAlso:
        New, Delete, TGLFramebuffer.AttachRenderbuffer, UnBind, IsBound,
        Storage }
    procedure Bind; inline;

    { Unbinds the renderbuffer.

      @bold(OpenGL API): glBindRenderbuffer

      SeeAlso:
        Bind, IsBound }
    procedure Unbind; inline;

    { Checks if this renderbuffer is currently bound.

      Returns:
        True if this is the currently bound renderbuffer, False otherwise. }
    function IsBound: Boolean; inline;

    { Create and initialize a renderbuffer object's data store.

      Parameters:
        AWidth: width of the renderbuffer in pixels
        AHeight: height of the renderbuffer in pixels
        AFormat: (optional) color-renderable, depth-renderable, or stencil-
          renderable format of the renderbuffer. Defaults to RGBA4.

      Raises:
        TGLError.InvalidValue if AWidth or AHeight is less than zero or
          greater than the maximum renderbuffer size
          (see GetMaxRenderbufferSize).
        TGLError.OutOfMemory if the implementation is unable to create a data
          store with the requested AWidth and AHeight.
        TGLError.InvalidOperation if no renderbuffer is bound.

      This method establishes the data storage, format, and dimensions of a
      renderbuffer object's image. Any existing data store for the renderbuffer
      is deleted and the contents of the new data store are undefined.

      An implementation may vary its allocation of internal component resolution
      based on any parameter, but the allocation and chosen internal format must
      not be a function of any other state and cannot be changed once they are
      established. The actual resolution in bits of each component of the
      allocated image can be queried with the Get* methods.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glRenderbufferStorage

      SeeAlso:
        New, Delete, Bind, TGLFramebuffer.AttachRenderbuffer,
        GetMaxRenderbufferSize }
    procedure Storage(const AWidth, AHeight: Integer;
      const AFormat: TGLRenderbufferFormat = TGLRenderbufferFormat.RGBA4); inline;

    { Gets the width of the renderbuffer.

      Returns:
        The width in pixels of the image of the renderbuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_WIDTH)

      SeeAlso:
        Bind, Storage, GetHeight, GetFormat, GetRedSize, GetGreenSize,
        GetBlueSize, GetAlphaSize, GetDepthSize, GetStencilSize }
    function GetWidth: Integer; inline;

    { Gets the height of the renderbuffer.

      Returns:
        The height in pixels of the image of the renderbuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_HEIGHT)

      SeeAlso:
        Bind, Storage, GetWidth, GetFormat, GetRedSize, GetGreenSize,
        GetBlueSize, GetAlphaSize, GetDepthSize, GetStencilSize }
    function GetHeight: Integer; inline;

    { Gets the format of the renderbuffer.

      Returns:
        The color-renderable, depth-renderable, or stencil-renderable format of
        the renderbuffer

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_INTERNAL_FORMAT)

      SeeAlso:
        Bind, Storage, GetWidth, GetHeight, GetRedSize, GetGreenSize,
        GetBlueSize, GetAlphaSize, GetDepthSize, GetStencilSize }
    function GetFormat: TGLRenderbufferFormat; inline;

    { Gets the resolution in bits for the red component.

      Returns:
        The resolution in bits for the red component of the image of the
        renderbuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_RED_SIZE)

      SeeAlso:
        Bind, Storage, GetWidth, GetHeight, GetFormat, GetGreenSize,
        GetBlueSize, GetAlphaSize, GetDepthSize, GetStencilSize }
    function GetRedSize: Integer; inline;

    { Gets the resolution in bits for the green component.

      Returns:
        The resolution in bits for the green component of the image of the
        renderbuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_GREEN_SIZE)

      SeeAlso:
        Bind, Storage, GetWidth, GetHeight, GetFormat, GetRedSize,
        GetBlueSize, GetAlphaSize, GetDepthSize, GetStencilSize }
    function GetGreenSize: Integer; inline;

    { Gets the resolution in bits for the blue component.

      Returns:
        The resolution in bits for the blue component of the image of the
        renderbuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_BLUE_SIZE)

      SeeAlso:
        Bind, Storage, GetWidth, GetHeight, GetFormat, GetGreenSize,
        GetRedSize, GetAlphaSize, GetDepthSize, GetStencilSize }
    function GetBlueSize: Integer; inline;

    { Gets the resolution in bits for the alpha component.

      Returns:
        The resolution in bits for the alpha component of the image of the
        renderbuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_ALPHA_SIZE)

      SeeAlso:
        Bind, Storage, GetWidth, GetHeight, GetFormat, GetGreenSize,
        GetBlueSize, GetRedSize, GetDepthSize, GetStencilSize }
    function GetAlphaSize: Integer; inline;

    { Gets the resolution in bits for the depth component.

      Returns:
        The resolution in bits for the depth component of the image of the
        renderbuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_DEPTH_SIZE)

      SeeAlso:
        Bind, Storage, GetWidth, GetHeight, GetFormat, GetGreenSize,
        GetBlueSize, GetAlphaSize, GetRedSize, GetStencilSize }
    function GetDepthSize: Integer; inline;

    { Gets the resolution in bits for the stencil component.

      Returns:
        The resolution in bits for the stencil component of the image of the
        renderbuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this renderbuffer is not bound.

      @bold(OpenGL API): glGetRenderbufferParameteriv(GL_RENDERBUFFER_STENCIL_SIZE)

      SeeAlso:
        Bind, Storage, GetWidth, GetHeight, GetFormat, GetGreenSize,
        GetBlueSize, GetAlphaSize, GetDepthSize, GetRedSize }
    function GetStencilSize: Integer; inline;

    { Get the renderbuffer that is currently bound.

      Returns:
        The currently bound renderbuffer. Its Handle will be 0 if there is no
        renderbuffer bound.

      @bold(OpenGL API): glGetProgramiv(GL_RENDERBUFFER_BINDING)

      SeeAlso:
        Bind, Unbind, IsBound }
    class function GetCurrent: TGLRenderbuffer; inline; static;

    { Get the largest renderbuffer width and height that the GL can handle. The
      value must be at least 1.

      @bold(OpenGL API): glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE)

      SeeAlso:
        Storage. }
    class function GetMaxRenderbufferSize: Integer; inline; static;

    { OpenGL handle to the renderbuffer object. }
    property Handle: GLuint read FHandle;
  end;

type
  { A framebuffer }
  TGLFramebuffer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: GLuint;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a framebuffer.

      No framebuffer objects are associated with the returned framebuffer object
      names until they are first bound by calling Bind.

      @bold(OpenGL API): glGenFramebuffers

      SeeAlso:
        Bind, Delete }
    procedure New; inline;

    { Deletes the framebuffer.

      After a framebuffer object is deleted, it has no attachments, and its name
      is free for reuse (for example by New). If a framebuffer object that is
      currently bound is deleted, the binding reverts to 0 (the
      window-system-provided framebuffer).

      @bold(OpenGL API): glDeleteFramebuffers

      SeeAlso:
        Bind, New }
    procedure Delete; inline;

    { Returns the current framebuffer.

      @bold(Note): do @bold(not) delete this framebuffer.

      @bold(Note): if you call Current @bold(before) you create any custom
      framebuffers, then the returned value can be regarded as the default
      framebuffer. Note that this is not always the "system" framebuffer, since
      you are not allowed to access that framebuffer on some devices.

      SeeAlso:
        New, Bind }
    class function GetCurrent: TGLFramebuffer; static; inline;

    { Binds the framebuffer.

      Bind lets you create or use a named framebuffer object. When a framebuffer
      object is bound, the previous binding is automatically broken.

      Framebuffer object names are unsigned integers. The value zero is reserved
      to represent the "system" framebuffer provided by the windowing system.
      Framebuffer object names and the corresponding framebuffer object contents
      are local to the shared object space of the current GL rendering context.

      You may use New to generate a new framebuffer object name.

      The state of a framebuffer object immediately after it is first bound is
      three attachment points (ColorAttachment, DepthAttachment, and
      StencilAttachment) each with None as the object type.

      While a framebuffer object name is bound, all rendering to the framebuffer
      (with gl.DrawArrays and gl.DrawElements) and reading from the framebuffer
      (with ReadPixels, TGLTexture.Copy, or TGLTexture.SubCopy) use the images
      attached to the application-created framebuffer object rather than the
      default window-system-provided framebuffer.

      Application created framebuffer objects differ from the default
      window-system-provided framebuffer in a few important ways. First, they
      have modifiable attachment points for a color buffer, a depth buffer, and
      a stencil buffer to which framebuffer attachable images may be attached
      and detached. Second, the size and format of the attached images are
      controlled entirely within the GL and are not affected by window-system
      events, such as pixel format selection, window resizes, and display mode
      changes. Third, when rendering to or reading from an application created
      framebuffer object, the pixel ownership test always succeeds (i.e. they
      own all their pixels). Fourth, there are no visible color buffer
      bitplanes, only a single "off-screen" color image attachment, so there is
      no sense of front and back buffers or swapping. Finally, there is no
      multisample buffer.

      A framebuffer object binding created with Bind remains active until a
      different framebuffer object name is bound, or until the bound framebuffer
      object is deleted with Delete.

      @bold(Note): you cannot unbind a framebuffer. If you want to revert back
      to the default framebuffer, then you should call TGLFramebuffer.GetCurrent
      @bold(before) you generate a new framebuffer. Then you can bind to the
      that framebuffer later to revert back to it.

      @bold(OpenGL API): glBindFramebuffer

      SeeAlso:
        New, Delete, AttachRenderbuffer, AttachTexture, IsBound }
    procedure Bind; inline;

    { Checks if this framebuffer is currently bound.

      Returns:
        True if this is the currently bound framebuffer, False otherwise. }
    function IsBound: Boolean; inline;

    { Return the framebuffer completeness status.

      Returns:
        The completeness status.

      The returned value identifies whether or not the currently bound
      framebuffer is framebuffer complete, and if not, which of the rules of
      framebuffer completeness is violated.

      If the currently bound framebuffer is not framebuffer complete, then it is
      an error to attempt to use the framebuffer for writing or reading. This
      means that rendering commands (gl.Clear, gl.DrawArrays, and
      gl.DrawElements) as well as commands that read the framebuffer
      (ReadPixels, TGLTexture.Copy, and TGLTexture.SubCopy) will generate the
      error InvalidFramebufferOperation if called while the framebuffer is not
      framebuffer complete.

      @bold(Note): it is strongly advised, thought not required, that an
      application call Status to see if the framebuffer is complete prior to
      rendering. This is because some implementations may not support rendering
      to particular combinations of internal formats.

      @bold(Note): the default window-system-provided framebuffer is always
      framebuffer complete, and thus Complete is returned when there is no
      bound application created framebuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glCheckFramebufferStatus

      SeeAlso:
        TGLRenderbuffer.Bind, TGLTexture.Copy, TGLTexture.SubCopy,
        gl.DrawArrays, gl.DrawElements, ReadPixels, TGLRenderbuffer.Storage }
    function Status: TGLFramebufferStatus; inline;

    { Attach a renderbuffer to this framebuffer.

      Parameters:
        AAttachment: the attachment point to which ARenderbuffer should be
          attached.
        ARenderbuffer: the renderbuffer to attach.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.

      This method attaches the renderbuffer specified by ARenderbuffer as one of
      the logical buffers of the currently bound framebuffer object. AAttachment
      specifies whether the renderbuffer should be attached to the framebuffer
      object's color, depth, or stencil buffer. A renderbuffer may not be
      attached to the default framebuffer object name 0.

      @bold(Note): if a renderbuffer object is deleted while its image is
      attached to the currently bound framebuffer, then it is as if
      DetachRenderbuffer had been called for the attachment point to which this
      image was attached in the currently bound framebuffer object. In other
      words, the renderbuffer image is detached from the currently bound
      framebuffer. Note that the renderbuffer image is specifically not detached
      from any non-bound framebuffers. Detaching the image from any non-bound
      framebuffers is the responsibility of the application.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glFramebufferRenderbuffer

      SeeAlso:
        DetachRenderbuffer, Bind, TGLRenderbuffer.Bind, Status, Delete,
        TGLRenderbuffer.Delete, AttachTexture, TGLRenderbuffer.Storage }
    procedure AttachRenderbuffer(const AAttachment: TGLFramebufferAttachment;
      const ARenderbuffer: TGLRenderbuffer); inline;

    { Detach a renderbuffer from this framebuffer.

      Parameters:
        AAttachment: the attachment point from which the renderbuffer should be
          detached.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glFramebufferRenderbuffer

      SeeAlso:
        AttachRenderbuffer }
    procedure DetachRenderbuffer(const AAttachment: TGLFramebufferAttachment); inline;

    { Attach a texture to this framebuffer.

      Parameters:
        AAttachment: the attachment point to which ATexture should be
          attached.
        ATexture: the texture to attach.
        ACubeTarget: (optional) if this ATexture is a cube texture, then this
          parameter specifies which of the 6 cube faces to attach. This
          parameter is ignored for 2D textures.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.

      This method attaches the texture image specified by ATexture as one of the
      logical buffers of the currently bound framebuffer object. AAttachment
      specifies whether the texture image should be attached to the framebuffer
      object's color, depth, or stencil buffer. A texture image may not be
      attached to the default framebuffer object name 0.

      @bold(Note): special precautions need to be taken to avoid attaching a
      texture image to the currently bound framebuffer while the texture object
      is currently bound and potentially sampled by the current vertex or
      fragment shader. Doing so could lead to the creation of a "feedback loop"
      between the writing of pixels by rendering operations and the simultaneous
      reading of those same pixels when used as texels in the currently bound
      texture. In this scenario, the framebuffer will be considered framebuffer
      complete, but the values of fragments rendered while in this state will be
      undefined. The values of texture samples may be undefined as well.

      @bold(Note): if a texture object is deleted while its image is attached to
      the currently bound framebuffer, then it is as if DetachTexture had been
      called for the attachment point to which this image was attached in the
      currently bound framebuffer object. In other words, the texture image is
      detached from the currently bound framebuffer. Note that the texture image
      is specifically not detached from any non-bound framebuffers. Detaching
      the image from any non-bound framebuffers is the responsibility of the
      application.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glFramebufferTexture2D

      SeeAlso:
        DetachTexture, Bind, TGLTexture.Bind, Status, Delete,
        TGLTexture.Delete, AttachRenderbuffer, TGLTexture.GenerateMipmap,
        TGLTexture.Upload }
    procedure AttachTexture(const AAttachment: TGLFramebufferAttachment;
      const ATexture: TGLTexture; const ACubeTarget: TGLCubeTarget = 0); inline;

    { Detach a texture from this framebuffer.

      Parameters:
        AAttachment: the attachment point from which the texture should be
          detached.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glFramebufferTexture2D

      SeeAlso:
        AttachTexture }
    procedure DetachTexture(const AAttachment: TGLFramebufferAttachment); inline;

    { Returns the type of object attached to an attachment point of the
      framebuffer.

      Parameters:
        AAttachment: the attachment point to check.

      Returns:
        The type of attachment attached to this point.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE)

      SeeAlso:
        Bind, AttachRenderbuffer, AttachTexture, GetAttachedTexture,
        GetAttachedRenderbuffer, GetAttachedTextureLevel,
        GetAttachedCubeMapFace }
    function GetAttachedObjectType(const AAttachment: TGLFramebufferAttachment): TGLFramebufferAttachmentType; inline;

    { Returns the texture attached to an attachment point of the framebuffer.

      Parameters:
        AAttachment: the attachment point to check.

      Returns:
        The texture attached to this point.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.
        TGLError.InvalidOperation if no texture is attached to the given
          attachment point.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME)

      SeeAlso:
        Bind, AttachRenderbuffer, AttachTexture, GetAttachedObjectType,
        GetAttachedRenderbuffer, GetAttachedTextureLevel,
        GetAttachedCubeMapFace }
    function GetAttachedTexture(const AAttachment: TGLFramebufferAttachment): TGLTexture; inline;

    { Returns the renderbuffer attached to an attachment point of the
      framebuffer.

      Parameters:
        AAttachment: the attachment point to check.

      Returns:
        The renderbuffer attached to this point.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.
        TGLError.InvalidOperation if no renderbuffer is attached to the given
          attachment point.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME)

      SeeAlso:
        Bind, AttachRenderbuffer, AttachTexture, GetAttachedObjectType,
        GetAttachedTexture, GetAttachedTextureLevel, GetAttachedCubeMapFace }
    function GetAttachedRenderbuffer(const AAttachment: TGLFramebufferAttachment): TGLRenderbuffer; inline;

    { Returns the mipmap level of the texture attached to an attachment point of
      the framebuffer.

      Parameters:
        AAttachment: the attachment point to check.

      Returns:
        The mipmap level of texture attached to this point.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.
        TGLError.InvalidOperation if no texture is attached to the given
          attachment point.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL)

      SeeAlso:
        Bind, AttachRenderbuffer, AttachTexture, GetAttachedObjectType,
        GetAttachedRenderbuffer, GetAttachedTexture, GetAttachedCubeMapFace }
    function GetAttachedTextureLevel(const AAttachment: TGLFramebufferAttachment): Integer; inline;

    { Returns the cube map face of the cube-map texture attached to an
      attachment point of the framebuffer.

      Parameters:
        AAttachment: the attachment point to check.

      Returns:
        The cube map face of texture attached to this point.

      Raises:
        TGLError.InvalidOperation if no framebuffer is bound.
        TGLError.InvalidOperation if no texture is attached to the given
          attachment point.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE)

      SeeAlso:
        Bind, AttachRenderbuffer, AttachTexture, GetAttachedObjectType,
        GetAttachedRenderbuffer, GetAttachedTexture, GetAttachedTextureLevel }
    function GetAttachedCubeMapFace(const AAttachment: TGLFramebufferAttachment): TGLCubeTarget; inline;

    { Read a block of pixels from the frame buffer.

      Parameters:
        ALeft: left window coordinate of the first pixel that is read from the
          framebuffer.
        ABottom: bottom window coordinate of the first pixel that is read from
          the framebuffer.
        AWidth: width of the rectangle in pixels.
        AHeight: height of the rectangle in pixels.
        AData: pointer to the pixel data to be filled.
        AFormat: (optional) format of the pixels to return. Only Alpha, RGB and
          RGBA are supported. Defaults to RGBA.
        ADataType: (optional) data type of the pixels to return. Defaults to
          UnsignedByte.

      Raises:
        TGLError.InvalidEnum if AFormat or ADataType is not an accepted value.
        TGLError.InvalidValue if either AWidth or AHeight is negative.
        TGLError.InvalidOperation if ADataType is UnsignedShort565 and AFormat
          is not RGB.
        TGLError.InvalidOperation if ADataType is UnsignedShort4444
          or UnsignedShort5551 and AFormat is not RGBA.
        TGLError.InvalidOperation if AFormat and ADataType are
          neither RGBA UnsignedByte, respectively, nor the AFormat/ADataType
          pair returned by calling GetColorReadFormat and GetColorReadType.
        TGLError.InvalidFramebufferOperation if the framebuffer is not
          framebuffer complete.

      This method returns pixel data from the frame buffer, starting with the
      pixel whose lower left corner is at location (ALeft, ABottom), into client
      memory starting at location AData. The TGLPixelStoreMode.PackAlignment
      parameter, set with the gl.PixelStore command, affects the processing of
      the pixel data before it is placed into client memory.

      Pixels are returned in row order from the lowest to the highest row, left
      to right in each row.

      AFormat specifies the format for the returned pixel values. RGBA color
      components are read from the color buffer. Each color component is
      converted to floating point such that zero intensity maps to 0.0 and full
      intensity maps to 1.0.

      Unneeded data is then discarded. For example, TGLPixelFormat.Alpha
      discards the red, green, and blue components, while PackAlignment.RGB
      discards only the alpha component. The final values are clamped to the
      range 0..1.

      Finally, the components are converted to the proper format, as specified
      by ADataType. When type is TGLPixelDataType.UnsignedByte (the default),
      each component is multiplied by 255. When ADataType is
      TGLPixelDataType.UnsignedShort565, UnsignedShort4444 or
      UnsignedShort5551, each component is multiplied accordingly.

      @bold(Note): if the currently bound framebuffer is not the default
      framebuffer object, color components are read from the color image
      attached to the TGLFramebufferAttachment.Color attachment point.

      @bold(Note): only two AFormat/ADataType parameter pairs are accepted.
      TGLPixelFormat.RGBA/TGLPixelDataType.UnsignedByte is always accepted, and
      the other acceptable pair can be discovered by calling
      GetColorReadFormat and GetColorReadType.

      @bold(Note): values for pixels that lie outside the window connected to
      the current GL context are undefined.

      @bold(Note): if an error is generated, no change is made to the contents
      of data.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glReadPixels

      SeeAlso:
        GetColorReadFormat, GetColorReadType, gl.PixelStore, gl.GetPixelStore,
        Status }
    procedure ReadPixels(const ALeft, ABottom, AWidth, AHeight: Integer;
      const AData: Pointer; const AFormat: TGLPixelFormat = TGLPixelFormat.RGBA;
      const ADataType: TGLPixelDataType = TGLPixelDataType.UnsignedByte); inline;

    { Get the number of red bitplanes in the color buffer of the framebuffer.

      Returns:
        The number of red bitplanes.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetIntegerv(GL_RED_BITS)

      SeeAlso:
        GetGreenBits, GetBlueBits, GetAlphaBits, GetDepthBits, GetStencilBits }
    function GetRedBits: Integer; inline;

    { Get the number of green bitplanes in the color buffer of the framebuffer.

      Returns:
        The number of green bitplanes.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetIntegerv(GL_GREEN_BITS)

      SeeAlso:
        GetRedBits, GetBlueBits, GetAlphaBits, GetDepthBits, GetStencilBits }
    function GetGreenBits: Integer; inline;

    { Get the number of blue bitplanes in the color buffer of the framebuffer.

      Returns:
        The number of blue bitplanes.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetIntegerv(GL_BLUE_BITS)

      SeeAlso:
        GetGreenBits, GetRedBits, GetAlphaBits, GetDepthBits, GetStencilBits }
    function GetBlueBits: Integer; inline;

    { Get the number of alpha bitplanes in the color buffer of the framebuffer.

      Returns:
        The number of alpha bitplanes.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetIntegerv(GL_ALPHA_BITS)

      SeeAlso:
        GetGreenBits, GetBlueBits, GetRedBits, GetDepthBits, GetStencilBits }
    function GetAlphaBits: Integer; inline;

    { Get the number of bitplanes in the depth buffer of the framebuffer.

      Returns:
        The number of bitplanes in the depth buffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetIntegerv(GL_DEPTH_BITS)

      SeeAlso:
        GetGreenBits, GetBlueBits, GetAlphaBits, GetRedBits, GetStencilBits }
    function GetDepthBits: Integer; inline;

    { Get the number of bitplanes in the stencil buffer of the framebuffer.

      Returns:
        The number of bitplanes in the stencil buffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetIntegerv(GL_STENCIL_BITS)

      SeeAlso:
        GetGreenBits, GetBlueBits, GetAlphaBits, GetRedBits, GetRedBits }
    function GetStencilBits: Integer; inline;

    { Get the number of sample buffers associated with the framebuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetIntegerv(GL_SAMPLE_BUFFERS)

      SeeAlso:
        gl.SampleCoverage }
    function GetSampleBuffers: Integer; inline;

    { Get the coverage mask size of the framebuffer.

      @bold(Note): in DEBUG mode with assertions enabled, an error will be
      logged to the debug console if this framebuffer is not bound.

      @bold(OpenGL API): glGetIntegerv(GL_SAMPLES)

      SeeAlso:
        gl.SampleCoverage }
    function GetSamples: Integer; inline;

    { Get the format chosen by the implementation in which pixels may be read
      from the color buffer of the currently bound framebuffer in conjunction
      with GetColorReadType. In addition to this implementation-dependent
      format/type pair, format RGBA in conjunction with type UnsingedByte is
      always allowed by every implementation, regardless of the currently bound
      render surface.

      @bold(Note): this is a global value that affects all framebuffers.

      @bold(OpenGL API): glGetIntegerv(GL_IMPLEMENTATION_COLOR_READ_FORMAT)

      SeeAlso:
        ReadPixels, GetColorReadType }
    class function GetColorReadFormat: TGLPixelFormat; inline; static;

    { Get the type chosen by the implementation with which pixels may be read
      from the color buffer of the currently bound framebuffer in conjunction
      with GetColorReadFormat. In addition to this implementation-dependent
      format/type pair, format RGBA in conjunction with type UnsingedByte is
      always allowed by every implementation, regardless of the currently bound
      render surface.

      @bold(Note): this is a global value that affects all framebuffers.

      @bold(OpenGL API): glGetIntegerv(GL_IMPLEMENTATION_COLOR_READ_TYPE)

      SeeAlso:
        ReadPixels, GetColorReadFormat }
    class function GetColorReadType: TGLPixelDataType; inline; static;

    { OpenGL handle to the framebuffer object. }
    property Handle: GLuint read FHandle;
  end;

{$REGION 'Internal Declarations'}
{$IFDEF DEBUG}
{ @exclude }
procedure _DebugLog(const AMsg: String); overload;
{ @exclude }
procedure _DebugLog(const AMsg: String; const AArgs: array of const); overload;
{$ENDIF}

{$IFOPT C+}
{ @exclude }
function _Check(const AMethod: String): Boolean;
{ @exclude }
function _CheckBinding(const ATarget: GLenum; const AMethodName: String): Boolean; overload;
{ @exclude }
function _CheckBinding(const ATarget: GLenum; const AExpectedBinding: GLint;
  const AMethodName: String): Boolean; overload;
{ @exclude }
function _GetTargetBinding(const ATarget: GLenum): GLenum;
{$ENDIF}
{$ENDREGION 'Internal Declarations'}

implementation

uses
  System.Classes,
  System.TypInfo

{$IFDEF DEBUG}
{$IF Defined(MSWINDOWS)}
  ,Winapi.Windows;

procedure _DebugLog(const AMsg: String); overload;
begin
  OutputDebugString(PChar(AMsg));
end;
{$ELSEIF Defined(IOS)}
  ,Macapi.Helpers,
  Macapi.ObjectiveC,
  iOSapi.Foundation;

procedure _DebugLog(const AMsg: String); overload;
begin
  NSLog((StrToNSStr(AMsg) as ILocalObject).GetObjectID);
end;
{$ELSEIF Defined(ANDROID)}
  ,Androidapi.Log;

procedure _DebugLog(const AMsg: String); overload;
var
  M: TMarshaller;
begin
  LOGI(M.AsUtf8(AMsg).ToPointer);
end;
{$ELSEIF Defined(MACOS)}
  ,Macapi.Helpers,
  Macapi.ObjectiveC;

const
  FoundationFwk = '/System/Library/Frameworks/Foundation.framework/Foundation';

{ NSLog is not imported for OSX by Embarcadero }
procedure NSLog(S: Pointer); varargs; cdecl; external FoundationFwk name '_NSLog';

procedure _DebugLog(const AMsg: String); overload;
begin
  NSLog((StrToNSStr(AMsg) as ILocalObject).GetObjectID);
end;
{$ENDIF}

procedure _DebugLog(const AMsg: String; const AArgs: array of const); overload;
begin
  _DebugLog(Format(AMsg, AArgs));
end;
{$ELSE !DEBUG}
  ;
{$ENDIF DEBUG}

procedure InitOoogles;
begin
  {$IFDEF DESKTOP_OPENGL}
  { In OpenGL-ES, point sprites are always enable. On desktop OpenGL, it must
    be enabled manually. So we do that here for compatibility. }
  {$IFDEF MACOS}
  glenable(GL_PROGRAM_POINT_SIZE_EXT);
  {$ELSE}
  glenable(GL_PROGRAM_POINT_SIZE);
  {$ENDIF}
  glenable(GL_POINT_SPRITE);
  {$ENDIF}
end;

{$IF Defined(MACOS) and not Defined(IOS)}
const
  GL_MAX_VARYING_VECTORS = $8DFC;
  GL_MAX_FRAGMENT_UNIFORM_VECTORS = $8DFD;
  GL_MAX_VERTEX_UNIFORM_VECTORS = $8DFB;
  GL_IMPLEMENTATION_COLOR_READ_FORMAT = $8B9B;
  GL_IMPLEMENTATION_COLOR_READ_TYPE = $8B9A;
{$ENDIF}

function _GetTargetBinding(const ATarget: GLenum): GLenum;
begin
  case ATarget of
    GL_ARRAY_BUFFER:
      Result := GL_ARRAY_BUFFER_BINDING;

    GL_ELEMENT_ARRAY_BUFFER:
      Result := GL_ELEMENT_ARRAY_BUFFER_BINDING;

    GL_TEXTURE_2D:
      Result := GL_TEXTURE_BINDING_2D;

    GL_TEXTURE_CUBE_MAP:
      Result := GL_TEXTURE_BINDING_CUBE_MAP;

    GL_RENDERBUFFER:
      Result := GL_RENDERBUFFER_BINDING;

    GL_FRAMEBUFFER:
      Result := GL_FRAMEBUFFER_BINDING;
  else
    Assert(False);
    Result := 0;
  end;
end;

{$IFOPT C+}
{$IFDEF DEBUG}
function _Check(const AMethod: String): Boolean;
var
  Error: GLenum;
begin
  Error := glGetError;
  if (Error <> GL_NO_ERROR) then
    raise EGLError.Create(Error, AMethod);

  { Always return True so no Assertion exception is raised. }
  Result := True;
end;

function GetTargetName(const ATarget: GLenum): String;
begin
  case ATarget of
    GL_ARRAY_BUFFER:
      Result := 'TGLBufferType.Vertex';

    GL_ELEMENT_ARRAY_BUFFER:
      Result := 'TGLBufferType.Index';

    GL_TEXTURE_2D:
      Result := 'TGLTextureType.TwoD';

    GL_TEXTURE_CUBE_MAP:
      Result := 'TGLTextureType.CubeMap';

    GL_RENDERBUFFER:
      Result := 'TGLRenderbuffer';

    GL_FRAMEBUFFER:
      Result := 'TGLFramebuffer';
  else
    Assert(False);
    Result := Format('(unknown %d)', [ATarget]);
  end;
end;

function _CheckBinding(const ATarget: GLenum; const AMethodName: String): Boolean;
var
  CurrentBinding: GLint;
begin
  glGetIntegerv(_GetTargetBinding(ATarget), @CurrentBinding);
  if (CurrentBinding = 0) then
    _DebugLog('The method "%s" requires an object bound to "%s", '+
      'but no object is bound to that target', [AMethodName, GetTargetName(ATarget)]);

  { Always return True so no Assertion exception is raised. }
  Result := True;
end;

function _CheckBinding(const ATarget: GLenum; const AExpectedBinding: GLint;
  const AMethodName: String): Boolean;
var
  CurrentBinding: GLint;
begin
  glGetIntegerv(_GetTargetBinding(ATarget), @CurrentBinding);
  if (CurrentBinding <> AExpectedBinding) then
    _DebugLog('The method "%s" requires the current object bound to "%s", '+
      'but another object is bound to that target', [AMethodName, GetTargetName(ATarget)]);

  { Always return True so no Assertion exception is raised. }
  Result := True;
end;
{$ELSE !DEBUG}
function _Check(const AMethod: String): Boolean;
begin
  { Don't perform error checking if DEBUG is not defined. }
  Result := True;
end;

function _CheckBinding(const ATarget: GLenum; const AMethodName: String): Boolean; overload;
begin
  { Don't perform error checking if DEBUG is not defined. }
  Result := True;
end;

function _CheckBinding(const ATarget: GLenum; const AExpectedBinding: GLint;
  const AMethodName: String): Boolean; overload;
begin
  { Don't perform error checking if DEBUG is not defined. }
  Result := True;
end;
{$ENDIF DEBUG}
{$ENDIF C+}

{ EGLError }

constructor EGLError.Create(const AErrorCode: Integer; const AMethod: String);
var
  Msg: String;
  Error: TGLError;
begin
  Error := TGLError(AErrorCode);
  case AErrorCode of
    GL_INVALID_ENUM                 : Msg := 'Invalid Enum';
    GL_INVALID_VALUE                : Msg := 'Invalid Value';
    GL_INVALID_OPERATION            : Msg := 'Invalid Operation';
    GL_OUT_OF_MEMORY                : Msg := 'Out of Memory';
    GL_INVALID_FRAMEBUFFER_OPERATION: Msg := 'Invalid Framebuffer Operation';
  else
    Msg := IntToHex(AErrorCode, 4);
  end;

  inherited CreateFmt('OpenGL error "%s" in method "%s"', [Msg, AMethod]);

  FError := Error;
  FErrorMethod := AMethod;
end;

{ gl }

class procedure gl.BlendColor(const ARed, AGreen, ABlue, AAlpha: Single);
begin
  glBlendColor(ARed, AGreen, ABlue, AAlpha);
  Assert(_Check('gl.BlendColor'));
end;

class procedure gl.BlendColor(const AColor: TVector4);
begin
  glBlendColor(AColor.R, AColor.G, AColor.B, AColor.A);
  Assert(_Check('gl.BlendColor'));
end;

class procedure gl.BlendEquation(const AEquation: TGLBlendEquation);
begin
  glBlendEquation(Ord(AEquation));
  Assert(_Check('gl.BlendEquation'));
end;

class procedure gl.BlendEquationSeparate(const AEquationRgb,
  AEquationAlpha: TGLBlendEquation);
begin
  glBlendEquationSeparate(Ord(AEquationRgb), Ord(AEquationAlpha));
  Assert(_Check('gl.BlendEquationSeparate'));
end;

class procedure gl.BlendFunc(const ASrcFactor, ADstFactor: TGLBlendFunc);
begin
  glBlendFunc(Ord(ASrcFactor), Ord(ADstFactor));
  Assert(_Check('gl.BlendFunc'));
end;

class procedure gl.BlendFuncSeparate(const ASrcRgb, ADstRgb, ASrcAlpha,
  ADstAlpha: TGLBlendFunc);
begin
  glBlendFuncSeparate(Ord(ASrcRgb), Ord(ADstRgb), Ord(ASrcAlpha), Ord(ADstAlpha));
  Assert(_Check('gl.BlendFuncSeparate'));
end;

class procedure gl.Clear(const ABuffers: TGLClearBuffers);
begin
  glClear(Word(ABuffers));
  Assert(_Check('gl.Clear'));
end;

class procedure gl.ClearColor(const ARed, AGreen, ABlue, AAlpha: Single);
begin
  glClearColor(ARed, AGreen, ABlue, AAlpha);
  Assert(_Check('gl.ClearColor'));
end;

class procedure gl.ClearColor(const AColor: TVector4);
begin
  glClearColor(AColor.R, AColor.G, AColor.B, AColor.A);
  Assert(_Check('gl.ClearColor'));
end;

class procedure gl.ClearDepth(const ADepth: Single);
begin
  {$IF Defined(MACOS) and (not Defined(IOS))}
  glClearDepth(ADepth);
  {$ELSE}
  glClearDepthf(ADepth);
  {$ENDIF}
  Assert(_Check('gl.ClearDepth'));
end;

class procedure gl.ClearStencil(const AIndex: Integer);
begin
  glClearStencil(AIndex);
  Assert(_Check('gl.ClearStencil'));
end;

class procedure gl.ColorMask(const ARed, AGreen, ABlue, AAlpha: Boolean);
begin
  glColorMask(Ord(ARed), Ord(AGreen), Ord(ABlue), Ord(AAlpha));
  Assert(_Check('gl.ColorMask'));
end;

class procedure gl.CullFace(const AMode: TGLFace);
begin
  glCullFace(Ord(AMode));
  Assert(_Check('gl.CullFace'));
end;

class procedure gl.DepthFunc(const AFunc: TGLCompareFunc);
begin
  glDepthFunc(Ord(AFunc));
  Assert(_Check('gl.DepthFunc'));
end;

class procedure gl.DepthMask(const AEnable: Boolean);
begin
  glDepthMask(Ord(AEnable));
  Assert(_Check('gl.DepthMask'));
end;

class procedure gl.DepthRange(const ANearVal, AFarVal: Single);
begin
  {$IF Defined(MACOS) and not Defined(IOS)}
  glDepthRange(ANearVal, AFarVal);
  {$ELSE}
  glDepthRangef(ANearVal, AFarVal);
  {$ENDIF}
  Assert(_Check('gl.DepthRange'));
end;

class procedure gl.Disable(const ACapability: TGLCapability);
begin
  glDisable(Ord(ACapability));
  Assert(_Check('gl.Disable'));
end;

class procedure gl.DrawArrays(const AType: TGLPrimitiveType;
  const ACount: Integer);
begin
  glDrawArrays(Ord(AType), 0, ACount);
  Assert(_Check('gl.DrawArrays'));
end;

class procedure gl.DrawArrays(const AType: TGLPrimitiveType;
  const AFirst, ACount: Integer);
begin
  glDrawArrays(Ord(AType), AFirst, ACount);
  Assert(_Check('gl.DrawArrays'));
end;

class procedure gl.DrawElements(const AType: TGLPrimitiveType;
  const ACount: Integer; const AIndexType: TGLIndexType);
begin
  glDrawElements(Ord(AType), ACount, Ord(AIndexType), nil);
  Assert(_Check('gl.DrawElements'));
end;

class procedure gl.DrawElements(const AType: TGLPrimitiveType;
  const AIndices: TArray<UInt8>; const AFirst, ACount: Integer);
var
  Count: Integer;
begin
  if (ACount = 0) then
    Count := Length(AIndices) - AFirst
  else
    Count := ACount;

  glDrawElements(Ord(AType), Count, GL_UNSIGNED_BYTE, @AIndices[AFirst]);
  Assert(_Check('gl.DrawElements'));
end;

class procedure gl.DrawElements(const AType: TGLPrimitiveType;
  const AIndices: array of UInt8; const AFirst, ACount: Integer);
var
  Count: Integer;
begin
  if (ACount = 0) then
    Count := Length(AIndices) - AFirst
  else
    Count := ACount;

  glDrawElements(Ord(AType), Count, GL_UNSIGNED_BYTE, @AIndices[AFirst]);
  Assert(_Check('gl.DrawElements'));
end;

class procedure gl.DrawElements(const AType: TGLPrimitiveType;
  const AIndices: TArray<UInt16>; const AFirst, ACount: Integer);
var
  Count: Integer;
begin
  if (ACount = 0) then
    Count := Length(AIndices) - AFirst
  else
    Count := ACount;

  glDrawElements(Ord(AType), Count, GL_UNSIGNED_SHORT, @AIndices[AFirst]);
  Assert(_Check('gl.DrawElements'));
end;

class procedure gl.DrawElements(const AType: TGLPrimitiveType;
  const AIndices: array of UInt16; const AFirst, ACount: Integer);
var
  Count: Integer;
begin
  if (ACount = 0) then
    Count := Length(AIndices) - AFirst
  else
    Count := ACount;

  glDrawElements(Ord(AType), Count, GL_UNSIGNED_SHORT, @AIndices[AFirst]);
  Assert(_Check('gl.DrawElements'));
end;

class procedure gl.Enable(const ACapability: TGLCapability);
begin
  glEnable(Ord(ACapability));
  Assert(_Check('gl.Enable'));
end;

class procedure gl.Finish;
begin
  glFinish;
  Assert(_Check('gl.Finish'));
end;

class procedure gl.Flush;
begin
  glFlush;
  Assert(_Check('gl.Flush'));
end;

class procedure gl.FrontFace(const AOrientation: TGLFaceOrientation);
begin
  glFrontFace(Ord(AOrientation));
  Assert(_Check('gl.FrontFace'));
end;

class procedure gl.GetAliasedLineWidthRange(out AMin, AMax: Single);
var
  Values: array [0..1] of Single;
begin
  glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, @Values);
  Assert(_Check('gl.GetAliasedLineWidthRange'));
  AMin := Values[0];
  AMax := Values[1];
end;

class procedure gl.GetAliasedPointSizeRange(out AMin, AMax: Single);
var
  Values: array [0..1] of Single;
begin
  glGetFloatv(GL_ALIASED_POINT_SIZE_RANGE, @Values);
  Assert(_Check('gl.GetAliasedPointSizeRange'));
  AMin := Values[0];
  AMax := Values[1];
end;

class function gl.GetBlendColor: TVector4;
begin
  glGetFloatv(GL_BLEND_COLOR, @Result);
  Assert(_Check('gl.GetBlendColor'));
end;

class function gl.GetBlendDstAlpha: TGLBlendFunc;
var
  Value: GLint;
begin
  glGetIntegerv(GL_BLEND_DST_ALPHA, @Value);
  Assert(_Check('gl.GetBlendDstAlpha'));
  Result := TGLBlendFunc(Value);
end;

class function gl.GetBlendDstRgb: TGLBlendFunc;
var
  Value: GLint;
begin
  glGetIntegerv(GL_BLEND_DST_RGB, @Value);
  Assert(_Check('gl.GetBlendDstRgb'));
  Result := TGLBlendFunc(Value);
end;

class function gl.GetBlendEquationAlpha: TGLBlendEquation;
var
  Value: GLint;
begin
  glGetIntegerv(GL_BLEND_EQUATION_ALPHA, @Value);
  Assert(_Check('gl.GetBlendEquationAlpha'));
  Result := TGLBlendEquation(Value);
end;

class function gl.GetBlendEquationRgb: TGLBlendEquation;
var
  Value: GLint;
begin
  glGetIntegerv(GL_BLEND_EQUATION_RGB, @Value);
  Assert(_Check('gl.GetBlendEquationRgb'));
  Result := TGLBlendEquation(Value);
end;

class function gl.GetBlendSrcAlpha: TGLBlendFunc;
var
  Value: GLint;
begin
  glGetIntegerv(GL_BLEND_SRC_ALPHA, @Value);
  Assert(_Check('gl.GetBlendSrcAlpha'));
  Result := TGLBlendFunc(Value);
end;

class function gl.GetBlendSrcRgb: TGLBlendFunc;
var
  Value: GLint;
begin
  glGetIntegerv(GL_BLEND_SRC_RGB, @Value);
  Assert(_Check('gl.GetBlendSrcRgb'));
  Result := TGLBlendFunc(Value);
end;

class function gl.GetClearColor: TVector4;
begin
  glGetFloatv(GL_COLOR_CLEAR_VALUE, @Result);
  Assert(_Check('gl.GetClearColor'));
end;

class function gl.GetClearDepth: Single;
begin
  glGetFloatv(GL_DEPTH_CLEAR_VALUE, @Result);
  Assert(_Check('gl.GetClearDepth'));
end;

class function gl.GetClearStencil: Integer;
begin
  glGetIntegerv(GL_STENCIL_CLEAR_VALUE, @Result);
  Assert(_Check('gl.GetClearStencil'));
end;

class procedure gl.GetColorMask(out ARed, AGreen, ABlue, AAlpha: Boolean);
var
  Values: array [0..3] of GLint;
begin
  glGetIntegerv(GL_COLOR_WRITEMASK, @Values);
  Assert(_Check('gl.GetColorMask'));
  ARed := (Values[0] = GL_TRUE);
  AGreen := (Values[1] = GL_TRUE);
  ABlue := (Values[2] = GL_TRUE);
  AAlpha := (Values[3] = GL_TRUE);
end;

class function gl.GetCullFace: TGLFace;
var
  Value: GLint;
begin
  glGetIntegerv(GL_CULL_FACE_MODE, @Value);
  Assert(_Check('gl.GetCullFace'));
  Result := TGLFace(Value);
end;

class function gl.GetDepthFunc: TGLCompareFunc;
var
  Value: GLint;
begin
  glGetIntegerv(GL_DEPTH_FUNC, @Value);
  Assert(_Check('gl.GetDepthFunc'));
  Result := TGLCompareFunc(Value);
end;

class function gl.GetDepthMask: Boolean;
var
  Value: GLint;
begin
  glGetIntegerv(GL_DEPTH_WRITEMASK, @Value);
  Assert(_Check('gl.GetDepthMask'));
  Result := (Value = GL_TRUE);
end;

class procedure gl.GetDepthRange(out ANearVal, AFarVal: Single);
var
  Values: array [0..1] of GLfloat;
begin
  glGetFloatv(GL_DEPTH_RANGE, @Values);
  Assert(_Check('gl.GetDepthRange'));
  ANearVal := Values[0];
  AFarVal := Values[0];
end;

class function gl.GetError: TGLError;
begin
  Result := TGLError(glGetError);
end;

class function gl.GetExtensions: RawByteString;
begin
  Result := GetString(GL_EXTENSIONS);
  Assert(_Check('gl.GetExtensions'));
end;

class function gl.GetFrontFace: TGLFaceOrientation;
var
  Value: GLint;
begin
  glGetIntegerv(GL_FRONT_FACE, @Value);
  Assert(_Check('gl.GetFrontFace'));
  Result := TGLFaceOrientation(Value);
end;

class function gl.GetLineWidth: Single;
begin
  glGetFloatv(GL_LINE_WIDTH, @Result);
  Assert(_Check('gl.GetLineWidth'));
end;

class procedure gl.GetMaxViewportDimensions(out AMaxWidth, AMaxHeight: Integer);
var
  Data: array [0..1] of GLint;
begin
  glGetIntegerv(GL_MAX_VIEWPORT_DIMS, @Data);
  Assert(_Check('gl.GetMaxViewportDimensions'));
  AMaxWidth := Data[0];
  AMaxHeight := Data[1];
end;

class function gl.GetPixelStore(
  const AMode: TGLPixelStoreMode): TGLPixelStoreValue;
var
  Value: GLint;
begin
  glGetIntegerv(Ord(AMode), @Value);
  Assert(_Check('gl.GetPixelStore'));
  Result := TGLPixelStoreValue(Value);
end;

class function gl.GetPolygonOffsetFactor: Single;
begin
  glGetIntegerv(GL_POLYGON_OFFSET_FACTOR, @Result);
  Assert(_Check('gl.GetPolygonOffsetFactor'));
end;

class function gl.GetPolygonOffsetUnits: Single;
begin
  glGetIntegerv(GL_POLYGON_OFFSET_UNITS, @Result);
  Assert(_Check('gl.GetPolygonOffsetUnits'));
end;

class function gl.GetRenderer: RawByteString;
begin
  Result := GetString(GL_RENDERER);
  Assert(_Check('gl.GetRenderer'));
end;

class function gl.GetSampleAlphaToCoverage: Boolean;
var
  Value: GLint;
begin
  glGetIntegerv(GL_SAMPLE_ALPHA_TO_COVERAGE, @Value);
  Assert(_Check('gl.GetSampleAlphaToCoverage'));
  Result := (Value = GL_TRUE);
end;

class function gl.GetSampleCoverage: Boolean;
var
  Value: GLint;
begin
  glGetIntegerv(GL_SAMPLE_COVERAGE, @Value);
  Assert(_Check('gl.GetSampleCoverage'));
  Result := (Value = GL_TRUE);
end;

class function gl.GetSampleCoverageInvert: Boolean;
var
  Value: GLint;
begin
  glGetIntegerv(GL_SAMPLE_COVERAGE_INVERT, @Value);
  Assert(_Check('gl.GetSampleCoverageInvert'));
  Result := (Value = GL_TRUE);
end;

class function gl.GetSampleCoverageValue: Single;
begin
  glGetFloatv(GL_SAMPLE_COVERAGE_VALUE, @Result);
  Assert(_Check('gl.GetSampleCoverageValue'));
end;

class procedure gl.GetScissor(out ALeft, ABottom, AWidth, AHeight: Integer);
var
  Data: array [0..3] of GLint;
begin
  glGetIntegerv(GL_SCISSOR_BOX, @Data);
  Assert(_Check('gl.GetScissor'));
  ALeft := Data[0];
  ABottom := Data[1];
  AWidth := Data[2];
  AHeight := Data[3];
end;

class function gl.GetShadingLanguageVersion: RawByteString;
begin
  Result := GetString(GL_SHADING_LANGUAGE_VERSION);
  Assert(_Check('gl.GetShadingLanguageVersion'));
end;

class function gl.GetStencilBackFail: TGLStencilOp;
var
  Value: GLint;
begin
  glGetIntegerv(GL_STENCIL_BACK_FAIL, @Value);
  Assert(_Check('gl.GetStencilBackFail'));
  Result := TGLStencilOp(Value);
end;

class function gl.GetStencilBackFunc: TGLCompareFunc;
var
  Value: GLint;
begin
  glGetIntegerv(GL_STENCIL_BACK_FUNC, @Value);
  Assert(_Check('gl.GetStencilBackFunc'));
  Result := TGLCompareFunc(Value);
end;

class function gl.GetStencilBackPassDepthFail: TGLStencilOp;
var
  Value: GLint;
begin
  glGetIntegerv(GL_STENCIL_BACK_PASS_DEPTH_FAIL, @Value);
  Assert(_Check('gl.GetStencilBackPassDepthFail'));
  Result := TGLStencilOp(Value);
end;

class function gl.GetStencilBackPassDepthPass: TGLStencilOp;
var
  Value: GLint;
begin
  glGetIntegerv(GL_STENCIL_BACK_PASS_DEPTH_PASS, @Value);
  Assert(_Check('gl.GetStencilBackPassDepthPass'));
  Result := TGLStencilOp(Value);
end;

class function gl.GetStencilBackRef: Integer;
begin
  glGetIntegerv(GL_STENCIL_BACK_REF, @Result);
  Assert(_Check('gl.GetStencilBackRef'));
end;

class function gl.GetStencilBackValueMask: Cardinal;
begin
  glGetIntegerv(GL_STENCIL_BACK_VALUE_MASK, @Result);
  Assert(_Check('gl.GetStencilBackValueMask'));
end;

class function gl.GetStencilBackWriteMask: Cardinal;
begin
  glGetIntegerv(GL_STENCIL_BACK_WRITEMASK, @Result);
  Assert(_Check('gl.GetStencilBackWriteMask'));
end;

class function gl.GetStencilFail: TGLStencilOp;
var
  Value: GLint;
begin
  glGetIntegerv(GL_STENCIL_FAIL, @Value);
  Assert(_Check('gl.GetStencilFail'));
  Result := TGLStencilOp(Value);
end;

class function gl.GetStencilFunc: TGLCompareFunc;
var
  Value: GLint;
begin
  glGetIntegerv(GL_STENCIL_FUNC, @Value);
  Assert(_Check('gl.GetStencilFunc'));
  Result := TGLCompareFunc(Value);
end;

class function gl.GetStencilPassDepthFail: TGLStencilOp;
var
  Value: GLint;
begin
  glGetIntegerv(GL_STENCIL_PASS_DEPTH_FAIL, @Value);
  Assert(_Check('gl.GetStencilPassDepthFail'));
  Result := TGLStencilOp(Value);
end;

class function gl.GetStencilPassDepthPass: TGLStencilOp;
var
  Value: GLint;
begin
  glGetIntegerv(GL_STENCIL_PASS_DEPTH_PASS, @Value);
  Assert(_Check('gl.GetStencilPassDepthPass'));
  Result := TGLStencilOp(Value);
end;

class function gl.GetStencilRef: Integer;
begin
  glGetIntegerv(GL_STENCIL_REF, @Result);
  Assert(_Check('gl.GetStencilRef'));
end;

class function gl.GetStencilValueMask: Cardinal;
begin
  glGetIntegerv(GL_STENCIL_VALUE_MASK, @Result);
  Assert(_Check('gl.GetStencilValueMask'));
end;

class function gl.GetStencilWriteMask: Cardinal;
begin
  glGetIntegerv(GL_STENCIL_WRITEMASK, @Result);
  Assert(_Check('gl.GetStencilWriteMask'));
end;

class function gl.GetString(const AName: GLenum): RawByteString;
begin
  Result := RawByteString(glGetString(AName));
end;

class function gl.GetSubpixelBits: Integer;
begin
  glGetIntegerv(GL_SUBPIXEL_BITS, @Result);
  Assert(_Check('gl.GetSubpixelBits'));
end;

class function gl.GetVendor: RawByteString;
begin
  Result := GetString(GL_VENDOR);
  Assert(_Check('gl.GetVendor'));
end;

class function gl.GetVersion: RawByteString;
begin
  Result := GetString(GL_VERSION);
  Assert(_Check('gl.GetVersion'));
end;

class procedure gl.GetViewport(out ALeft, ABottom, AWidth, AHeight: Integer);
var
  Data: array [0..3] of GLint;
begin
  glGetIntegerv(GL_VIEWPORT, @Data);
  Assert(_Check('gl.GetViewport'));
  ALeft := Data[0];
  ABottom := Data[1];
  AWidth := Data[2];
  AHeight := Data[3];
end;

class function gl.IsEnabled(const ACapability: TGLCapability): Boolean;
begin
  Result := (glIsEnabled(Ord(ACapability)) = GL_TRUE);
  Assert(_Check('gl.IsEnabled'));
end;

class procedure gl.LineWidth(const AWidth: Single);
begin
  glLineWidth(AWidth);
  Assert(_Check('gl.LineWidth'));
end;

class procedure gl.PixelStore(const AMode: TGLPixelStoreMode;
  const AValue: TGLPixelStoreValue);
begin
  glPixelStorei(Ord(AMode), Ord(AValue));
  Assert(_Check('gl.PixelStore'));
end;

class procedure gl.PolygonOffset(const AFactor, AUnits: Single);
begin
  glPolygonOffset(AFactor, AUnits);
  Assert(_Check('gl.PolygonOffset'));
end;

class procedure gl.SampleCoverage(const AValue: Single; const AInvert: Boolean);
begin
  glSampleCoverage(AValue, Ord(AInvert));
  Assert(_Check('gl.SampleCoverage'));
end;

class procedure gl.Scissor(const ALeft, ABottom, AWidth, AHeight: Integer);
begin
  glScissor(ALeft, ABottom, AWidth, AHeight);
  Assert(_Check('gl.Scissor'));
end;

class procedure gl.StencilFunc(const AFunc: TGLCompareFunc; const ARef: Integer;
  const AMask: Cardinal);
begin
  glStencilFunc(Ord(AFunc), ARef, AMask);
  Assert(_Check('gl.StencilFunc'));
end;

class procedure gl.StencilFuncSeparate(const AFace: TGLFace;
  const AFunc: TGLCompareFunc; const ARef: Integer; const AMask: Cardinal);
begin
  glStencilFuncSeparate(Ord(AFace), Ord(AFunc), ARef, AMask);
  Assert(_Check('gl.StencilFuncSeparate'));
end;

class procedure gl.StencilMask(const AMask: Cardinal);
begin
  glStencilMask(AMask);
  Assert(_Check('gl.StencilMask'));
end;

class procedure gl.StencilMaskSeparate(const AFace: TGLFace;
  const AMask: Cardinal);
begin
  glStencilMaskSeparate(Ord(AFace), AMask);
  Assert(_Check('gl.StencilMaskSeparate'));
end;

class procedure gl.StencilOp(const AStencilFail, ADepthFail,
  ABothPass: TGLStencilOp);
begin
  glStencilOp(Ord(AStencilFail), Ord(ADepthFail), Ord(ABothPass));
  Assert(_Check('gl.StencilOp'));
end;

class procedure gl.StencilOpSeparate(const AFace: TGLFace; const AStencilFail,
  ADepthFail, ABothPass: TGLStencilOp);
begin
  glStencilOpSeparate(Ord(AFace), Ord(AStencilFail), Ord(ADepthFail), Ord(ABothPass));
  Assert(_Check('gl.StencilOpSeparate'));
end;

class procedure gl.Viewport(const ALeft, ABottom, AWidth, AHeight: Integer);
begin
  glViewport(ALeft, ABottom, AWidth, AHeight);
  Assert(_Check('gl.Viewport'));
end;

class procedure gl.Viewport(const AWidth, AHeight: Integer);
begin
  glViewport(0, 0, AWidth, AHeight);
  Assert(_Check('gl.Viewport'));
end;

{ TGLShader }

function TGLShader.Compile: Boolean;
var
  Status: GLint;
  {$IFDEF DEBUG}
  InfoLogLength: GLint;
  InfoLog: TBytes;
  InfoLogMsg: String;
  {$ENDIF}
begin
  glCompileShader(FHandle);
  Assert(_Check('TGLShader.Compile.CompileShader'));

  glGetShaderiv(FHandle, GL_COMPILE_STATUS, @Status);
  Assert(_Check('TGLShader.Compile.GetShaderiv(GL_COMPILE_STATUS)'));

  Result := (Status = GL_TRUE);

  {$IFDEF DEBUG}
  if (Result) then
  begin
    { Check for warnings }
    glGetShaderiv(FHandle, GL_INFO_LOG_LENGTH, @InfoLogLength);
    Assert(_Check('TGLShader.Compile.GetShaderiv(GL_INFO_LOG_LENGTH)'));
    if (InfoLogLength > 1) then
    begin
      SetLength(InfoLog, InfoLogLength);
      glGetShaderInfoLog(FHandle, InfoLogLength, nil, @InfoLog[0]);
      Assert(_Check('TGLShader.Compile.GetShaderInfoLog'));
      InfoLogMsg := TEncoding.ANSI.GetString(InfoLog);
      _DebugLog('Shader compiler warning: ' + InfoLogMsg);
    end;
  end
  else
  begin
    glGetShaderiv(FHandle, GL_INFO_LOG_LENGTH, @InfoLogLength);
    Assert(_Check('TGLShader.Compile.GetShaderiv(GL_INFO_LOG_LENGTH)'));
    SetLength(InfoLog, InfoLogLength);
    glGetShaderInfoLog(FHandle, InfoLogLength, nil, @InfoLog[0]);
    Assert(_Check('TGLShader.Compile.GetShaderInfoLog'));
    InfoLogMsg := TEncoding.ANSI.GetString(InfoLog);
    raise EGLShaderError.Create('Shader compiler failure: ' + InfoLogMsg);
  end;
  {$ENDIF}
end;

procedure TGLShader.Delete;
begin
  if (FHandle <> 0) then
  begin
    glDeleteShader(FHandle);
    FHandle := 0;
    Assert(_Check('TGLShader.Delete'));
  end;
end;

function TGLShader.GetCompileStatus: Boolean;
var
  Value: GLint;
begin
  glGetShaderiv(FHandle, GL_COMPILE_STATUS, @Value);
  Assert(_Check('TGLShader.GetCompileStatus'));
  Result := (Value = GL_TRUE);
end;

function TGLShader.GetDeleteStatus: Boolean;
var
  Value: GLint;
begin
  glGetShaderiv(FHandle, GL_DELETE_STATUS, @Value);
  Assert(_Check('TGLShader.GetDeleteStatus'));
  Result := (Value = GL_TRUE);
end;

class function TGLShader.GetMaxVaryingVectors: Integer;
begin
  glGetIntegerv(GL_MAX_VARYING_VECTORS, @Result);
  Assert(_Check('TGLShader.GetMaxVaryingVectors'));
end;

class function TGLShader.GetMaxVertexAttribs: Integer;
begin
  glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, @Result);
  Assert(_Check('TGLShader.GetMaxVertexAttribs'));
end;

function TGLShader.GetSource: RawByteString;
var
  Len: GLint;
begin
  glGetShaderiv(FHandle, GL_SHADER_SOURCE_LENGTH, @Len);
  Assert(_Check('TGLShader.GetSource'));
  if (Len <= 1) then
    Exit('');

  SetLength(Result, Len - 1);
  glGetShaderSource(FHandle, Len, nil, @Result[Low(RawByteString)]);
  Assert(_Check('TGLShader.GetSource'));
end;

function TGLShader.GetType: TGLShaderType;
var
  Value: GLint;
begin
  glGetShaderiv(FHandle, GL_SHADER_TYPE, @Value);
  Assert(_Check('TGLShader.GetType'));
  Result := TGLShaderType(Value);
end;

{$IFDEF DESKTOP_OPENGL}
class function TGLShader.GlslEsToGlsl(
  const ASource: RawByteString): RawByteString;
var
  Strings: TStringList;
  Line: String;
  I: Integer;
begin
  Strings := TStringList.Create;
  try
    Strings.Text := String(ASource);

    { Remove any lines containing a 'precision ...' directive }
    for I := Strings.Count - 1 downto 0 do
    begin
      Line := Strings[I].TrimLeft;
      if (Line.StartsWith('precision ')) then
        Strings.Delete(I);
    end;

    { Define GLSL-ES precision qualifiers as empty so GLSL ignores them.
      Also, set the GLSL version to 1.20, which most closely matches
      GLSL-ES 2.0 }
    Result :=
      '#version 120'#10+
      '#define lowp'#10+
      '#define mediump'#10+
      '#define highp'#10+
      RawByteString(Strings.Text);
  finally
    Strings.Free;
  end;
end;
{$ENDIF}

procedure TGLShader.New(const AType: TGLShaderType);
begin
  FHandle := glCreateShader(Ord(AType));
  Assert(_Check('TGLShader.New'));
end;

procedure TGLShader.New(const AType: TGLShaderType;
  const ASource: RawByteString);
begin
  FHandle := glCreateShader(Ord(AType));
  Assert(_Check('TGLShader.New'));
  SetSource(ASource);
end;

class procedure TGLShader.ReleaseCompiler;
begin
  {$IF Defined(MACOS) and not Defined(IOS)}
  // Not used on macOS
  {$ELSE}
  glReleaseShaderCompiler;
  Assert(_Check('TGLShader.ReleaseCompiler'));
  {$ENDIF}
end;

procedure TGLShader.SetSource(const ASource: RawByteString);
var
  Source: RawByteString;
  SourcePtr: MarshaledAString;
begin
  {$IFDEF DESKTOP_OPENGL}
  Source := GlslEsToGlsl(ASource);
  {$ELSE}
  Source := ASource;
  {$ENDIF}

  SourcePtr := MarshaledAString(Source);
  glShaderSource(FHandle, 1, @SourcePtr, nil);
  Assert(_Check('TGLShader.SetSource'));
end;

{ TGLProgram }

procedure TGLProgram.AttachShader(const AShader: TGLShader);
begin
  glAttachShader(FHandle, AShader.FHandle);
  Assert(_Check('TGLProgram.AttachShader'));
end;

procedure TGLProgram.AttachShaders(const
  AVertexShader, AFragmentShader: TGLShader);
begin
  AttachShader(AVertexShader);
  AttachShader(AFragmentShader);
end;

procedure TGLProgram.Delete;
begin
  if (FHandle <> 0) then
  begin
    glDeleteProgram(FHandle);
    FHandle := 0;
    Assert(_Check('TGLProgram.Delete'));
  end;
end;

procedure TGLProgram.DetachShader(const AShader: TGLShader);
begin
  glDetachShader(FHandle, AShader.FHandle);
  Assert(_Check('TGLProgram.DetachShader'));
end;

function TGLProgram.GetActiveAttributes: Integer;
begin
  glGetProgramiv(FHandle, GL_ACTIVE_ATTRIBUTES, @Result);
  Assert(_Check('TGLProgram.GetActiveAttributes'));
end;

function TGLProgram.GetActiveUniforms: Integer;
begin
  glGetProgramiv(FHandle, GL_ACTIVE_UNIFORMS, @Result);
  Assert(_Check('TGLProgram.GetActiveUniforms'));
end;

function TGLProgram.GetAttachedShaders: TArray<TGLShader>;
var
  Handles: array [0..1] of GLuint;
  I, Count: GLsizei;
begin
  glGetAttachedShaders(FHandle, Length(Handles), @Count, @Handles[0]);
  Assert(_Check('TGLProgram.GetAttachedShaders'));
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
    Result[I].FHandle := Handles[I];
end;

function TGLProgram.GetAttributeInfo(const AIndex: Integer): TGLAttrInfo;
var
  Buffer: array [0..63] of Byte;
  Len: GLsizei;
  DataType: GLenum;
begin
  glGetActiveAttrib(FHandle, AIndex, Length(Buffer), @Len, @Result.Size,
    @DataType, @Buffer[0]);
  Assert(_Check('TGLProgram.GetAttributeInfo'));
  Result.DataType := TGLAttrDataType(DataType);
  Result.Name := RawByteString(MarshaledAString(@Buffer[0]));
end;

class function TGLProgram.GetCurrent: TGLProgram;
begin
  glGetIntegerv(GL_CURRENT_PROGRAM, @Result.FHandle);
  Assert(_Check('TGLProgram.GetCurrent'));
end;

function TGLProgram.GetDeleteStatus: Boolean;
var
  Value: GLint;
begin
  glGetProgramiv(FHandle, GL_DELETE_STATUS, @Value);
  Assert(_Check('TGLProgram.GetDeleteStatus'));
  Result := (Value = GL_TRUE);
end;

function TGLProgram.GetLinkStatus: Boolean;
var
  Value: GLint;
begin
  glGetProgramiv(FHandle, GL_LINK_STATUS, @Value);
  Assert(_Check('TGLProgram.GetLinkStatus'));
  Result := (Value = GL_TRUE);
end;

function TGLProgram.GetUniformInfo(const AIndex: Integer): TGLUniformInfo;
var
  Buffer: array [0..63] of Byte;
  Len: GLsizei;
  DataType: GLenum;
begin
  glGetActiveUniform(FHandle, AIndex, Length(Buffer), @Len, @Result.Size,
    @DataType, @Buffer[0]);
  Assert(_Check('TGLProgram.GetUniformInfo'));
  Result.DataType := TGLUniformDataType(DataType);
  Result.Name := RawByteString(MarshaledAString(@Buffer[0]));
end;

function TGLProgram.GetValidateStatus: Boolean;
var
  Value: GLint;
begin
  glGetProgramiv(FHandle, GL_VALIDATE_STATUS, @Value);
  Assert(_Check('TGLProgram.GetValidateStatus'));
  Result := (Value = GL_TRUE);
end;

function TGLProgram.Link: Boolean;
var
  Status: GLint;
  {$IFDEF DEBUG}
  InfoLogLength: GLint;
  InfoLog: TBytes;
  InfoLogMsg: String;
  {$ENDIF}
begin
  glLinkProgram(FHandle);
  Assert(_Check('TGLProgram.Link.LinkProgram'));

  glGetProgramiv(FHandle, GL_LINK_STATUS, @Status);
  Assert(_Check('TGLProgram.Link.GetShaderiv(GL_LINK_STATUS)'));

  Result := (Status = GL_TRUE);

  {$IFDEF DEBUG}
  if (Result) then
  begin
    { Check for warnings }
    glGetProgramiv(FHandle, GL_INFO_LOG_LENGTH, @InfoLogLength);
    Assert(_Check('TGLProgram.Link.GetProgramiv(GL_INFO_LOG_LENGTH)'));
    if (InfoLogLength > 1) then
    begin
      SetLength(InfoLog, InfoLogLength);
      glGetProgramInfoLog(FHandle, InfoLogLength, nil, @InfoLog[0]);
      Assert(_Check('TGLProgram.Link.GetProgramInfoLog'));
      InfoLogMsg := TEncoding.ANSI.GetString(InfoLog);
      _DebugLog('Program link warning: ' + InfoLogMsg);
    end;
  end
  else
  begin
    glGetProgramiv(FHandle, GL_INFO_LOG_LENGTH, @InfoLogLength);
    Assert(_Check('TGLProgram.Link.GetProgramiv(GL_INFO_LOG_LENGTH)'));
    SetLength(InfoLog, InfoLogLength);
    glGetProgramInfoLog(FHandle, InfoLogLength, nil, @InfoLog[0]);
    Assert(_Check('TGLProgram.Link.GetProgramInfoLog'));
    InfoLogMsg := TEncoding.ANSI.GetString(InfoLog);
    raise EGLShaderError.Create('Program link failure: ' + InfoLogMsg);
  end;
  {$ENDIF}
end;

procedure TGLProgram.New;
begin
  FHandle := glCreateProgram;
  Assert(_Check('TGLProgram.New'));
end;

procedure TGLProgram.New(const AVertexShader, AFragmentShader: TGLShader);
begin
  FHandle := glCreateProgram;
  Assert(_Check('TGLProgram.New'));
  AttachShaders(AVertexShader, AFragmentShader);
end;

procedure TGLProgram.Use;
begin
  glUseProgram(FHandle);
  Assert(_Check('TGLProgram.Use'));
end;

function TGLProgram.Validate: Boolean;
var
  Status: GLint;
  {$IFDEF DEBUG}
  InfoLogLength: GLint;
  InfoLog: TBytes;
  InfoLogMsg: String;
  {$ENDIF}
begin
  glValidateProgram(FHandle);
  Assert(_Check('TGLProgram.Validate.ValidateProgram'));

  glGetProgramiv(FHandle, GL_VALIDATE_STATUS, @Status);
  Assert(_Check('TGLProgram.Link.GetShaderiv(GL_VALIDATE_STATUS)'));

  Result := (Status = GL_TRUE);

  {$IFDEF DEBUG}
  if (Result) then
  begin
    { Check for warnings }
    glGetProgramiv(FHandle, GL_INFO_LOG_LENGTH, @InfoLogLength);
    Assert(_Check('TGLProgram.Validate.GetProgramiv(GL_INFO_LOG_LENGTH)'));
    if (InfoLogLength > 1) then
    begin
      SetLength(InfoLog, InfoLogLength);
      glGetProgramInfoLog(FHandle, InfoLogLength, nil, @InfoLog[0]);
      Assert(_Check('TGLProgram.Validate.GetProgramInfoLog'));
      InfoLogMsg := TEncoding.ANSI.GetString(InfoLog);
      _DebugLog('Program validation warning: ' + InfoLogMsg);
    end;
  end
  else
  begin
    glGetProgramiv(FHandle, GL_INFO_LOG_LENGTH, @InfoLogLength);
    Assert(_Check('TGLProgram.Validate.GetProgramiv(GL_INFO_LOG_LENGTH)'));
    SetLength(InfoLog, InfoLogLength);
    glGetProgramInfoLog(FHandle, InfoLogLength, nil, @InfoLog[0]);
    Assert(_Check('TGLProgram.Validate.GetProgramInfoLog'));
    InfoLogMsg := TEncoding.ANSI.GetString(InfoLog);
    raise EGLShaderError.Create('Program validation failure: ' + InfoLogMsg);
  end;
  {$ENDIF}
end;

{ TGLBuffer }

procedure TGLBuffer.Bind;
begin
  glBindBuffer(FType, FHandle);
  Assert(_Check('TGLBuffer.Bind'));
end;

procedure TGLBuffer.Data(const AData; const ASize: NativeInt;
  const AUsage: TGLBufferUsage);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLBuffer.Data'));
  glBufferData(FType, ASize, @AData, Ord(AUsage));
  Assert(_Check('TGLBuffer.Data'));
end;

procedure TGLBuffer.Data<T>(const AData: array of T;
  const AUsage: TGLBufferUsage);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLBuffer.Data'));
  glBufferData(FType, Length(AData) * SizeOf(T), @AData[0], Ord(AUsage));
  Assert(_Check('TGLBuffer.Data'));
end;

procedure TGLBuffer.Data<T>(const AData: TArray<T>;
  const AUsage: TGLBufferUsage);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLBuffer.Data'));
  glBufferData(FType, Length(AData) * SizeOf(T), @AData[0], Ord(AUsage));
  Assert(_Check('TGLBuffer.Data'));
end;

procedure TGLBuffer.Delete;
begin
  if (FHandle <> 0) then
  begin
    glDeleteBuffers(1, @FHandle);
    FHandle := 0;
    Assert(_Check('TGLBuffer.Delete'));
  end;
end;

class function TGLBuffer.GetCurrentArrayBuffer: TGLBuffer;
begin
  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, @Result.FHandle);
  Assert(_Check('TGLBuffer.GetCurrentArrayBuffer'));
  Result.FType := GL_ARRAY_BUFFER;
end;

class function TGLBuffer.GetCurrentElementArrayBuffer: TGLBuffer;
begin
  glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, @Result.FHandle);
  Assert(_Check('TGLBuffer.GetCurrentElementArrayBuffer'));
  Result.FType := GL_ELEMENT_ARRAY_BUFFER;
end;

function TGLBuffer.GetSize: Integer;
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLBuffer.GetSize'));
  glGetBufferParameteriv(FType, GL_BUFFER_SIZE, @Result);
  Assert(_Check('TGLBuffer.GetSize'));
end;

function TGLBuffer.GetUsage: TGLBufferUsage;
var
  Usage: GLint;
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLBuffer.TGLBufferUsage'));
  glGetBufferParameteriv(FType, GL_BUFFER_SIZE, @Usage);
  Assert(_Check('TGLBuffer.TGLBufferUsage'));
  Result := TGLBufferUsage(Usage);
end;

function TGLBuffer.IsBound: Boolean;
var
  CurrentlyBoundBuffer: GLenum;
begin
  glGetIntegerv(_GetTargetBinding(FType), @CurrentlyBoundBuffer);
  Assert(_Check('TGLBuffer.IsBound'));
  Result := (CurrentlyBoundBuffer = FHandle);
end;

procedure TGLBuffer.New(const AType: TGLBufferType);
begin
  FType := Ord(AType);
  glGenBuffers(1, @FHandle);
  Assert(_Check('TGLBuffer.New'));
end;

procedure TGLBuffer.SubData(const AOffset: NativeInt; const AData;
  const ASize: NativeInt);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLBuffer.SubData'));
  glBufferSubData(FType, AOffset, ASize, @AData);
  Assert(_Check('TGLBuffer.SubData'));
end;

procedure TGLBuffer.SubData<T>(const AOffset: NativeInt; const AData: array of T);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLBuffer.SubData'));
  glBufferSubData(FType, AOffset, Length(AData) * SizeOf(T), @AData[0]);
  Assert(_Check('TGLBuffer.SubData'));
end;

procedure TGLBuffer.SubData<T>(const AOffset: NativeInt; const AData: TArray<T>);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLBuffer.SubData'));
  glBufferSubData(FType, AOffset, Length(AData) * SizeOf(T), @AData[0]);
  Assert(_Check('TGLBuffer.SubData'));
end;

procedure TGLBuffer.Unbind;
begin
  glBindBuffer(FType, 0);
  Assert(_Check('TGLBuffer.Bind'));
end;

{ TGLVertexAttrib }

procedure TGLVertexAttrib.Bind(const AProgram: TGLProgram;
  const ALocation: Cardinal; const AAttrName: RawByteString);
begin
  glBindAttribLocation(AProgram.FHandle, ALocation, MarshaledAString(AAttrName));
  Assert(_Check('TGLVertexAttrib.Bind'));
end;

procedure TGLVertexAttrib.Disable;
begin
  glDisableVertexAttribArray(FLocation);
  Assert(_Check('TGLVertexAttrib.Disable'));
end;

procedure TGLVertexAttrib.Enable;
begin
  glEnableVertexAttribArray(FLocation);
  Assert(_Check('TGLVertexAttrib.Enable'));
end;

function TGLVertexAttrib.GetBuffer: TGLBuffer;
begin
  glGetVertexAttribiv(FLocation, GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, @Result.FHandle);
  Assert(_Check('TGLVertexAttrib.GetBuffer'));
  Result.FType := GL_ARRAY_BUFFER;
end;

function TGLVertexAttrib.GetData: Pointer;
begin
  glGetVertexAttribPointerv(FLocation, GL_VERTEX_ATTRIB_ARRAY_POINTER, @Result);
  Assert(_Check('TGLVertexAttrib.GetData'));
end;

function TGLVertexAttrib.GetDataType: TGLDataType;
var
  Value: GLint;
begin
  glGetVertexAttribiv(FLocation, GL_VERTEX_ATTRIB_ARRAY_TYPE, @Value);
  Assert(_Check('TGLVertexAttrib.GetDataType'));
  Result := TGLDataType(Value);
end;

function TGLVertexAttrib.GetOffset: Integer;
begin
  glGetVertexAttribPointerv(FLocation, GL_VERTEX_ATTRIB_ARRAY_POINTER, @Result);
  Assert(_Check('TGLVertexAttrib.GetOffset'));
end;

function TGLVertexAttrib.GetSize: Integer;
begin
  glGetVertexAttribiv(FLocation, GL_VERTEX_ATTRIB_ARRAY_SIZE, @Result);
  Assert(_Check('TGLVertexAttrib.GetSize'));
end;

function TGLVertexAttrib.GetStride: Integer;
begin
  glGetVertexAttribiv(FLocation, GL_VERTEX_ATTRIB_ARRAY_STRIDE, @Result);
  Assert(_Check('TGLVertexAttrib.GetStride'));
end;

class procedure TGLVertexAttrib.GetTypeInfo<T>(out ADataType: TGLDataType;
  out ANumValuesPerVertex: Integer);
var
  SrcTypeInfo: PTypeInfo;
begin
  ANumValuesPerVertex := 1;
  case GetTypeKind(T) of
    tkInteger:
      begin
        case GetTypeData(TypeInfo(T))^.OrdType of
          otSByte: ADataType := TGLDataType.Byte;
          otUByte: ADataType := TGLDataType.UnsignedByte;
          otSWord: ADataType := TGLDataType.Short;
          otUWord: ADataType := TGLDataType.UnsignedShort;
          otSLong: ADataType := TGLDataType.Int;
          otULong: ADataType := TGLDataType.UnsignedInt;
        else
          Assert(False);
          ADataType := TGLDataType.Float;
        end;
      end;

    tkFloat:
      begin
        case GetTypeData(TypeInfo(T))^.FloatType of
          ftSingle: ADataType := TGLDataType.Float;
        else
          Assert(False);
          ADataType := TGLDataType.Float;
        end;
      end;

    tkRecord:
      begin
        ADataType := TGLDataType.Float;
        SrcTypeInfo := TypeInfo(T);
        if (SrcTypeInfo = TypeInfo(TVector2)) then
          ANumValuesPerVertex := 2
        else if (SrcTypeInfo = TypeInfo(TVector3)) then
          ANumValuesPerVertex := 3
        else if (SrcTypeInfo = TypeInfo(TVector4)) then
          ANumValuesPerVertex := 4
        else
          Assert(False);
      end
  else
    Assert(False);
    ADataType := TGLDataType.Float;
  end;
end;

function TGLVertexAttrib.GetValue: TVector4;
begin
  glGetVertexAttribfv(FLocation, GL_CURRENT_VERTEX_ATTRIB, @Result);
  Assert(_Check('TGLVertexAttrib.GetValue'));
end;

procedure TGLVertexAttrib.Init(const AProgram: TGLProgram;
  const AAttrName: RawByteString);
begin
  FLocation := glGetAttribLocation(AProgram.FHandle, MarshaledAString(AAttrName));
  Assert(_Check('TGLVertexAttrib.Init'));
  {$IFDEF DEBUG}
  if (FLocation < 0) then
    _DebugLog('Unable to get location of attribute "%s"', [String(AAttrName)]);
  {$ENDIF}
end;

function TGLVertexAttrib.IsEnabled: Boolean;
var
  Value: GLint;
begin
  glGetVertexAttribiv(FLocation, GL_VERTEX_ATTRIB_ARRAY_ENABLED, @Value);
  Assert(_Check('TGLVertexAttrib.IsEnabled'));
  Result := (Value = GL_TRUE);
end;

function TGLVertexAttrib.IsNormalized: Boolean;
var
  Value: GLint;
begin
  glGetVertexAttribiv(FLocation, GL_VERTEX_ATTRIB_ARRAY_NORMALIZED, @Value);
  Assert(_Check('TGLVertexAttrib.IsNormalized'));
  Result := (Value = GL_TRUE);
end;

procedure TGLVertexAttrib.SetData(const ADataType: TGLDataType;
  const ANumValuesPerVertex: Integer; const AData: Pointer;
  const AStride: NativeInt; const ANormalized: Boolean);
begin
  glVertexAttribPointer(FLocation, ANumValuesPerVertex, Ord(ADataType),
    Ord(ANormalized), AStride, AData);
  Assert(_Check('TGLVertexAttrib.SetData'));
end;

procedure TGLVertexAttrib.SetData<T>(const AData: array of T;
  const AStride: NativeInt; const ANormalized: Boolean);
var
  DataType: TGLDataType;
  NumValuesPerVertex: Integer;
begin
  GetTypeInfo<T>(DataType, NumValuesPerVertex);
  SetData(DataType, NumValuesPerVertex, @AData[0], AStride, ANormalized);
end;

procedure TGLVertexAttrib.SetData<T>(const AData: TArray<T>;
  const AStride: NativeInt; const ANormalized: Boolean);
var
  DataType: TGLDataType;
  NumValuesPerVertex: Integer;
begin
  GetTypeInfo<T>(DataType, NumValuesPerVertex);
  SetData(DataType, NumValuesPerVertex, @AData[0], AStride, ANormalized);
end;

procedure TGLVertexAttrib.SetValue(const AValue: Single);
begin
  glVertexAttrib1f(FLocation, AValue);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue0, AValue1: Single);
begin
  glVertexAttrib2f(FLocation, AValue0, AValue1);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue0, AValue1, AValue2: Single);
begin
  glVertexAttrib3f(FLocation, AValue0, AValue1, AValue2);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue0, AValue1, AValue2,
  AValue3: Single);
begin
  glVertexAttrib4f(FLocation, AValue0, AValue1, AValue2, AValue3);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue: TVector2);
begin
  glVertexAttrib2fv(FLocation, @AValue);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue: TVector3);
begin
  glVertexAttrib3fv(FLocation, @AValue);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue: TVector4);
begin
  glVertexAttrib4fv(FLocation, @AValue);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue: TMatrix2);
begin
  glVertexAttrib2fv(FLocation + 0, @AValue.V[0]);
  glVertexAttrib2fv(FLocation + 1, @AValue.V[1]);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue: TMatrix3);
begin
  glVertexAttrib3fv(FLocation + 0, @AValue.V[0]);
  glVertexAttrib3fv(FLocation + 1, @AValue.V[1]);
  glVertexAttrib3fv(FLocation + 2, @AValue.V[2]);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetValue(const AValue: TMatrix4);
begin
  glVertexAttrib4fv(FLocation + 0, @AValue.V[0]);
  glVertexAttrib4fv(FLocation + 1, @AValue.V[1]);
  glVertexAttrib4fv(FLocation + 2, @AValue.V[2]);
  glVertexAttrib4fv(FLocation + 3, @AValue.V[3]);
  Assert(_Check('TGLVertexAttrib.SetValue'));
end;

procedure TGLVertexAttrib.SetConfig(const ADataType: TGLDataType;
  const ANumValuesPerVertex: Integer; const AStride, AOffset: NativeInt);
begin
  Assert(_CheckBinding(GL_ARRAY_BUFFER, 'TGLVertexAttrib.SetConfig'));
  glVertexAttribPointer(FLocation, ANumValuesPerVertex, Ord(ADataType),
    GL_FALSE, AStride, Pointer(AOffset));
  Assert(_Check('TGLVertexAttrib.SetConfig'));
end;

procedure TGLVertexAttrib.SetConfig<T>(const AStride, AOffset: NativeInt);
var
  DataType: TGLDataType;
  NumValuesPerVertex: Integer;
begin
  GetTypeInfo<T>(DataType, NumValuesPerVertex);
  SetConfig(DataType, NumValuesPerVertex, AStride, AOffset);
end;

{ TGLUniform }

class function TGLUniform.GetMaxFragmentUniformVectors: Integer;
begin
  glGetIntegerv(GL_MAX_FRAGMENT_UNIFORM_VECTORS, @Result);
  Assert(_Check('TGLUniform.GetMaxFragmentUniformVectors'));
end;

class function TGLUniform.GetMaxVertexUniformVectors: Integer;
begin
  glGetIntegerv(GL_MAX_VERTEX_UNIFORM_VECTORS, @Result);
  Assert(_Check('TGLUniform.GetMaxVertexUniformVectors'));
end;

procedure TGLUniform.GetValue(out AValue: TVector3);
begin
  glGetUniformfv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue: TVector2);
begin
  glGetUniformfv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue: TMatrix2);
begin
  glGetUniformfv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue: TVector4);
begin
  glGetUniformfv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue: Single);
begin
  glGetUniformfv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue0, AValue1: Single);
var
  Values: array [0..1] of Single;
begin
  glGetUniformfv(FProgram, FLocation, @Values);
  Assert(_Check('TGLUniform.GetValue'));
  AValue0 := Values[0];
  AValue1 := Values[1];
end;

procedure TGLUniform.GetValue(out AValue0, AValue1, AValue2: Single);
var
  Values: array [0..2] of Single;
begin
  glGetUniformfv(FProgram, FLocation, @Values);
  Assert(_Check('TGLUniform.GetValue'));
  AValue0 := Values[0];
  AValue1 := Values[1];
  AValue2 := Values[2];
end;

procedure TGLUniform.GetValue(out AValue0, AValue1, AValue2, AValue3: Single);
var
  Values: array [0..3] of Single;
begin
  glGetUniformfv(FProgram, FLocation, @Values);
  Assert(_Check('TGLUniform.GetValue'));
  AValue0 := Values[0];
  AValue1 := Values[1];
  AValue2 := Values[2];
  AValue3 := Values[3];
end;

procedure TGLUniform.GetValue(out AValue: TMatrix3);
begin
  glGetUniformfv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue: TIVector2);
begin
  glGetUniformiv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue: Integer);
begin
  glGetUniformiv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue0, AValue1: Integer);
var
  Values: array [0..1] of Integer;
begin
  glGetUniformiv(FProgram, FLocation, @Values);
  Assert(_Check('TGLUniform.GetValue'));
  AValue0 := Values[0];
  AValue1 := Values[1];
end;

procedure TGLUniform.GetValue(out AValue0, AValue1, AValue2: Integer);
var
  Values: array [0..2] of Integer;
begin
  glGetUniformiv(FProgram, FLocation, @Values);
  Assert(_Check('TGLUniform.GetValue'));
  AValue0 := Values[0];
  AValue1 := Values[1];
  AValue2 := Values[2];
end;

procedure TGLUniform.GetValue(out AValue0, AValue1, AValue2, AValue3: Integer);
var
  Values: array [0..3] of Integer;
begin
  glGetUniformiv(FProgram, FLocation, @Values);
  Assert(_Check('TGLUniform.GetValue'));
  AValue0 := Values[0];
  AValue1 := Values[1];
  AValue2 := Values[2];
  AValue3 := Values[3];
end;

procedure TGLUniform.GetValue(out AValue: TIVector4);
begin
  glGetUniformiv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue: TIVector3);
begin
  glGetUniformiv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.GetValue(out AValue: TMatrix4);
begin
  glGetUniformfv(FProgram, FLocation, @AValue);
  Assert(_Check('TGLUniform.GetValue'));
end;

procedure TGLUniform.Init(const AProgram: TGLProgram;
  const AUniformName: RawByteString);
begin
  FLocation := glGetUniformLocation(AProgram.FHandle, MarshaledAString(AUniformName));
  FProgram := AProgram.FHandle;
  Assert(_Check('TGLUniform.Init'));
  {$IFDEF DEBUG}
  if (FLocation < 0) then
    _DebugLog('Unable to get location of uniform "%s"', [String(AUniformName)]);
  {$ENDIF}
end;

procedure TGLUniform.SetValue(const AValue: Integer);
begin
  glUniform1i(FLocation, AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue0, AValue1: Integer);
begin
  glUniform2i(FLocation, AValue0, AValue1);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue0, AValue1, AValue2: Integer);
begin
  glUniform3i(FLocation, AValue0, AValue1, AValue2);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue0, AValue1, AValue2,
  AValue3: Integer);
begin
  glUniform4i(FLocation, AValue0, AValue1, AValue2, AValue3);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: Single);
begin
  glUniform1f(FLocation, AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue0, AValue1: Single);
begin
  glUniform2f(FLocation, AValue0, AValue1);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue0, AValue1, AValue2: Single);
begin
  glUniform3f(FLocation, AValue0, AValue1, AValue2);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue0, AValue1, AValue2, AValue3: Single);
begin
  glUniform4f(FLocation, AValue0, AValue1, AValue2, AValue3);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TIVector2);
begin
  glUniform2iv(FLocation, 1, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TIVector3);
begin
  glUniform3iv(FLocation, 1, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TIVector4);
begin
  glUniform4iv(FLocation, 1, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TVector2);
begin
  glUniform2fv(FLocation, 1, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TVector3);
begin
  glUniform3fv(FLocation, 1, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TVector4);
begin
  glUniform4fv(FLocation, 1, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TMatrix2);
begin
  glUniformMatrix2fv(FLocation, 1, GL_FALSE, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TMatrix3);
begin
  glUniformMatrix3fv(FLocation, 1, GL_FALSE, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValue(const AValue: TMatrix4);
begin
  glUniformMatrix4fv(FLocation, 1, GL_FALSE, @AValue);
  Assert(_Check('TGLUniform.SetValue'));
end;

procedure TGLUniform.SetValues(const AValues: array of Integer);
begin
  glUniform1iv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<Integer>);
begin
  glUniform1iv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TIVector2);
begin
  glUniform2iv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TIVector2>);
begin
  glUniform2iv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TIVector3>);
begin
  glUniform3iv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TIVector3);
begin
  glUniform3iv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TIVector4>);
begin
  glUniform4iv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TIVector4);
begin
  glUniform4iv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<Single>);
begin
  glUniform1fv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of Single);
begin
  glUniform1fv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TVector2);
begin
  glUniform2fv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TVector2>);
begin
  glUniform2fv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TVector3>);
begin
  glUniform3fv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TVector3);
begin
  glUniform3fv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TVector4);
begin
  glUniform4fv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TVector4>);
begin
  glUniform4fv(FLocation, Length(AValues), @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TMatrix2);
begin
  glUniformMatrix2fv(FLocation, Length(AValues), GL_FALSE, @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TMatrix2>);
begin
  glUniformMatrix2fv(FLocation, Length(AValues), GL_FALSE, @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TMatrix3);
begin
  glUniformMatrix3fv(FLocation, Length(AValues), GL_FALSE, @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TMatrix3>);
begin
  glUniformMatrix3fv(FLocation, Length(AValues), GL_FALSE, @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: array of TMatrix4);
begin
  glUniformMatrix4fv(FLocation, Length(AValues), GL_FALSE, @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

procedure TGLUniform.SetValues(const AValues: TArray<TMatrix4>);
begin
  glUniformMatrix4fv(FLocation, Length(AValues), GL_FALSE, @AValues[0]);
  Assert(_Check('TGLUniform.SetValues'));
end;

{ TGLTexture }

procedure TGLTexture.Bind;
begin
  glBindTexture(FType, FHandle);
  Assert(_Check('TGLTexture.Bind'));
end;

procedure TGLTexture.BindToTextureUnit(const ATextureUnit: Cardinal);
begin
  glActiveTexture(GL_TEXTURE0 + ATextureUnit);
  Assert(_Check('TGLTexture.BindToTextureUnit'));
  glBindTexture(FType, FHandle);
  Assert(_Check('TGLTexture.Bind'));
end;

procedure TGLTexture.Copy(const AFormat: TGLPixelFormat; const ALeft, ABottom,
  AWidth, AHeight, ALevel: Integer; const ACubeTarget: TGLCubeTarget);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.Copy'));
  glCopyTexImage2D(GetTarget(ACubeTarget), ALevel, Ord(AFormat), ALeft, ABottom,
    AWidth, AHeight, 0);
  Assert(_Check('TGLTexture.Copy'));
end;

procedure TGLTexture.Delete;
begin
  if (FHandle <> 0) then
  begin
    glDeleteTextures(1, @FHandle);
    FHandle := 0;
    Assert(_Check('TGLTexture.Delete'));
  end;
end;

procedure TGLTexture.GenerateMipmap;
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.GenerateMipmap'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGenerateMipmapEXT(FType);
  {$ELSE}
  glGenerateMipmap(FType);
  {$ENDIF}
  Assert(_Check('TGLTexture.GenerateMipmap'));
end;

class function TGLTexture.GetActiveTextureUnit: Integer;
begin
  glGetIntegerv(GL_ACTIVE_TEXTURE, @Result);
  Assert(_Check('TGLTexture.GetActiveTextureUnit'));
end;

class function TGLTexture.GetCompressedTextureFormats: TArray<Cardinal>;
var
  Count: GLint;
begin
  glGetIntegerv(GL_NUM_COMPRESSED_TEXTURE_FORMATS, @Count);
  Assert(_Check('TGLTexture.GetCompressedTextureFormats'));
  SetLength(Result, Count);

  if (Count > 0) then
  begin
    glGetIntegerv(GL_COMPRESSED_TEXTURE_FORMATS, @Result[0]);
    Assert(_Check('TGLTexture.GetCompressedTextureFormats'));
  end;
end;

class function TGLTexture.GetCurrent2DTexture: TGLTexture;
begin
  glGetIntegerv(GL_TEXTURE_BINDING_2D, @Result.FHandle);
  Assert(_Check('TGLTexture.GetCurrent2DTexture'));
  Result.FType := GL_TEXTURE_2D;
end;

class function TGLTexture.GetCurrentCubemapTexture: TGLTexture;
begin
  glGetIntegerv(GL_TEXTURE_BINDING_CUBE_MAP, @Result.FHandle);
  Assert(_Check('TGLTexture.GetCurrentCubemapTexture'));
  Result.FType := GL_TEXTURE_CUBE_MAP;
end;

function TGLTexture.GetMagFilter: TGLMagFilter;
var
  Value: GLint;
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.GetMagFilter'));
  glGetTexParameteriv(FType, GL_TEXTURE_MAG_FILTER, @Value);
  Result := TGLMagFilter(Value);
  Assert(_Check('TGLTexture.GetMagFilter'));
end;

class function TGLTexture.GetMaxCombinedTextureUnits: Integer;
begin
  glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, @Result);
  Assert(_Check('TGLTexture.GetMaxCombinedTextureUnits'));
end;

class function TGLTexture.GetMaxCubeMapTextureSize: Integer;
begin
  glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, @Result);
  Assert(_Check('TGLTexture.GetMaxCubeMapTextureSize'));
end;

class function TGLTexture.GetMaxTextureSize: Integer;
begin
  glGetIntegerv(GL_MAX_TEXTURE_SIZE, @Result);
  Assert(_Check('TGLTexture.GetMaxTextureSize'));
end;

class function TGLTexture.GetMaxTextureUnits: Integer;
begin
  glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, @Result);
  Assert(_Check('TGLTexture.GetMaxTextureUnits'));
end;

class function TGLTexture.GetMaxVertexTextureUnits: Integer;
begin
  glGetIntegerv(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, @Result);
  Assert(_Check('TGLTexture.GetMaxVertexTextureUnits'));
end;

function TGLTexture.GetMinFilter: TGLMinFilter;
var
  Value: GLint;
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.GetMinFilter'));
  glGetTexParameteriv(FType, GL_TEXTURE_MIN_FILTER, @Value);
  Result := TGLMinFilter(Value);
  Assert(_Check('TGLTexture.GetMinFilter'));
end;

class function TGLTexture.GetMipmapHint: TGLMipmapHint;
var
  Value: GLint;
begin
  glGetIntegerv(GL_GENERATE_MIPMAP_HINT, @Value);
  Assert(_Check('TGLTexture.GetMipmapHint'));
  Result := TGLMipmapHint(Value);
end;

function TGLTexture.GetTarget(const ACubeTarget: TGLCubeTarget): GLuint;
begin
  Result := FType;
  if (Result = GL_TEXTURE_CUBE_MAP) then
    Result := GL_TEXTURE_CUBE_MAP_POSITIVE_X + ACubeTarget;
end;

function TGLTexture.GetWrapS: TGLWrapMode;
var
  Value: GLint;
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.GetWrapS'));
  glGetTexParameteriv(FType, GL_TEXTURE_WRAP_S, @Value);
  Result := TGLWrapMode(Value);
  Assert(_Check('TGLTexture.GetWrapS'));
end;

function TGLTexture.GetWrapT: TGLWrapMode;
var
  Value: GLint;
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.GetWrapT'));
  glGetTexParameteriv(FType, GL_TEXTURE_WRAP_T, @Value);
  Result := TGLWrapMode(Value);
  Assert(_Check('TGLTexture.GetWrapT'));
end;

function TGLTexture.IsBound: Boolean;
var
  CurrentlyBoundTexture: GLenum;
begin
  glGetIntegerv(_GetTargetBinding(FType), @CurrentlyBoundTexture);
  Assert(_Check('TGLTexture.IsBound'));
  Result := (CurrentlyBoundTexture = FHandle);
end;

procedure TGLTexture.MagFilter(const AMagFilter: TGLMagFilter);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.MagFilter'));
  glTexParameteri(FType, GL_TEXTURE_MAG_FILTER, Ord(AMagFilter));
  Assert(_Check('TGLTexture.MagFilter'));
end;

procedure TGLTexture.MinFilter(const AMinFilter: TGLMinFilter);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.MinFilter'));
  glTexParameteri(FType, GL_TEXTURE_MIN_FILTER, Ord(AMinFilter));
  Assert(_Check('TGLTexture.MinFilter'));
end;

class procedure TGLTexture.MipmapHint(const AHint: TGLMipmapHint);
begin
  glHint(GL_GENERATE_MIPMAP_HINT, Ord(AHint));
  Assert(_Check('TGLTexture.MipmapHint'));
end;

procedure TGLTexture.New(const AType: TGLTextureType);
begin
  glGenTextures(1, @FHandle);
  Assert(_Check('TGLTexture.New'));
  FType := Ord(AType);
end;

procedure TGLTexture.SubCopy(const AXOffset, AYOffset, ALeft, ABottom, AWidth,
  AHeight, ALevel: Integer; const ACubeTarget: TGLCubeTarget);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.SubCopy'));
  glCopyTexSubImage2D(GetTarget(ACubeTarget), ALevel, AXOffset, AYOffset,
    ALeft, ABottom, AWidth, AHeight);
  Assert(_Check('TGLTexture.SubCopy'));
end;

procedure TGLTexture.SubUpload(const AFormat: TGLPixelFormat; const AXOffset,
  AYOffset, AWidth, AHeight: Integer; const AData: Pointer;
  const ALevel: Integer; const AType: TGLPixelDataType;
  const ACubeTarget: TGLCubeTarget);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.SubUpload'));
  glTexSubImage2D(GetTarget(ACubeTarget), ALevel, AXOffset, AYOffset, AWidth,
    AHeight, Ord(AFormat), Ord(AType), AData);
  Assert(_Check('TGLTexture.SubUpload'));
end;

procedure TGLTexture.SubUploadCompressed(const AFormat: Cardinal;
  const AXOffset, AYOffset, AWidth, AHeight: Integer; const AData: Pointer;
  const ADataSize, ALevel: Integer; const ACubeTarget: TGLCubeTarget);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.SubUploadCompressed'));
  glCompressedTexSubImage2D(GetTarget(ACubeTarget), ALevel, AXOffset, AYOffset,
    AWidth, AHeight, AFormat, ADataSize, AData);
  Assert(_Check('TGLTexture.SubUploadCompressed'));
end;

procedure TGLTexture.Unbind;
begin
  glBindTexture(FType, 0);
  Assert(_Check('TGLTexture.Unbind'));
end;

procedure TGLTexture.UnbindFromTextureUnit(const ATextureUnit: Cardinal);
begin
  glActiveTexture(GL_TEXTURE0 + ATextureUnit);
  Assert(_Check('TGLTexture.UnbindFromTextureUnit'));
  glBindTexture(FType, 0);
  Assert(_Check('TGLTexture.Unbind'));
end;

procedure TGLTexture.Upload(const AFormat: TGLPixelFormat; const AWidth,
  AHeight: Integer; const AData: Pointer; const ALevel: Integer;
  const AType: TGLPixelDataType; const ACubeTarget: TGLCubeTarget);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.Upload'));
  glTexImage2D(GetTarget(ACubeTarget), ALevel, Ord(AFormat), AWidth, AHeight, 0,
    Ord(AFormat), Ord(AType), AData);
  Assert(_Check('TGLTexture.Upload'));
end;

procedure TGLTexture.UploadCompressed(const AFormat: Cardinal; const AWidth,
  AHeight: Integer; const AData: Pointer; const ADataSize, ALevel: Integer;
  const ACubeTarget: TGLCubeTarget);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.UploadCompressed'));
  glCompressedTexImage2D(GetTarget(ACubeTarget), ALevel, AFormat, AWidth,
    AHeight, 0, ADataSize, AData);
  Assert(_Check('TGLTexture.UploadCompressed'));
end;

procedure TGLTexture.WrapS(const AWrap: TGLWrapMode);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.WrapS'));
  glTexParameteri(FType, GL_TEXTURE_WRAP_S, Ord(AWrap));
  Assert(_Check('TGLTexture.WrapS'));
end;

procedure TGLTexture.WrapT(const AWrap: TGLWrapMode);
begin
  Assert(_CheckBinding(FType, FHandle, 'TGLTexture.WrapT'));
  glTexParameteri(FType, GL_TEXTURE_WRAP_T, Ord(AWrap));
  Assert(_Check('TGLTexture.WrapT'));
end;

{ TGLRenderbuffer }

procedure TGLRenderbuffer.Bind;
begin
  {$IF Defined(MACOS) and not Defined(IOS)}
  glBindRenderbufferEXT(GL_RENDERBUFFER, FHandle);
  {$ELSE}
  glBindRenderbuffer(GL_RENDERBUFFER, FHandle);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.Bind'));
end;

procedure TGLRenderbuffer.Delete;
begin
  if (FHandle <> 0) then
  begin
    {$IF Defined(MACOS) and not Defined(IOS)}
    glDeleteRenderbuffersEXT(1, @FHandle);
    {$ELSE}
    glDeleteRenderbuffers(1, @FHandle);
    {$ENDIF}
    FHandle := 0;
    Assert(_Check('TGLRenderbuffer.Delete'));
  end;
end;

function TGLRenderbuffer.GetAlphaSize: Integer;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetAlphaSize'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_ALPHA_SIZE, @Result);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_ALPHA_SIZE, @Result);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetAlphaSize'));
end;

function TGLRenderbuffer.GetBlueSize: Integer;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetBlueSize'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_BLUE_SIZE, @Result);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_BLUE_SIZE, @Result);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetBlueSize'));
end;

class function TGLRenderbuffer.GetCurrent: TGLRenderbuffer;
begin
  glGetIntegerv(GL_RENDERBUFFER_BINDING, @Result.FHandle);
  Assert(_Check('TGLRenderbuffer.GetCurrent'));
end;

function TGLRenderbuffer.GetDepthSize: Integer;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetDepthSize'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_DEPTH_SIZE, @Result);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_DEPTH_SIZE, @Result);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetDepthSize'));
end;

function TGLRenderbuffer.GetFormat: TGLRenderbufferFormat;
var
  Value: GLint;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetFormat'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_INTERNAL_FORMAT, @Value);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_INTERNAL_FORMAT, @Value);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetFormat'));
  Result := TGLRenderbufferFormat(Value);
end;

function TGLRenderbuffer.GetGreenSize: Integer;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetGreenSize'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_GREEN_SIZE, @Result);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_GREEN_SIZE, @Result);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetGreenSize'));
end;

function TGLRenderbuffer.GetHeight: Integer;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetHeight'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, @Result);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, @Result);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetHeight'));
end;

class function TGLRenderbuffer.GetMaxRenderbufferSize: Integer;
begin
  glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE, @Result);
  Assert(_Check('TGLRenderbuffer.GetMaxRenderbufferSize'));
end;

function TGLRenderbuffer.GetRedSize: Integer;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetRedSize'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_RED_SIZE, @Result);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_RED_SIZE, @Result);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetRedSize'));
end;

function TGLRenderbuffer.GetStencilSize: Integer;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetStencilSize'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_STENCIL_SIZE, @Result);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_STENCIL_SIZE, @Result);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetStencilSize'));
end;

function TGLRenderbuffer.GetWidth: Integer;
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.GetWidth'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetRenderbufferParameterivEXT(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, @Result);
  {$ELSE}
  glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, @Result);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.GetWidth'));
end;

function TGLRenderbuffer.IsBound: Boolean;
var
  CurrentlyBoundBuffer: GLenum;
begin
  glGetIntegerv(_GetTargetBinding(GL_RENDERBUFFER), @CurrentlyBoundBuffer);
  Assert(_Check('TGLRenderbuffer.IsBound'));
  Result := (CurrentlyBoundBuffer = FHandle);
end;

procedure TGLRenderbuffer.New;
begin
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGenRenderbuffersEXT(1, @FHandle);
  {$ELSE}
  glGenRenderbuffers(1, @FHandle);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.New'));
end;

procedure TGLRenderbuffer.Storage(const AWidth, AHeight: Integer;
  const AFormat: TGLRenderbufferFormat);
begin
  Assert(_CheckBinding(GL_RENDERBUFFER, FHandle, 'TGLRenderbuffer.Storage'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glRenderbufferStorageEXT(GL_RENDERBUFFER, Ord(AFormat), AWidth, AHeight);
  {$ELSE}
  glRenderbufferStorage(GL_RENDERBUFFER, Ord(AFormat), AWidth, AHeight);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.Storage'));
end;

procedure TGLRenderbuffer.Unbind;
begin
  {$IF Defined(MACOS) and not Defined(IOS)}
  glBindRenderbufferEXT(GL_RENDERBUFFER, 0);
  {$ELSE}
  glBindRenderbuffer(GL_RENDERBUFFER, 0);
  {$ENDIF}
  Assert(_Check('TGLRenderbuffer.Unbind'));
end;

{ TGLFramebuffer }

procedure TGLFramebuffer.AttachRenderbuffer(
  const AAttachment: TGLFramebufferAttachment;
  const ARenderbuffer: TGLRenderbuffer);
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.AttachRenderbuffer'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glFramebufferRenderbufferEXT(GL_FRAMEBUFFER, Ord(AAttachment), GL_RENDERBUFFER,
    ARenderbuffer.FHandle);
  {$ELSE}
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, Ord(AAttachment), GL_RENDERBUFFER,
    ARenderbuffer.FHandle);
  {$ENDIF}
  Assert(_Check('TGLFramebuffer.AttachRenderbuffer'));
end;

procedure TGLFramebuffer.AttachTexture(
  const AAttachment: TGLFramebufferAttachment; const ATexture: TGLTexture;
  const ACubeTarget: TGLCubeTarget);
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.AttachTexture'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER, Ord(AAttachment),
    ATexture.GetTarget(ACubeTarget), ATexture.FHandle, 0);
  {$ELSE}
  glFramebufferTexture2D(GL_FRAMEBUFFER, Ord(AAttachment),
    ATexture.GetTarget(ACubeTarget), ATexture.FHandle, 0);
  {$ENDIF}

  Assert(_Check('TGLFramebuffer.AttachTexture'));
end;

procedure TGLFramebuffer.Bind;
begin
  {$IF Defined(MACOS) and not Defined(IOS)}
  glBindFramebufferEXT(GL_FRAMEBUFFER, FHandle);
  {$ELSE}
  glBindFramebuffer(GL_FRAMEBUFFER, FHandle);
  {$ENDIF}
  Assert(_Check('TGLFramebuffer.Bind'));
end;

procedure TGLFramebuffer.Delete;
begin
  if (FHandle <> 0) then
  begin
    {$IF Defined(MACOS) and not Defined(IOS)}
    glDeleteFramebuffersEXT(1, @FHandle);
    {$ELSE}
    glDeleteFramebuffers(1, @FHandle);
    {$ENDIF}
    FHandle := 0;
    Assert(_Check('TGLFramebuffer.Delete'));
  end;
end;

procedure TGLFramebuffer.DetachRenderbuffer(
  const AAttachment: TGLFramebufferAttachment);
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.DetachRenderbuffer'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glFramebufferRenderbufferEXT(GL_FRAMEBUFFER, Ord(AAttachment), GL_RENDERBUFFER, 0);
  {$ELSE}
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, Ord(AAttachment), GL_RENDERBUFFER, 0);
  {$ENDIF}
  Assert(_Check('TGLFramebuffer.DetachRenderbuffer'));
end;

procedure TGLFramebuffer.DetachTexture(
  const AAttachment: TGLFramebufferAttachment);
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.DetachTexture'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  glFramebufferTexture2DEXT(GL_FRAMEBUFFER, Ord(AAttachment), GL_TEXTURE_2D, 0, 0);
  {$ELSE}
  glFramebufferTexture2D(GL_FRAMEBUFFER, Ord(AAttachment), GL_TEXTURE_2D, 0, 0);
  {$ENDIF}
  Assert(_Check('TGLFramebuffer.DetachTexture'));
end;

function TGLFramebuffer.GetAlphaBits: Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetAlphaBits'));
  glGetIntegerv(GL_ALPHA_BITS, @Result);
  Assert(_Check('TGLFramebuffer.GetAlphaBits'));
end;

function TGLFramebuffer.GetAttachedCubeMapFace(
  const AAttachment: TGLFramebufferAttachment): TGLCubeTarget;
var
  Face: GLint;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetAttachedCubeMapFace'));

  {$IFDEF DEBUG}
  {$IFOPT C+}
  if (GetAttachedObjectType(AAttachment) <> TGLFramebufferAttachmentType.Texture) then
    raise EGLError.Create(GL_INVALID_OPERATION, 'TGLFramebuffer.GetAttachedCubeMapFace');
  {$ENDIF}
  {$ENDIF}

  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetFramebufferAttachmentParameterivEXT(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE, @Face);
  {$ELSE}
  glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE, @Face);
  {$ENDIF}

  Assert(_Check('TGLFramebuffer.GetAttachedCubeMapFace'));
  Result := TGLCubeTarget(Face - GL_TEXTURE_CUBE_MAP_POSITIVE_X);
end;

function TGLFramebuffer.GetAttachedObjectType(
  const AAttachment: TGLFramebufferAttachment): TGLFramebufferAttachmentType;
var
  Value: GLint;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetAttachedObjectType'));

  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetFramebufferAttachmentParameterivEXT(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, @Value);
  {$ELSE}
  glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, @Value);
  {$ENDIF}

  Assert(_Check('TGLFramebuffer.GetAttachedObjectType'));
  Result := TGLFramebufferAttachmentType(Value);
end;

function TGLFramebuffer.GetAttachedRenderbuffer(
  const AAttachment: TGLFramebufferAttachment): TGLRenderbuffer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetAttachedRenderbuffer'));

  {$IFDEF DEBUG}
  {$IFOPT C+}
  if (GetAttachedObjectType(AAttachment) <> TGLFramebufferAttachmentType.RenderBuffer) then
    raise EGLError.Create(GL_INVALID_OPERATION, 'TGLFramebuffer.GetAttachedRenderbuffer');
  {$ENDIF}
  {$ENDIF}

  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetFramebufferAttachmentParameterivEXT(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, @Result.FHandle);
  {$ELSE}
  glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, @Result.FHandle);
  {$ENDIF}

  Assert(_Check('TGLFramebuffer.GetAttachedRenderbuffer'));
end;

function TGLFramebuffer.GetAttachedTexture(
  const AAttachment: TGLFramebufferAttachment): TGLTexture;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetAttachedTexture'));

  {$IFDEF DEBUG}
  {$IFOPT C+}
  if (GetAttachedObjectType(AAttachment) <> TGLFramebufferAttachmentType.Texture) then
    raise EGLError.Create(GL_INVALID_OPERATION, 'TGLFramebuffer.GetAttachedTexture');
  {$ENDIF}
  {$ENDIF}

  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetFramebufferAttachmentParameterivEXT(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, @Result.FHandle);
  {$ELSE}
  glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, @Result.FHandle);
  {$ENDIF}

  Assert(_Check('TGLFramebuffer.GetAttachedTexture'));
end;

function TGLFramebuffer.GetAttachedTextureLevel(
  const AAttachment: TGLFramebufferAttachment): Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetAttachedTextureLevel'));

  {$IFDEF DEBUG}
  {$IFOPT C+}
  if (GetAttachedObjectType(AAttachment) <> TGLFramebufferAttachmentType.Texture) then
    raise EGLError.Create(GL_INVALID_OPERATION, 'TGLFramebuffer.GetAttachedTextureLevel');
  {$ENDIF}
  {$ENDIF}

  {$IF Defined(MACOS) and not Defined(IOS)}
  glGetFramebufferAttachmentParameterivEXT(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL, @Result);
  {$ELSE}
  glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, Ord(AAttachment),
    GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL, @Result);
  {$ENDIF}

  Assert(_Check('TGLFramebuffer.GetAttachedTextureLevel'));
end;

function TGLFramebuffer.GetBlueBits: Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetBlueBits'));
  glGetIntegerv(GL_BLUE_BITS, @Result);
  Assert(_Check('TGLFramebuffer.GetBlueBits'));
end;

class function TGLFramebuffer.GetColorReadFormat: TGLPixelFormat;
var
  Value: GLint;
begin
  glGetIntegerv(GL_IMPLEMENTATION_COLOR_READ_FORMAT, @Value);
  Assert(_Check('TGLFramebuffer.GetColorReadFormat'));
  Result := TGLPixelFormat(Value);
end;

class function TGLFramebuffer.GetColorReadType: TGLPixelDataType;
var
  Value: GLint;
begin
  glGetIntegerv(GL_IMPLEMENTATION_COLOR_READ_TYPE, @Value);
  Assert(_Check('TGLFramebuffer.GetColorReadType'));
  Result := TGLPixelDataType(Value);
end;

class function TGLFramebuffer.GetCurrent: TGLFramebuffer;
begin
  { NOTE: The default framebuffer is not always 0. For example, on iOS, you
    cannot write to framebuffer 0, and you must always create a framebuffer and
    attach it to a view. So the default framebuffer for our purposes, would be
    the one attached to that view. }
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, @Result.FHandle);
  Assert(_Check('TGLFramebuffer.GetCurrent'));
end;

function TGLFramebuffer.GetDepthBits: Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetDepthBits'));
  glGetIntegerv(GL_DEPTH_BITS, @Result);
  Assert(_Check('TGLFramebuffer.GetDepthBits'));
end;

function TGLFramebuffer.GetGreenBits: Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetGreenBits'));
  glGetIntegerv(GL_GREEN_BITS, @Result);
  Assert(_Check('TGLFramebuffer.GetGreenBits'));
end;

function TGLFramebuffer.GetRedBits: Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetRedBits'));
  glGetIntegerv(GL_RED_BITS, @Result);
  Assert(_Check('TGLFramebuffer.GetRedBits'));
end;

function TGLFramebuffer.GetSampleBuffers: Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetSampleBuffers'));
  glGetIntegerv(GL_SAMPLE_BUFFERS, @Result);
  Assert(_Check('TGLFramebuffer.GetSampleBuffers'));
end;

function TGLFramebuffer.GetSamples: Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetSamples'));
  glGetIntegerv(GL_SAMPLES, @Result);
  Assert(_Check('TGLFramebuffer.GetSamples'));
end;

function TGLFramebuffer.GetStencilBits: Integer;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.GetStencilBits'));
  glGetIntegerv(GL_STENCIL_BITS, @Result);
  Assert(_Check('TGLFramebuffer.GetStencilBits'));
end;

function TGLFramebuffer.IsBound: Boolean;
var
  CurrentlyBoundBuffer: GLenum;
begin
  glGetIntegerv(_GetTargetBinding(GL_FRAMEBUFFER), @CurrentlyBoundBuffer);
  Assert(_Check('TGLFramebuffer.IsBound'));
  Result := (CurrentlyBoundBuffer = FHandle);
end;

procedure TGLFramebuffer.New;
begin
  {$IF Defined(MACOS) and not Defined(IOS)}
  glGenFramebuffersEXT(1, @FHandle);
  {$ELSE}
  glGenFramebuffers(1, @FHandle);
  {$ENDIF}
  Assert(_Check('TGLFramebuffer.New'));
end;

procedure TGLFramebuffer.ReadPixels(const ALeft, ABottom, AWidth,
  AHeight: Integer; const AData: Pointer; const AFormat: TGLPixelFormat;
  const ADataType: TGLPixelDataType);
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.ReadPixels'));
  glReadPixels(ALeft, ABottom, AWidth, AHeight, Ord(AFormat), Ord(ADataType), AData);
  Assert(_Check('TGLFramebuffer.ReadPixels'));
end;

function TGLFramebuffer.Status: TGLFramebufferStatus;
begin
  Assert(_CheckBinding(GL_FRAMEBUFFER, FHandle, 'TGLFramebuffer.Status'));
  {$IF Defined(MACOS) and not Defined(IOS)}
  Result := TGLFramebufferStatus(glCheckFramebufferStatusEXT(GL_FRAMEBUFFER));
  {$ELSE}
  Result := TGLFramebufferStatus(glCheckFramebufferStatus(GL_FRAMEBUFFER));
  {$ENDIF}
  Assert(_Check('TGLFramebuffer.Status'));
end;

end.
