{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  StringGridEx
  Author: copyright (c) Sebastian Seidel
  Date:   30.09.2020

  Stringgrid kann sortiert werden
  Die Spalten können unterschiedlich gestrecht werden.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

unit StringGridEx;

interface

uses
  Winapi.Messages,System.SysUtils, System.Classes, System.UITypes, System.Types,
  Vcl.Controls, Vcl.Grids;

type
  TStretchType = (
    stNoStretching,                   //keine Zelle Strechen
    stStretchAllSame,                 //alle auf die gleiche länge stretchen
    stStretchLastCol                  //die letzte Col bis rand stretchen
    );

type
  TMoveSG = class(TCustomGrid);       // offenbart geschütztes MoveRow-Verfahren

type
  TStringGridEx = class( TStringGrid )
    procedure WMPaint( var Message: TWMPaint ); message WM_PAINT;
  private
    FAutosize : Boolean;
    FStretchType : TStretchType;
    FFixedFontStyles : TFontStyles;
    procedure AutoSizeGridColumn;
    procedure StretchLastCol;
    procedure StretchAllColAtSame;
    function StrCompare( ACol, Row1, Row2: Integer ): Integer;
    { Private-Deklarationen }
  protected
    { Protected-Deklarationen }
  public
    constructor Create( AOwner : TComponent ); override;

    procedure Sort( ACol : Integer );
    { Public-Deklarationen }
  published
    property Autosize : Boolean read FAutosize write FAutoSize;
    property FixedFontStyle : TFontStyles read FFixedFontStyles write FFixedFontStyles;
    property StretchType : TStretchType read FStretchType write FStretchType;
    { Published-Deklarationen }
  end;

procedure Register;

implementation

{------------------------------------------------------------------------------
Author: Seidel 2020-11-15
-------------------------------------------------------------------------------}
constructor TStringGridEx.Create( AOwner : TComponent );
begin
  inherited create( AOwner );
  FAutosize := false;
  FStretchType := stNoStretching;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-15
-------------------------------------------------------------------------------}
procedure TStringGridEx.WMPaint( var Message: TWMPaint );
begin
  inherited;
  if stStretchAllSame = StretchType then
    StretchAllColAtSame
  else
  begin
    if Autosize then
      AutoSizeGridColumn;

    if stStretchLastCol = StretchType then
      StretchLastCol;
  end;
end;
{------------------------------------------------------------------------------
Author: Seidel 2020-11-15
Hinweis: vergleicht den String Char basiert 100 < 15 (true)
-------------------------------------------------------------------------------}
function TStringGridEx.StrCompare( ACol, Row1, Row2: Integer ): Integer;
var
s1,
s2 : String;
begin
  s1 := Self.Cells[ ACol, Row1 ];
  s2 := Self.Cells[ ACol, Row2 ];
  //TODO: ungewöhnliches verhalten 100 < 15?! deshalb vorher prüfen ob es sich um ein
  //Wort String oder eine Zahl handelt
  Result := AnsiCompareStr( s1 , s2 );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-15
-------------------------------------------------------------------------------}
procedure TStringGridEx.Sort( ACol : Integer );
var
r: Integer;
sorted : Boolean;
begin
  repeat
    sorted := true;
    for r := 1 to ( Self.RowCount -2 ) do
    begin
      if StrCompare( ACol, r, r +1 ) > 0 then
      begin
        TMoveSG( Self ).MoveRow( r +1, r );
        sorted := false;
      end
    end;
  until sorted;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-15
-------------------------------------------------------------------------------}
procedure TStringGridEx.StretchAllColAtSame;
var
r,
c,
temp,
tempmax : integer;
begin
  tempmax := 0;
  for c := 0 to ( Self.ColCount - 1 ) do
  begin
    for r := 0 to ( Self.RowCount - 1 ) do
    begin
      temp := Self.Canvas.TextWidth( Self.cells[ c, r ] );
      if temp > tempmax then
        tempmax := temp;
    end;
  end;
  for c := 0 to ( Self.ColCount - 1 ) do
    Self.ColWidths[ c ] := tempmax + ( Self.GridLineWidth * 2 ) + 10;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-15
-------------------------------------------------------------------------------}
procedure TStringGridEx.AutoSizeGridColumn;
var
r: Integer;
temp: Integer;
tempmax: Integer;
c: Integer;
begin
  for c := 0 to ( Self.ColCount - 1 ) do
  begin
    tempmax := 0;

    if ( stStretchLastCol = StretchType ) and ( c = Self.ColCount - 1 ) then
      Continue;

    for r := 0 to ( Self.RowCount - 1 ) do
    begin
      temp := Self.Canvas.TextWidth( Self.cells[ c, r ] );
      if temp > tempmax then
        tempmax := temp;
    end;
    if Self.DefaultColWidth > tempmax then
      tempmax := Self.DefaultColWidth;
    Self.ColWidths[ c ] := tempmax + ( Self.GridLineWidth * 2 ) + 10;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-11-15
-------------------------------------------------------------------------------}
procedure TStringGridEx.StretchLastCol;
var
ActualGridSize,
c,
ExtraForLastCol : Integer;
begin
  ActualGridSize := 0;
  for c := 0 to ( Self.ColCount -1 ) do
  begin
    ActualGridSize := ActualGridSize + Self.ColWidths[ c ];
  end;
  if ActualGridSize < ( Self.Width - 10 ) then
  begin
    ExtraForLastCol := Self.Width - ActualGridSize - 10;
    Self.ColWidths[ Self.ColCount -1 ] := Self.ColWidths[ Self.ColCount -1 ] + ExtraForLastCol;
  end;
end;

procedure Register;
begin
  RegisterComponents('Basti_Komponenten', [TStringGridEx]);
end;

end.
