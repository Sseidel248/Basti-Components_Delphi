unit EditEx;

interface

uses
  Windows, SysUtils, Classes, Controls, StdCtrls, Messages, Graphics;

type
  TEditEx = class(TEdit)
  private
    Fh: TWMNCPAINT;
    Fdc: hDc;
    FPen: hPen;
    FOldPen: hPen;
    FOldBrush: hBrush;
    FColorMouseLeave,
    FColorSelect,
    FColorInfo,
    FColorMouseOver : TColor;
    FShowInfoColor : Boolean;
    procedure WMNCCalcSize(var Msg: TWMNCCALCSIZE); message WM_NCCALCSIZE;
    procedure WMNCPAINT(var Msg: TWMNCPaint); message WM_NCPAINT;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure SetShowInfoColor( const value : Boolean );
    procedure RedrawBorder;
  protected
    { Protected-Deklarationen }
  public
    procedure Repaint; override;
    constructor Create(AOwner: TComponent); override;
    property ShowInfoColor : Boolean read FShowInfoColor write SetShowInfoColor;
  published
    property BorderInfoColor : TColor read FColorInfo write FColorInfo;
    { Published-Deklarationen }
  end;

procedure Register;


implementation

procedure Register;
begin
  RegisterComponents('Basti_Komponenten', [TEditEx]);
end;

constructor TEditEx.Create(AOwner: TComponent);
begin
  inherited;
  ParentFont := True;
  FColorMouseLeave := clMedGray;
  FColorSelect := clHighlight;
  FColorInfo := clRed;
  FColorMouseOver := clBlack;
  FShowInfoColor := False;
end;

procedure TEditEx.Repaint;
begin
  WMNCPAINT(Fh);
end;

procedure TEditEx.WMNCCalcSize(var Msg: TWMNCCalcSize);
begin
  inherited;
  InflateRect(Msg.CalcSize_Params^.rgrc[0], -1, -1);
end;

procedure TEditEx.WMNCPAINT(var Msg: TWMNCPAINT);
begin
  inherited;
  RedrawBorder;
end;


procedure TEditEx.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    Repaint;
  end;
end;

procedure TEditEx.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    Repaint;
  end;
end;

procedure TEditEx.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if (GetActiveWindow <> 0) then
  begin
    Repaint;
  end;
end;

procedure TEditEx.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TEditEx.SetShowInfoColor( const value : Boolean );
begin
  FShowInfoColor := Value;
  Repaint;
end;

procedure TEditEx.RedrawBorder;

  procedure Draw( Color : TColor );
  begin
    Fdc := GetWindowDC(Handle);
    FPen := CreatePen(PS_SOLID, 2, ColorToRGB( Color ));
    FOldPen := SelectObject(Fdc, FPen);
    FOldBrush := SelectObject(Fdc, GetStockObject(NULL_BRUSH));
    Rectangle(Fdc, 0, 0, Width, Height);
    SelectObject(Fdc, FOldBrush);
    SelectObject(Fdc, FOldPen);
    DeleteObject(FPen);
    ReleaseDC(Handle, Handle);
  end;

begin
  if FShowInfoColor then
    Draw( FColorInfo )
end;


end.
