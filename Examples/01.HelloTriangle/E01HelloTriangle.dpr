program E01HelloTriangle;

{$R *.res}

uses
  Sample.App,
  App in 'App.pas';

begin
  RunApp(TTriangleApp, 800, 600, 'Hello Triangle');
end.
