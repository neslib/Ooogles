unit Sample.Geometry;

{$INCLUDE 'Sample.inc'}

interface

uses
  Neslib.FastMath;

type
  { Geometry of a cube. }
  TCubeGeometry = record
  public
    Positions: TArray<TVector3>;
    Normals: TArray<TVector3>;
    Tangents: TArray<TVector3>;
    TexCoords: TArray<TVector2>;
    Indices: TArray<UInt16>;
  public
    procedure Generate(const ARadius: Single = 0.5);
    procedure Clear;
    procedure DrawWithBoundIndexBuffer;
    procedure DrawWithIndices;
  end;

type
  { Geometry of a sphere. }
  TSphereGeometry = record
  public
    Positions: TArray<TVector3>;
    Normals: TArray<TVector3>;
    TexCoords: TArray<TVector2>;
    Indices: TArray<UInt16>;
  public
    procedure Generate(const ASliceCount: Integer = 18;
      const ARadius: Single = 1.0);
    procedure Clear;
    procedure DrawWithBoundIndexBuffer;
    procedure DrawWithIndices;
  end;

type
  { Geometry of a torus. }
  TTorusGeometry = record
  public
    Positions: TArray<TVector3>;
    Normals: TArray<TVector3>;
    TexCoords: TArray<TVector2>;
    Indices: TArray<UInt16>;
  public
    procedure Generate(const ASections: Integer = 36; const ARings: Integer = 24;
      const AOuterRadius: Single = 1.0; const AInnerRadius: Single = 0.5);
    procedure Clear;
    procedure DrawWithBoundIndexBuffer;
    procedure DrawWithIndices;
  end;

type
  { Geometry of a twisted torus. }
  TTwistedTorusGeometry = record
  public
    Positions: TArray<TVector3>;
    Normals: TArray<TVector3>;
    Tangents: TArray<TVector3>;
    Indices: TArray<UInt16>;
    StripSize: Integer;
    StripCount: Integer;
  private
    procedure GenerateTangents(const ASections, ARings, ATwist: Integer);
  public
    procedure Generate(const ASections: Integer = 12; const ARings: Integer = 48;
      const ATwist: Integer = 12; const AOuterRadius: Single = 1.0;
      const AInnerRadius: Single = 0.5; const AThickness: Single = 0.02);
    procedure Clear;
    procedure Draw;
  end;

type
  { Geometry of a spiral sphere. }
  TSpiralSphereGeometry = record
  public
    Positions: TArray<TVector3>;
    Normals: TArray<TVector3>;
    Indices: TArray<UInt16>;
    StripSize: Integer;
    StripCount: Integer;
  private
    class procedure MakeVectors(var ADst: TArray<TVector3>; var AK: Integer;
      const ASign, ARadius: Single; const ABands, ADivisions,
      ASegments: Integer); static;
    class procedure MakeSideVerts(var ADst: TArray<TVector3>; var AK: Integer;
      const ABands, ASegments: Integer; const ARadius, AThickness: Single); static;
    procedure GenerateIndices(const ABands, ADivisions, ASegments: Integer);
  public
    procedure Generate(const ABands: Integer = 4; const ADivisions: Integer = 8;
      const ASegments: Integer = 48; const ARadius: Single = 1.0;
      const AThickness: Single = 0.1);
    procedure Clear;
    procedure Draw;
  end;

implementation

uses
  {$INCLUDE 'OpenGL.inc'}
  Neslib.Ooogles;

{ TCubeGeometry }

procedure TCubeGeometry.Clear;
begin
  Positions := nil;
  Normals := nil;
  Tangents := nil;
  TexCoords := nil;
  { We keep Indices, since they may be used with Draw* }
end;

procedure TCubeGeometry.DrawWithBoundIndexBuffer;
begin
  gl.DrawElements(TGLPrimitiveType.Triangles, Length(Indices),
    TGLIndexType.UnsignedShort);
end;

procedure TCubeGeometry.DrawWithIndices;
begin
  gl.DrawElements(TGLPrimitiveType.Triangles, Indices);
end;

procedure TCubeGeometry.Generate(const ARadius: Single);
begin
  SetLength(Positions, 24);
  SetLength(Normals, 24);
  SetLength(Tangents, 24);
  SetLength(TexCoords, 24);
  SetLength(Indices, 36);

  Positions[ 0].Init(-ARadius, -ARadius, -ARadius);
  Positions[ 1].Init(-ARadius, -ARadius,  ARadius);
  Positions[ 2].Init( ARadius, -ARadius,  ARadius);
  Positions[ 3].Init( ARadius, -ARadius, -ARadius);
  Positions[ 4].Init(-ARadius,  ARadius, -ARadius);
  Positions[ 5].Init(-ARadius,  ARadius,  ARadius);
  Positions[ 6].Init( ARadius,  ARadius,  ARadius);
  Positions[ 7].Init( ARadius,  ARadius, -ARadius);
  Positions[ 8].Init(-ARadius, -ARadius, -ARadius);
  Positions[ 9].Init(-ARadius,  ARadius, -ARadius);
  Positions[10].Init( ARadius,  ARadius, -ARadius);
  Positions[11].Init( ARadius, -ARadius, -ARadius);
  Positions[12].Init(-ARadius, -ARadius,  ARadius);
  Positions[13].Init(-ARadius,  ARadius,  ARadius);
  Positions[14].Init( ARadius,  ARadius,  ARadius);
  Positions[15].Init( ARadius, -ARadius,  ARadius);
  Positions[16].Init(-ARadius, -ARadius, -ARadius);
  Positions[17].Init(-ARadius, -ARadius,  ARadius);
  Positions[18].Init(-ARadius,  ARadius,  ARadius);
  Positions[19].Init(-ARadius,  ARadius, -ARadius);
  Positions[20].Init( ARadius, -ARadius, -ARadius);
  Positions[21].Init( ARadius, -ARadius,  ARadius);
  Positions[22].Init( ARadius,  ARadius,  ARadius);
  Positions[23].Init( ARadius,  ARadius, -ARadius);

  Normals[ 0].Init( 0.0, -1.0,  0.0);
  Normals[ 1].Init( 0.0, -1.0,  0.0);
  Normals[ 2].Init( 0.0, -1.0,  0.0);
  Normals[ 3].Init( 0.0, -1.0,  0.0);
  Normals[ 4].Init( 0.0,  1.0,  0.0);
  Normals[ 5].Init( 0.0,  1.0,  0.0);
  Normals[ 6].Init( 0.0,  1.0,  0.0);
  Normals[ 7].Init( 0.0,  1.0,  0.0);
  Normals[ 8].Init( 0.0,  0.0, -1.0);
  Normals[ 9].Init( 0.0,  0.0, -1.0);
  Normals[10].Init( 0.0,  0.0, -1.0);
  Normals[11].Init( 0.0,  0.0, -1.0);
  Normals[12].Init( 0.0,  0.0,  1.0);
  Normals[13].Init( 0.0,  0.0,  1.0);
  Normals[14].Init( 0.0,  0.0,  1.0);
  Normals[15].Init( 0.0,  0.0,  1.0);
  Normals[16].Init(-1.0,  0.0,  0.0);
  Normals[17].Init(-1.0,  0.0,  0.0);
  Normals[18].Init(-1.0,  0.0,  0.0);
  Normals[19].Init(-1.0,  0.0,  0.0);
  Normals[20].Init( 1.0,  0.0,  0.0);
  Normals[21].Init( 1.0,  0.0,  0.0);
  Normals[22].Init( 1.0,  0.0,  0.0);
  Normals[23].Init( 1.0,  0.0,  0.0);

  Tangents[ 0].Init(-1.0,  0.0,  0.0);
  Tangents[ 1].Init(-1.0,  0.0,  0.0);
  Tangents[ 2].Init(-1.0,  0.0,  0.0);
  Tangents[ 3].Init(-1.0,  0.0,  0.0);
  Tangents[ 4].Init(-1.0,  0.0,  0.0);
  Tangents[ 5].Init(-1.0,  0.0,  0.0);
  Tangents[ 6].Init(-1.0,  0.0,  0.0);
  Tangents[ 7].Init(-1.0,  0.0,  0.0);
  Tangents[ 8].Init( 1.0,  0.0,  0.0);
  Tangents[ 9].Init( 1.0,  0.0,  0.0);
  Tangents[10].Init( 1.0,  0.0,  0.0);
  Tangents[11].Init( 1.0,  0.0,  0.0);
  Tangents[12].Init( 1.0,  0.0,  0.0);
  Tangents[13].Init( 1.0,  0.0,  0.0);
  Tangents[14].Init( 1.0,  0.0,  0.0);
  Tangents[15].Init( 1.0,  0.0,  0.0);
  Tangents[16].Init( 0.0, -1.0,  0.0);
  Tangents[17].Init( 0.0, -1.0,  0.0);
  Tangents[18].Init( 0.0, -1.0,  0.0);
  Tangents[19].Init( 0.0, -1.0,  0.0);
  Tangents[20].Init( 0.0,  1.0,  0.0);
  Tangents[21].Init( 0.0,  1.0,  0.0);
  Tangents[22].Init( 0.0,  1.0,  0.0);
  Tangents[23].Init( 0.0,  1.0,  0.0);

  TexCoords[ 0].Init(0.0, 0.0);
  TexCoords[ 1].Init(0.0, 1.0);
  TexCoords[ 2].Init(1.0, 1.0);
  TexCoords[ 3].Init(1.0, 0.0);
  TexCoords[ 4].Init(1.0, 0.0);
  TexCoords[ 5].Init(1.0, 1.0);
  TexCoords[ 6].Init(0.0, 1.0);
  TexCoords[ 7].Init(0.0, 0.0);
  TexCoords[ 8].Init(0.0, 0.0);
  TexCoords[ 9].Init(0.0, 1.0);
  TexCoords[10].Init(1.0, 1.0);
  TexCoords[11].Init(1.0, 0.0);
  TexCoords[12].Init(0.0, 0.0);
  TexCoords[13].Init(0.0, 1.0);
  TexCoords[14].Init(1.0, 1.0);
  TexCoords[15].Init(1.0, 0.0);
  TexCoords[16].Init(0.0, 0.0);
  TexCoords[17].Init(0.0, 1.0);
  TexCoords[18].Init(1.0, 1.0);
  TexCoords[19].Init(1.0, 0.0);
  TexCoords[20].Init(0.0, 0.0);
  TexCoords[21].Init(0.0, 1.0);
  TexCoords[22].Init(1.0, 1.0);
  TexCoords[23].Init(1.0, 0.0);

  Indices[0]  := 0;
  Indices[1]  := 2;
  Indices[2]  := 1;
  Indices[3]  := 0;
  Indices[4]  := 3;
  Indices[5]  := 2;
  Indices[6]  := 4;
  Indices[7]  := 5;
  Indices[8]  := 6;
  Indices[9]  := 4;
  Indices[10] := 6;
  Indices[11] := 7;
  Indices[12] := 8;
  Indices[13] := 9;
  Indices[14] := 10;
  Indices[15] := 8;
  Indices[16] := 10;
  Indices[17] := 11;
  Indices[18] := 12;
  Indices[19] := 15;
  Indices[20] := 14;
  Indices[21] := 12;
  Indices[22] := 14;
  Indices[23] := 13;
  Indices[24] := 16;
  Indices[25] := 17;
  Indices[26] := 18;
  Indices[27] := 16;
  Indices[28] := 18;
  Indices[29] := 19;
  Indices[30] := 20;
  Indices[31] := 23;
  Indices[32] := 22;
  Indices[33] := 20;
  Indices[34] := 22;
  Indices[35] := 21;
end;

{ TSphereGeometry }

procedure TSphereGeometry.Clear;
begin
  Positions := nil;
  Normals := nil;
  TexCoords := nil;
  { We keep Indices, since they may be used with Draw* }
end;

procedure TSphereGeometry.DrawWithBoundIndexBuffer;
begin
  gl.DrawElements(TGLPrimitiveType.Triangles, Length(Indices),
    TGLIndexType.UnsignedShort);
end;

procedure TSphereGeometry.DrawWithIndices;
begin
  gl.DrawElements(TGLPrimitiveType.Triangles, Indices);
end;

procedure TSphereGeometry.Generate(const ASliceCount: Integer;
  const ARadius: Single);
var
  I, J, K, ParallelCount, VertexCount, IndexCount, VertexIndex: Integer;
  AngleStep, SI, CI, SJ, CJ, UStep, VStep, ULat: Single;
  Direction: TVector3;
begin
  ParallelCount := ASliceCount div 2;
  VertexCount := (ParallelCount + 1) * (ASliceCount + 1);
  IndexCount := ParallelCount * ASliceCount * 6;
  AngleStep := (2 * Pi) / ASliceCount;
  UStep := 1 / ParallelCount;
  VStep := 1 / ASliceCount;

  SetLength(Positions, VertexCount);
  SetLength(Normals, VertexCount);
  SetLength(TexCoords, VertexCount);
  for I := 0 to ParallelCount do
  begin
    FastSinCos(AngleStep * I, SI, CI);
    ULat := 1 - (I * UStep);
    for J := 0 to ASliceCount do
    begin
      FastSinCos(AngleStep * J, SJ, CJ);
      Direction.Init(SI * SJ, CI, SI * CJ);

      VertexIndex := I * (ASliceCount + 1) + J;
      Positions[VertexIndex] := Direction * ARadius;
      Normals[VertexIndex] := Direction;
      TexCoords[VertexIndex].Init(J * VStep, ULat);
    end;
  end;

  SetLength(Indices, IndexCount);
  K := 0;
  for I := 0 to ParallelCount - 1 do
  begin
    for J := 0 to ASliceCount - 1 do
    begin
      Indices[K + 0] := (I + 0) * (ASliceCount + 1) + (J + 0);
      Indices[K + 1] := (I + 1) * (ASliceCount + 1) + (J + 0);
      Indices[K + 2] := (I + 1) * (ASliceCount + 1) + (J + 1);
      Indices[K + 3] := (I + 0) * (ASliceCount + 1) + (J + 0);
      Indices[K + 4] := (I + 1) * (ASliceCount + 1) + (J + 1);
      Indices[K + 5] := (I + 0) * (ASliceCount + 1) + (J + 1);
      Inc(K, 6);
    end;
  end;
end;

{ TTorusGeometry }

procedure TTorusGeometry.Clear;
begin
  Positions := nil;
  Normals := nil;
  TexCoords := nil;
  { We keep Indices, since they may be used with Draw* }
end;

procedure TTorusGeometry.DrawWithBoundIndexBuffer;
begin
  gl.DrawElements(TGLPrimitiveType.TriangleStrip, Length(Indices),
    TGLIndexType.UnsignedShort);
end;

procedure TTorusGeometry.DrawWithIndices;
begin
  gl.DrawElements(TGLPrimitiveType.TriangleStrip, Indices);
end;

procedure TTorusGeometry.Generate(const ASections, ARings: Integer;
  const AOuterRadius, AInnerRadius: Single);
var
  K, R, S, Count, Offs: Integer;
  RStep, SStep, R1, R2, VR, VX, VY, VZ, U, V: Single;
begin
  Count := (ARings + 1) * (ASections + 1);
  SetLength(Positions, Count);
  SetLength(Normals, Count);
  SetLength(TexCoords, Count);

  K := 0;
  RStep := (2 * Pi) / ARings;
  SStep := (2 * Pi) / ASections;
  R1 := AInnerRadius;
  R2 := AOuterRadius - AInnerRadius;

  for R := 0 to ARings do
  begin
    FastSinCos(R * RStep, VZ, VX);
    VZ := -VZ;

    for S := 0 to ASections do
    begin
      FastSinCos(S * SStep, VY, VR);

      Positions[K].Init(
        VX * (R1 + R2 * (1 + VR)),
        VY * R2,
        VZ * (R1 + R2 * (1 + VR)));

      Normals[K].Init(VX * VR, VY, VZ * VR);
      Inc(K);
    end;
  end;
  Assert(K = Count);

  K := 0;
  RStep := 1 / ARings;
  SStep := 1 / ASections;

  for R := 0 to ARings do
  begin
    U := R * RStep;

    for S := 0 to ASections do
    begin
      V := S * SStep;
      TexCoords[K].Init(U, V);
      Inc(K);
    end;
  end;
  Assert(K = Count);

  Count := ARings * (2 * (ASections + 1) + 2);
  SetLength(Indices, Count);
  K := 0;
  Offs := 0;
  for R := 0 to ARings - 1 do
  begin
    for S := 0 to ASections do
    begin
      Indices[K + 0] := Offs + S;
      Indices[K + 1] := Offs + S + (ASections + 1);
      Inc(K, 2);
    end;

    Inc(Offs, ASections + 1);
    Indices[K + 0] := Offs + ASections;
    Indices[K + 1] := Offs;
    Inc(K, 2);
  end;
  Assert(K = Count);
end;

{ TTwistedTorusGeometry }

procedure TTwistedTorusGeometry.Clear;
begin
  Positions := nil;
  Normals := nil;
  Tangents := nil;
  { We keep Indices, since they may be used with Draw* }
end;

procedure TTwistedTorusGeometry.Draw;
var
  I, First, Count: Integer;
begin
  First := 0;
  Count := StripSize;
  for I := 0 to StripCount  - 1 do
  begin
    gl.DrawArrays(TGLPrimitiveType.TriangleStrip, First, Count);
    Inc(First, Count);
  end;
end;

procedure TTwistedTorusGeometry.Generate(const ASections, ARings,
  ATwist: Integer; const AOuterRadius, AInnerRadius, AThickness: Single);
const
  S_SLIP_COEFF = 0.2;
var
  D, F, K, R, S, Count: Integer;
  T, RTwist, RStep, SStep, SSlip, R1, R2, FSign, FDT, SAngle, RAngle: Single;
  VX, VY, VZ, VR, TA, DSign: Single;
  SA: array [0..1] of Single;
begin
  StripSize := 2 * (ARings + 1);
  StripCount := ASections * 4;

  Count := 2 * 2 * 2 * ASections * (ARings + 1);
  SetLength(Positions, Count);
  SetLength(Normals, Count);

  T := AThickness / AInnerRadius;
  RTwist := ATwist / ARings;
  RStep := 2 * Pi / ARings;
  SStep := 2 * Pi / ASections;
  SSlip := SStep * S_SLIP_COEFF;
  R1 := AInnerRadius;
  R2 := AOuterRadius - AInnerRadius;

  K := 0;
  FSign := 1;
  for F := 0 to 1 do
  begin
    FDT := T * FSign * 0.95;

    for S := 0 to ASections - 1 do
    begin
      SAngle := (SStep * 0.5) + (S * SStep);
      SA[0] := SAngle + (SSlip * FSign);
      SA[1] := SAngle - (SSlip * FSign);

      for R := 0 to ARings do
      begin
        RAngle := R * RStep;
        FastSinCos(RAngle, VZ, VX);

        TA := SStep * R * RTwist;

        for D := 0 to 1 do
        begin
          FastSinCos(SA[D] + TA, VY, VR);

          Positions[K].Init(
            VX * (R1 + R2 * (1.0 + VR) + (FDT * VR)),
            VY * (R2 + FDT),
            VZ * (R1 + R2 * (1.0 + VR) + (FDT * VR)));

          Normals[K].Init(
            FSign * VX * VR,
            FSign * VY,
            FSign * VZ * VR);

          Inc(K);
        end;
      end;
    end;

    FSign := -1;
  end;

  DSign := 1;
  for D := 0 to 1 do
  begin
    for S := 0 to ASections - 1 do
    begin
      SAngle := (SStep * 0.5) + (S * SStep);
      SA[0] := SAngle + (SSlip * DSign);

      for R := 0 to ARings do
      begin
        RAngle := R * RStep;
        TA := SStep * R * RTwist;
        FastSinCos(SA[0] + TA, VY, VR);
        FastSinCos(RAngle, VZ, VX);

        FSign := 1;
        for F := 0 to 1 do
        begin
          FDT := -T * DSign * FSign * 0.95;

          Positions[K].Init(
            VX * (R1 + R2 * (1.0 + VR) + (FDT * VR)),
            VY * (R2 + FDT),
            VZ * (R1 + R2 * (1.0 + VR) + (FDT * VR)));

          Normals[K].Init(
            DSign * -VX * VR,
            DSign * VY,
            DSign * -VZ * VR);

          Inc(K);
          FSign := -1;
        end;
      end;
    end;

    DSign := -1;
  end;

  Assert(K = Count);

  GenerateTangents(ASections, ARings, ATwist);
end;

procedure TTwistedTorusGeometry.GenerateTangents(const ASections,
  ARings, ATwist: Integer);
var
  D, DOff, F, FOff, K, K0, K1, R, R0, R1, S, S0, S1, Count: Integer;
  TX, TY, TZ, TL: Single;
begin
  Count := 2 * 2 * 2 * ASections * (ARings + 1);
  SetLength(Tangents, Count);
  K := 0;

  for F := 0 to 1 do
  begin
    FOff := F * ASections * (ARings + 1) * 2;
    for S := 0 to ASections - 1 do
    begin
      S0 := S * (ARings + 1) * 2;
      for R := 0 to ARings do
      begin
        S1 := S0;
        R0 := R;
        R1 := R + 1;
        if (R = ARings) then
        begin
          S1 := ((S + ATwist) mod ASections) * (ARings + 1) * 2;
          R1 := 1;
        end;

        for D := 0 to 1 do
        begin
          K0 := FOff + S0 + (R0 * 2) + D;
          K1 := FOff + S1 + (R1 * 2) + D;

          TX := Positions[K1].X - Positions[K0].X;
          TY := Positions[K1].Y - Positions[K0].Y;
          TZ := Positions[K1].Z - Positions[K0].Z;
          TL := Sqrt((TX * TX) + (TY * TY) + (TZ * TZ));
          Assert(TL > 0);

          Tangents[K].Init(TX / TL, TY / TL, TZ / TL);
          Inc(K);
        end;
      end;
    end;
  end;

  for D := 0 to 1 do
  begin
    DOff := D * ASections * (ARings + 1) * 2;
    for S := 0 to ASections - 1 do
    begin
      S0 := S * (ARings + 1) * 2;
      for R := 0 to ARings do
      begin
        S1 := S0;
        R0 := R;
        R1 := R + 1;
        if (R = ARings) then
        begin
          S1 := ((S + ATwist) mod ASections) * (ARings + 1) * 2;
          R1 := 1;
        end;

        for F := 0 to 1 do
        begin
          K0 := DOff + S0 + (R0 * 2) + F;
          K1 := DOff + S1 + (R1 * 2) + F;

          TX := Positions[K1].X - Positions[K0].X;
          TY := Positions[K1].Y - Positions[K0].Y;
          TZ := Positions[K1].Z - Positions[K0].Z;
          TL := Sqrt((TX * TX) + (TY * TY) + (TZ * TZ));
          Assert(TL > 0);

          Tangents[K].Init(TX / TL, TY / TL, TZ / TL);
          Inc(K);
        end;
      end;
    end;
  end;

  Assert(K = Count);
end;

{ TSpiralSphereGeometry }

procedure TSpiralSphereGeometry.Clear;
begin
  Positions := nil;
  Normals := nil;
  { We keep Indices, since they may be used with Draw* }
end;

procedure TSpiralSphereGeometry.Draw;
var
  I, First, Count: Integer;
begin
  First := 0;
  Count := StripSize;
  for I := 0 to StripCount  - 1 do
  begin
    gl.DrawElements(TGLPrimitiveType.TriangleStrip, Indices, First, Count);
    Inc(First, Count);
  end;
end;

procedure TSpiralSphereGeometry.Generate(const ABands, ADivisions,
  ASegments: Integer; const ARadius, AThickness: Single);
var
  K, VertexCount: Integer;
begin
  StripSize := (ASegments + 1) * 2;
  StripCount := (2 * ABands * ADivisions) + (4 * ABands);
  VertexCount := ((ABands * 2) * (ADivisions + 1) * (ASegments + 1)) +
                 ((ABands * 2) * (ASegments + 1));
  SetLength(Positions, VertexCount);
  SetLength(Normals, VertexCount);

  K := 0;
  MakeVectors(Positions, K, 1.0, ARadius, ABands, ADivisions, ASegments);
  MakeVectors(Positions, K, 1.0, ARadius + AThickness, ABands, ADivisions, ASegments);
  MakeSideVerts(Positions, K, ABands, ASegments, ARadius, AThickness);

  Assert(K = VertexCount);

  K := 0;
  MakeVectors(Normals, K, -1.0, 1.0, ABands, ADivisions, ASegments);
  MakeVectors(Normals, K,  1.0, 1.0, ABands, ADivisions, ASegments);
  MakeSideVerts(Normals, K, ABands, ASegments, ARadius, AThickness);

  Assert(K = VertexCount);

  GenerateIndices(ABands, ADivisions, ASegments);
end;

procedure TSpiralSphereGeometry.GenerateIndices(const ABands, ADivisions,
  ASegments: Integer);
var
  B, D, K, M, N, S, EOffs, Offs, Edge, Edge1, Edge2, Band, Surface: Integer;  
begin
  M := ((ABands * 2) * (ADivisions * 2) * (ASegments + 1)) +
       ((ABands * 8) * (ASegments + 1));
  SetLength(Indices, M);

  K := 0;
  Offs := 0;
  Edge := ASegments + 1;
  Band := Edge * (ADivisions + 1);
  Surface := ABands * Band;

  Edge1 := 0;
  Edge2 := Edge;
  for N := 0 to 1 do
  begin
    for B := 0 to ABands - 1 do
    begin
      for D := 0 to ADivisions - 1 do
      begin
        for S := 0 to Edge - 1 do
        begin
          Indices[K + 0] := Offs + S + Edge1;
          Indices[K + 1] := Offs + S + Edge2;
          Inc(K, 2);
        end;
        Inc(Offs, Edge);
      end;
      Inc(Offs, Edge);
    end;
    Edge1 := Edge;
    Edge2 := 0;   
  end;

  Offs := 0;
  EOffs := 2 * Surface;

  for B := 0 to ABands - 1 do
  begin
    for S := 0 to Edge - 1 do
    begin
      Indices[K + 0] := Offs + S;
      Indices[K + 1] := EOffs + S;
      Inc(K, 2);   
    end;
    Inc(Offs, Band);
    Inc(EOffs, Edge * 2);
  end;

  Offs := ADivisions * Edge;
  EOffs := (2 * Surface) + Edge;

  for B := 0 to ABands - 1 do
  begin
    for S := 0 to Edge - 1 do
    begin
      Indices[K + 0] := Offs + S;
      Indices[K + 1] := EOffs + S;
      Inc(K, 2);   
    end;
    Inc(Offs, Band);
    Inc(EOffs, Edge * 2);
  end;

  Offs := Surface;
  EOffs := 2 * Surface;

  for B := 0 to ABands - 1 do
  begin
    for S := 0 to Edge - 1 do
    begin
      Indices[K + 0] := Offs + S;
      Indices[K + 1] := EOffs + S;
      Inc(K, 2);   
    end;
    Inc(Offs, Band);
    Inc(EOffs, Edge * 2);
  end;

  Offs := Surface + (ADivisions * Edge);
  EOffs := (2 * Surface) + Edge;

  for B := 0 to ABands - 1 do
  begin
    for S := 0 to Edge - 1 do
    begin
      Indices[K + 0] := EOffs + S;
      Indices[K + 1] := Offs + S;
      Inc(K, 2);   
    end;
    Inc(Offs, Band);
    Inc(EOffs, Edge * 2);
  end;

  Assert(K = M);
end;

class procedure TSpiralSphereGeometry.MakeSideVerts(var ADst: TArray<TVector3>;
  var AK: Integer; const ABands, ASegments: Integer; const ARadius,
  AThickness: Single);
var
  BLeap, BSlip, SStep, M, G, BOffs, BAngle, CB, SB, SAngle, CS, SS: Single;
  B, S: Integer;
begin
  BLeap := Pi / ABands;
  BSlip := BLeap * AThickness * 0.5;
  SStep := Pi / ASegments;

  M := ARadius + (AThickness * 0.5);
  G := -1;

  for B := 0 to (ABands * 2) - 1 do
  begin
    BOffs := 0;
    for S := 0 to ASegments do
    begin
      BAngle := (B * BLeap) + BOffs + (G * BSlip);
      FastSinCos(BAngle, SB, CB);

      SAngle := S * SStep;
      FastSinCos(SAngle, SS, CS);

      ADst[AK].Init(M * SS * CB, M * CS, M * SS * -SB);
      Inc(AK);

      BOffs := BOffs + (SS * SStep);
    end;
    G := G * -1;
  end;
end;

class procedure TSpiralSphereGeometry.MakeVectors(var ADst: TArray<TVector3>;
  var AK: Integer; const ASign, ARadius: Single; const ABands,
  ADivisions, ASegments: Integer);
var
  BLeap, BStep, SStep, M, BOffs, BAngle, CB, SB, SAngle, CS, SS: Single;
  B, D, S: Integer;
begin
  BLeap := Pi / ABands;
  BStep := BLeap / ADivisions;
  SStep := Pi / ASegments;

  M := ASign * ARadius;

  for B := 0 to ABands - 1 do
  begin
    for D := 0 to ADivisions do
    begin
      BOffs := 0;
      for S := 0 to ASegments do
      begin
        BAngle := (2 * B * BLeap) + (D * BStep) + BOffs;
        FastSinCos(BAngle, SB, CB);

        SAngle := S * SStep;
        FastSinCos(SAngle, SS, CS);

        ADst[AK].Init(M * SS * CB, M * CS, M * SS * -SB);
        Inc(AK);

        BOffs := BOffs + (SS * SStep);
      end;
    end;
  end;
end;

end.
