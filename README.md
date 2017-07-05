# Ooogles - Object Oriented OpenGL-ES 2.0

Ooogles is a ultra-thin object oriented Delphi wrapper around OpenGL-ES 2.0 with near-zero impact on performance. It can also be used to create OpenGL applications for desktop platforms using the OpenGL-ES subset of OpenGL.

This wrapper is still pretty low-level. It is not a "rendering engine" or high-level framework, so you still need OpenGL knowledge.

## Features

Ooogles has the following features:
* Encapsulates OpenGL "objects" into Delphi records+methods for a better organized and easier to use interface to OpenGL.
* Provides type-safe access to most OpenGL constructs. For example:
  * In OpenGL, every "object" is just an integer (or Handle), and nothing prevents you to call a texture API on a shader object. This wrapper wraps the API into classes (actually records) like `TGLTexture` and `TGLShader`, preventing these types of errors.
  * Another big source of common OpenGL errors is to use incorrect enumeration values, resulting in `GL_INVALID_ENUM` errors. This wrapper uses true Delphi enums instead, preventing most of these errors.
* The wrapper is very thin. OpenGL handles are not wrapped into Delphi classes or object interfaces, but in records instead. Most methods are inlined and wrap just a single OpenGL API. So the overhead of the wrapper is mostly zero.
* A few methods perform multiple OpenGL calls for convenience. For example, when compiling a shader, the wrapper not only calls the compile API, but also checks for compilation errors. In `DEBUG` mode, it will expose those errors through exceptions, and it will also log any warnings to the debug console.
* OpenGL APIs that are not tied to an OpenGL "object" are wrapped in the static `gl` class (which acts more like a namespace). For example, the OpenGL API `glClear` is wrapped in the method `gl.Clear`.
* The wrapper provides some features to make OpenGL-ES specific constructs compatible with (desktop) OpenGL. For example, OpenGL-ES requires the use of precision qualifiers in fragment shaders, but these are not supported by OpenGL. This wrapper will modify the shader source so it will work with OpenGL as well.
* The wrapper only exposes methods that are OpenGL-ES compliant, so you cannot accidentially use APIs that only work with OpenGL, but not with OpenGL-ES. However, you always have access to the underlying OpenGL handle and so you can use it directly with the OpenGL API if you want to.
* The wrapper handles the sometimes slightly different API names on different platforms.
* When compiling with the `DEBUG` conditional define, and assertions enabled (the default configuration for Debug builds), every OpenGL call is checked for errors, and an exception is raised when an error occurs, indicating the type of error and in which method it occurred. When `DEBUG` is not defined, or assertions are disabled, all error checking code is removed from the build so it has zero impact on performance.
* Also, when compiling in `DEBUG` mode with assertions enabled, warnings will be logged to the debug console if you forget to bind an object before you use it (or when a different object than the one you are using is currently bound).
* The wrapper is [well documented](https://neslib.github.io/Ooogles/). Each record and method contains documentation from the official OpenGL-ES 2.0 reference, as well as custom documentation where needed. The documentation also shows which original OpenGL API call(s) are used in the implementation, to make it easier to find some method if you already know the API equivalent.
* Comes with various samples that show how to use this wrapper. These samples work on Windows, macOS, iOS and Android. However, they do *not* use the FireMonkey framework, but a custom light-weight (and limited) framework that you can find in the `Examples\Common` directory.

## Non-features

The wrapper does *not* provide higher-level features such as automatic OpenGL resource managment. You need to release OpenGL resources yourself when you no longer need them. Resources are usually created using a method called `New` and released using a methods called `Delete`. For example:

```Delphi
var
  Texture: TGLTexture;
begin
  Texture.New;
  // Do something with texture
  Texture.Delete;
end;
```

I may add automatic resource management in the future if and when Delphi gets support for record finalizers.

## Dependencies

This wrapper has no dependencies other than requiring the [FastMath](https://github.com/neslib/FastMath) library. This library offers (among other things) very fast vector and matrix math calculations, which makes it ideal for use in high performance (OpenGL) applications.

## Getting Started

To get started:
* Make sure the FastMath directory is at the same level as the Ooogles directory.
* You usually want to add the `FM_COLUMN_MAJOR` conditional define to your project (for All configurations - All platforms). This enables column-major storage of matrices, which makes more sense for OpenGL applications.
* *After* you have created and activated your OpenGL context, call `InitOoogles`. This is needed to emulate OpenGL-ES on OpenGL platforms. If your application uses multiple contexts, you must call InitOoogles once for each context (after making it current). Take a look at the `Sample.Platform.*` units for examples of when to call this.
* When using Ooogles in your unit, you may get compiler hints saying something like *"H2443 Inline function X has not been expanded because unit Y is not specified in USES list"*. This is because Ooogles inlines most functions and Delphi requires you use the OpenGL units for inlining to work. Unfortunately, the names of those units differ by platform (eg. `Winapi.OpenGL`, `iOSapi.OpenGLES` etc). To make it easier to use the correct OpenGL units, it is easiest if you include the 'OpenGL.inc' file in your uses clauses instead, as in:
```Delphi
uses
  {$INCLUDE 'OpenGL.inc'}
  Neslib.Ooogles;
```
Just make sure you "use" at least one other unit after the include file.

## Main Classes and Documentation

The following is a list of the main classes (actually records) used in Ooogles, along with links to their documentation:
* [gl](https://neslib.github.io/Ooogles/Neslib.Ooogles.gl.html): static class (or namespace) for OpenGL APIs that are not tied to a specific object.
* [TGLShader](https://neslib.github.io/Ooogles/Neslib.Ooogles.TGLShader.html): a vertex or fragment shader.
* [TGLProgram](https://neslib.github.io/Ooogles/Neslib.Ooogles.TGLProgram.html): a program that combines a vertex shader and a fragment shader.
* [TGLVertexAttrib](https://neslib.github.io/Ooogles/Neslib.Ooogles.TGLVertexAttrib.html): represents a single vertex attribute in a TGLProgram. These are variables marked with `attribute` in a vertex shader.
* [TGLUniform](https://neslib.github.io/Ooogles/Neslib.Ooogles.TGLUniform.html): represents a uniform in a TGLProgram. These are variables marked with `uniform` in a vertex or fragment shader.
* [TGLBuffer](https://neslib.github.io/Ooogles/Neslib.Ooogles.TGLBuffer.html): a (vertex) array buffer or element array (index) buffer.
* [TGLTexture](https://neslib.github.io/Ooogles/Neslib.Ooogles.TGLTexture.html): a 2D texture or cubemap texture.
* [TGLFramebuffer](https://neslib.github.io/Ooogles/Neslib.Ooogles.TGLFramebuffer.html): a framebuffer.
* [TGLRenderbuffer](https://neslib.github.io/Ooogles/Neslib.Ooogles.TGLRenderbuffer.html): a renderbuffer. Serves as storage for a TGLFramebuffer.

## Mapping from OpenGL to Ooogles

If you are fluent in OpenGL, the you may find the following table helpful to translate from a OpenGL API to an Ooogles method. It should all be pretty straightforward.

| OpenGL                                | Ooogles                                    |
|---------------------------------------|--------------------------------------------|
| glActiveTexture                       | TGLTexture.BindToTextureUnit               |
| glAttachShader                        | TGLProgram.AttachShader                    |
| glBindAttribLocation                  | TGLVertexAttrib.Bind                       |
| glBindBuffer                          | TGLBuffer.Bind                             |
| glBindFramebuffer                     | TGLFramebuffer.Bind                        |
| glBindTexture                         | TGLTexture.Bind                            |
| glBlendColor                          | gl.BlendColor                              |
| glBlendEquation                       | gl.BlendEquation                           |
| glBlendEquationSeparate               | gl.BlendEquationSeparate                   |
| glBlendFunc                           | gl.BlendFunc                               |
| glBlendFuncSeparate                   | gl.BlendFuncSeparate                       |
| glBufferData                          | TGLBuffer.Data                             |
| glBufferSubData                       | TGLBuffer.SubData                          |
| glCheckFramebufferStatus              | TGLFramebuffer.Status                      |
| glClear                               | gl.Clear                                   |
| glClearColor                          | gl.ClearColor                              |
| glClearDepthf                         | gl.ClearDepth                              |
| glClearStencil                        | gl.ClearStencil                            |
| glColorMask                           | gl.ColorMask                               |
| glCompileShader                       | TGLShader.Compile                          |
| glCompressedTexImage2D                | TGLTexture.UploadCompressed                |
| glCompressedTexSubImage2D             | TGLTexture.SubUploadCompressed             |
| glCopyTexImage2D                      | TGLTexture.Copy                            |
| glCopyTexSubImage2D                   | TGLTexture.SubCopy                         |
| glCreateProgram                       | TGLProgram.New                             |
| glCreateShader                        | TGLShader.New                              |
| glCullFace                            | gl.CullFace                                |
| glDeleteBuffers                       | TGLBuffer.Delete                           |
| glDeleteFramebuffers                  | TGLFramebuffer.Delete                      |
| glDeleteProgram                       | TGLProgram.Delete                          |
| glDeleteRenderbuffers                 | TGLRenderbuffer.Delete                     |
| glDeleteShader                        | TGLShader.Delete                           |
| glDeleteTextures                      | TGLTexture.Delete                          |
| glDepthFunc                           | gl.DepthFunc                               |
| glDepthMask                           | gl.DepthMask                               |
| glDepthRangef                         | gl.DepthRange                              |
| glDetachShader                        | TGLProgram.DetachShader                    |
| glDisable                             | gl.Disable                                 |
| glDisableVertexAttribArray            | TGLVertexAttrib.Disable                    |
| glDrawArrays                          | gl.DrawArrays                              |
| glDrawElements                        | gl.DrawElements                            |
| glEnable                              | gl.Enable                                  |
| glEnableVertexAttribArray             | TGLVertexAttrib.Enable                     |
| glFinish                              | gl.Finish                                  |
| glFlush                               | gl.Flush                                   |
| glFramebufferRenderbuffer             | TGLFramebuffer.AttachRenderbuffer          |
| glFramebufferTexture2D                | TGLFramebuffer.AttachTexture               |
| glFrontFace                           | gl.FrontFace                               |
| glGenBuffers                          | TGLBuffer.New                              |
| glGenFramebuffers                     | TGLFramebuffer.New                         |
| glGenRenderbuffers                    | TGLRenderbuffer.New                        |
| glGenTextures                         | TGLTexture.New                             |
| glGenerateMipmap                      | TGLTexture.GenerateMipmap                  |
| glGetBooleanv                         | various Get* methods                       |
| glGetFloatv                           | various Get* methods                       |
| glGetIntegerv                         | various Get* methods                       |
| glGetActiveAttrib                     | TGLProgram.GetAttributeInfo                |
| glGetActiveUniform                    | TGLProgram.GetUniformInfo                  |
| glGetAttachedShaders                  | TGLProgram.GetAttachedShaders              |
| glGetAttribLocation                   | TGLVertexAttrib.Init                       |
| glGetBufferParameteriv                | TGLBuffer.Get*                             |
| glGetError                            | gl.GetError                                |
| glGetFramebufferAttachmentParameteriv | TGLFramebuffer.Get*                        |
| glGetProgramInfoLog                   | TGLProgram (in DEBUG mode)                 |
| glGetProgramiv                        | TGLProgram.Get*                            |
| glGetRenderbufferParameteriv          | TGLRenderbuffer.Get*                       |
| glGetShaderInfoLog                    | TGLShader (in DEBUG mode)                  |
| glGetShaderSource                     | TGLShader.GetSource                        |
| glGetShaderiv                         | TGLShader.Get*                             |
| glGetString                           | gl.Get*                                    |
| glGetTexParameter*                    | TGLTexture.Get*                            |
| glGetUniform                          | TGLUniform.GetValue                        |
| glGetUniformLocation                  | TGLUniform.Init                            |
| glGetVertexAttrib*                    | TGLVertexAttrib.Get*                       |
| glGetVertexAttribPointerv             | TGLVertexAttrib.GetOffset/GetData          |
| glHint                                | TGLTexture.MipmapHint                      |
| glIsBuffer                            | not needed                                 |
| glIsEnabled                           | gl.IsEnabled                               |
| glIsFramebuffer                       | not needed                                 |
| glIsProgram                           | not needed                                 |
| glIsRenderbuffer                      | not needed                                 |
| glIsShader                            | not needed                                 |
| glIsTexture                           | not needed                                 |
| glLineWidth                           | gl.LineWidth                               |
| glLinkProgram                         | TGLProgram.Link                            |
| glPixelStorei                         | gl.PixelStore                              |
| glPolygonOffset                       | gl.PolygonOffset                           |
| glReadPixels                          | TGLFramebuffer.ReadPixels                  |
| glReleaseShaderCompiler               | TGLShader.ReleaseCompiler                  |
| glRenderbufferStorage                 | TGLRenderbuffer.Storage                    |
| glSampleCoverage                      | gl.SampleCoverage                          |
| glScissor                             | gl.Scissor                                 |
| glShaderSource                        | TGLShader.SetSource                        |
| glStencilFunc                         | gl.StencilFunc                             |
| glStencilFuncSeparate                 | gl.StencilFuncSeparate                     |
| glStencilMask                         | gl.StencilMask                             |
| glStencilMaskSeparate                 | gl.StencilMaskSeparate                     |
| glStencilOp                           | gl.StencilOp                               |
| glStencilOpSeparate                   | gl.StencilOpSeparate                       |
| glTexImage2D                          | TGLTexture.Upload                          |
| glTexParameter                        | TGLTexture.MinFilter/MagFilter/WrapS/WrapT |
| glTexSubImage2D                       | TGLTexture.SubUpload                       |
| glUniform*                            | TGLUniform.SetValue/SetValues              |
| glUseProgram                          | TGLProgram.Use                             |
| glValidateProgram                     | TGLProgram.Validate                        |
| glVertexAttrib*                       | TGLVertexAttrib.SetValue                   |
| glVertexAttribPointer                 | TGLVertexAttrib.SetConfig/SetData          |
| glViewport                            | gl.Viewport                                |
