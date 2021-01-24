{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  DBEditEx
  Author: copyright (c) Sebastian Seidel
  Date:   08.10.2020

  Änderung des Rahmen möglich (Allgemein und Focused)
  Zeigt einen Texthint
  ->  einstellbar, ob der Texthint verschwinden soll oder nicht wenn etwas
      geschrieben wurde
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

unit DBEditEx;

interface

uses
  Windows, SysUtils, Classes, Controls, DBCtrls, Messages, Graphics;

type
  TDBEditEx = class(TDBEdit)
  private
    Fh: TWMNCPAINT;
    FColorMouseLeave,
    FColorMouseOver : TColor;
    FBorderColor : TColor;
    FFocusBorderColor : TColor;
    FFocusBoder : Boolean;
    FTextHintOnFocus : Boolean;
    FTextHint : String;
    procedure WMNCCalcSize(var Msg: TWMNCCALCSIZE); message WM_NCCALCSIZE;
    procedure WMNCPAINT(var Msg: TWMNCPaint); message WM_NCPAINT;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure SetBorderColor( const Value : TColor );
    procedure SetFocusBorderColor( const Value : TColor );
    procedure SetTextHint( const value : string );
    procedure DrawBorder;
    procedure DrawBorderControl( DC : HDC );
  protected
    procedure DoSetTextHint( const value : String ); override;
    { Protected-Deklarationen }
  public
    procedure Repaint; override;
    constructor Create(AOwner: TComponent); override;
  published
    property Bordercolor : TColor read FBorderColor write SetBorderColor;
    property FocusBoderColor : TColor read FFocusBorderColor write SetFocusBorderColor;
    property TextHintOnFocus : Boolean read FTextHintOnFocus write FTextHintOnFocus;
    property TextHint : String read FTextHint write SetTextHint;
    { Published-Deklarationen }
  end;

procedure Register;


implementation

procedure Register;
begin
  RegisterComponents('Basti_Komponenten', [TDBEditEx]);
end;

constructor TDBEditEx.Create(AOwner: TComponent);
begin
  inherited;
  ParentFont := True;
  FColorMouseLeave := clMedGray;
  FColorMouseOver := clBlack;
  FBorderColor := clNone;
  FFocusBorderColor := clNone;
end;

procedure TDBEditEx.SetTextHint( const value : String );
begin
    if FTextHint <> Value then
  begin
    FTextHint := Value;
    if not ( csLoading in ComponentState ) then
      DoSetTextHint( FTextHint );
  end;
end;

procedure TDBEditEx.DoSetTextHint( const value : String );
const
  EM_SETCUEBANNER = $1501;
var
  wParam: Integer;
begin
  case FTextHintOnFocus of
    true: wParam := 1;
  else
    wParam := 0;
  end;
  SendMessage( self.Handle, EM_SETCUEBANNER, wParam, Integer( PWideChar( value ) ) );
end;

procedure TDBEditEx.Repaint;
begin
  WMNCPAINT(Fh);
end;

procedure TDBEditEx.WMNCCalcSize(var Msg: TWMNCCalcSize);
begin
  inherited;
  InflateRect(Msg.CalcSize_Params^.rgrc[0], -1, -1);
end;

procedure TDBEditEx.WMNCPAINT(var Msg: TWMNCPAINT);
begin
  inherited;
  DrawBorder;
end;


procedure TDBEditEx.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    FFocusBoder := true;
    Repaint;
  end;
end;

procedure TDBEditEx.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    FFocusBoder := false;
    Repaint;
  end;
end;

procedure TDBEditEx.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if (GetActiveWindow <> 0) then
  begin
    FFocusBoder := true;
    Repaint;
  end;
end;

procedure TDBEditEx.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FFocusBoder := false;
  Repaint;
end;

procedure TDBEditEx.SetBorderColor( const Value : TColor );
begin
   if (FBorderColor <> Value) then
  begin
    if not (csDesigning in ComponentState) then
    begin
      FBorderColor := Value;
      SendMessage(Self.Handle, WM_NCPAINT, 0,0);
    end;
  end;
end;

procedure TDBEditEx.SetFocusBorderColor( const Value : TColor );
begin
  if (FFocusBorderColor <> Value) then
  begin
    FFocusBorderColor := Value;
    SendMessage(Self.Handle, WM_NCPAINT, 0,0);
  end;
end;

procedure TDBEditEx.DrawBorder;
  var
  DC: HDC;
begin
  DC := GetWindowDC( Self.Handle );
  try
    DrawBorderControl( DC );
    DoSetTextHint( FTextHint );
  finally
    ReleaseDC( Self.Handle, DC );
  end;
end;

procedure TDBEditEx.DrawBorderControl( DC : HDC );
var
  ARect: TRect;
  BtnFaceBrush: HBRUSH;
  color: TColor;
  HasFocus: boolean;
begin
  if (BorderColor = clNone) and (csDesigning in ComponentState) then
    Exit;

  color := clNone;
  //var := ( Wert = AndererWert ) Boolische Abfrage
  HasFocus := GetFocus = Self.Handle;

  if not Enabled then
    color := clSilver
  else
  begin
    if (FBorderColor <> clNone) and (not HasFocus) then
      color := FBorderColor
    else
    if (FFocusBorderColor <> clNone) and ( HasFocus ) then
      color := FFocusBorderColor;
  end;

  if color <> clNone then
  begin
    BtnFaceBrush := CreateSolidBrush(ColorToRGB(color));
    try
      GetWindowRect(Handle, ARect);
      OffsetRect(ARect, -ARect.Left, -ARect.Top);
      FrameRect(DC, ARect, BtnFaceBrush);
    finally
      DeleteObject(BtnFaceBrush);
    end;
    Exit;
  end;

  if FFocusBoder then
    BtnFaceBrush := CreateSolidBrush(ColorToRGB( FColorMouseOver ))
  else
    BtnFaceBrush := CreateSolidBrush(ColorToRGB( FColorMouseLeave ));

  try
    GetWindowRect(Handle, ARect);
    OffsetRect(ARect, -ARect.Left, -ARect.Top);
    FrameRect(DC, ARect, BtnFaceBrush);
  finally
    DeleteObject(BtnFaceBrush);
  end;
end;

end.
