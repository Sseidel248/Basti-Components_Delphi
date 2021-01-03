unit GradientPanel;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  GradientPanel
  Author: Sebastian Seidel
  Date:   30.09.2020

  Ermöglicht einen Farbverlauf innerhalb eines Panels
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
interface

uses
  WinApi.Windows,
  WinApi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  vcl.Graphics,
  Math;

type
  TColorGradient = (
  cgVertical,              // = vertikaler Farbverlauf
  cgHorizontal             // = horizontaler Fabrverlauf
  );

type
  TRGBGradient = (
  rgbLinear,               // = lineares Mischen der Zwischenfarben
  rgbNonLinear             // = Nicht lineares Mischen der Zwischenfarben
  );

type
//  TAfterPaint = procedure( Sender : TObject; var RefreshAllChildren : Boolean ) of object;

  TGradientPanel = class(TPanel)
  private
    FColorGradient : TColorGradient;
    FRGBGradient : TRGBGradient;
    FColor : TColor;
    FColorTo : TColor;
    FR : Byte;
    FG : Byte;
    FB : Byte;
    FRTo : Byte;
    FGTo : Byte;
    FBTo : Byte;
//    FOnBeforePaint: TNotifyEvent;
//    FOnAfterPaint: TAfterPaint;
    procedure SetColorToRGB( ColorFrom: TColor );
    procedure SetColorToToRGB( ColorTo: TColor );
    procedure SetRGBWithGradient( var R, G, B: Byte; x : Double );
    function GetLinearRGBValue( RGBValueTo, RGBValueFrom : Byte; x : Double ) : Byte;
    function GetNonLinearRGBValue( RGBValueTo, RGBValueFrom : Byte; x : Double ) : Byte;
    procedure DrawPanelH( Rect : TRect );
    procedure DrawPanelV( Rect : TRect );
    procedure RefreshAllChildren;
    { Private-Deklarationen }
  protected
    procedure Paint; override;
    procedure ChangeColorGradient( AColorGradient : TColorGradient ); overload;
    procedure ChangeColorGradient( ARGBGradient : TRGBGradient ); overload;
    { Protected-Deklarationen }
  public
    constructor Create( AOwner : TComponent ); override;
    procedure Invalidate; override;
    { Public-Deklarationen }
  published
    property ColorGradient : TColorGradient read FColorGradient write ChangeColorGradient;
    property RGB_Gradient : TRGBGradient read FRGBGradient write ChangeColorGradient;
    property Color : TColor read FColor write SetColorToRGB;
    property ColorTo : TColor read FColorTo write SetColorToToRGB;
//    property OnBeforePaint: TNotifyEvent read FOnBeforePaint write FOnBeforePaint;
//    property OnAfterPaint: TAfterPaint read FOnAfterPaint write FOnAfterPaint;
    { Published-Deklarationen }
  end;

procedure Register;

implementation

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
constructor TGradientPanel.Create( AOwner : TComponent );
begin
  Inherited Create( AOwner );
  FColorGradient := cgVertical;
  FRGBGradient := rgbLinear;
  FColor := clBlue;
  FColorTo := clGreen;
  DoubleBuffered := true; // flackern beim Zeichnen vermeiden
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-29
-------------------------------------------------------------------------------}
procedure TGradientPanel.Invalidate;
begin
  inherited;
  RefreshAllChildren;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
procedure TGradientPanel.SetColorToRGB( ColorFrom: TColor );
var
RGB : Cardinal;
begin
  FColor := ColorFrom;
  RGB     := ColorToRGB( FColor );
  FR  := GetRValue( RGB );
  FG  := GetGValue( RGB );
  FB  := GetBValue( RGB );
  Invalidate;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
procedure TGradientPanel.SetColorToToRGB( ColorTo: TColor );
var
RGB : Cardinal;
begin
  FColorTo := ColorTo;
  RGB     := ColorToRGB( FColorTo );
  FRTo    := GetRValue( RGB );
  FGTo    := GetGValue( RGB );
  FBTo    := GetBValue( RGB );
  Invalidate;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
procedure TGradientPanel.SetRGBWithGradient( var R, G, B: Byte; x : Double );
begin
  if rgbLinear = FRGBGradient then
  begin
    R := GetLinearRGBValue( FRTo, FR, x );
    G := GetLinearRGBValue( FGTo, FG, x );
    B := GetLinearRGBValue( FBTo, FB, x );
  end
  else
  if rgbNonLinear = FRGBGradient then
  begin
    R := GetNonLinearRGBValue( FRTo, FR, x );
    G := GetNonLinearRGBValue( FGTo, FG, x );
    B := GetNonLinearRGBValue( FBTo, FB, x );
  end;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
function TGradientPanel.GetLinearRGBValue( RGBValueTo, RGBValueFrom : Byte; x : Double ) : Byte;
begin
  Result := Trunc( x * RGBValueTo + ( 1 - x ) * RGBValueFrom );
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30

  Da das lineare Mischen von zwei Farben zum Teil zu unerwarteten Ergebnissen
-----------------------------------------------------------------------------}
function TGradientPanel.GetNonLinearRGBValue( RGBValueTo, RGBValueFrom : Byte; x : Double ) : Byte;
begin
  Result := Trunc( sqrt( x * Power( RGBValueTo, 2 ) + ( 1 - x ) * Power( RGBValueFrom, 2 ) ) );
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30

Rect.top    = 0
Rect.Left   = 0
Rect.right  = Breite von Links vom Panel
Rect.Bottom = Höhe von Oben vom Pane
-----------------------------------------------------------------------------}
procedure TGradientPanel.DrawPanelV ( Rect : TRect );
var
i : Integer;
x : double;
RDraw, GDraw, BDraw : Byte;
begin
  for i := ( Rect.Left - 1 )  to ( Rect.Right - 1 ) do
  begin
    x := ( i / Rect.Right ); //Porzentualer Anteil wo sich der Stift befindet
    SetRGBWithGradient( RDraw, GDraw, BDraw, x );
    Canvas.Pen.Color := RGB( RDraw, GDraw, BDraw );
    Canvas.MoveTo ( i, 0 );
    Canvas.LineTo ( i, Height );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-12-29
-------------------------------------------------------------------------------}
procedure TGradientPanel.RefreshAllChildren;
var
  I: Integer;
begin
  for I := 0 to Self.ControlCount-1 do
  begin
    Self.Controls[i].Refresh;
  end;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
procedure TGradientPanel.DrawPanelH ( Rect : TRect );
var
i : Integer;
x : double;
RDraw, GDraw, BDraw : Byte;
begin
  for i := ( Rect.Top - 1 ) to ( Rect.Bottom - 1 ) do
  begin
    x := ( i / Rect.Bottom  );
    SetRGBWithGradient( RDraw, GDraw, BDraw, x );
    Canvas.Pen.Color := RGB( RDraw, GDraw, BDraw );
    Canvas.MoveTo ( 0, i );
    Canvas.LineTo ( width, i );
  end;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
procedure TGradientPanel.ChangeColorGradient( AColorGradient : TColorGradient );
begin
  FColorGradient := AColorGradient;
  Invalidate;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
procedure TGradientPanel.ChangeColorGradient( ARGBGradient : TRGBGradient );
begin
  FRGBGradient := ARGBGradient;
  Invalidate;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
procedure TGradientPanel.Paint;
var
Rect : TRect;
//RefreshAllCh : Boolean;
begin
//  RefreshAllCh := false;
//
//  if Assigned(FOnBeforePaint) then
//    FOnBeforePaint(Self);

  inherited;

  Rect := ClientRect;
  AdjustClientRect ( Rect );

  if cgVertical = FColorGradient then
  begin
    DrawPanelV( rect );
  end
  else if cgHorizontal = FColorGradient then
  begin
    DrawPanelH( rect );
  end;

//  if Assigned(FOnAfterPaint) then
//  begin
//    FOnAfterPaint( Self, RefreshAllCh );
//    if RefreshAllCh then
//  RefreshAllChildren;
//  end;
end;

{-----------------------------------------------------------------------------
  Author: Seidel 2020-09-30
-----------------------------------------------------------------------------}
procedure Register;
begin
  RegisterComponents( 'Basti_Komponenten', [TGradientPanel] );
end;

end.
