program E10Mandelbrot;

{$R *.res}

uses
  Sample.App,
  App in 'App.pas';

begin
  RunApp(TMandelbrotApp, 800, 600, 'Mandelbrot Fractal');
end.
