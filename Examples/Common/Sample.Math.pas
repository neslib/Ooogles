unit Sample.Math;

{$INCLUDE 'Sample.inc'}

interface

uses
  Neslib.FastMath;

procedure OrbitCameraMatrix(const ATarget: TVector3; const ARadius: Single;
  const AAzimuth, AElevation: Single; out AMatrix: TMatrix4);

implementation

procedure OrbitCameraMatrix(const ATarget: TVector3; const ARadius: Single;
  const AAzimuth, AElevation: Single; out AMatrix: TMatrix4);
var
  SA, CA, SE, CE: Single;
  X, Y, Z: TVector3;
begin
  FastSinCos(AAzimuth, SA, CA);
  FastSinCos(AElevation, SE, CE);

  Z.Init(CE * CA, SE, CE * -SA);
  X.Init(-SA, 0, -CA);
  Y := Z.Cross(X);

  AMatrix.Init(
    X.X, Y.X, Z.X, 0,
    X.Y, Y.Y, Z.Y, 0,
    X.Z, Y.Z, Z.Z, 0,
    X.Dot(Z) * -ARadius - X.Dot(ATarget),
    Y.Dot(Z) * -ARadius - Y.Dot(ATarget),
    Z.Dot(Z) * -ARadius - Z.Dot(ATarget), 1);
end;

end.
