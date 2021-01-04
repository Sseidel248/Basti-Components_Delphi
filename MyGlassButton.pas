unit MyGlassButton;

interface

uses
  WinApi.Windows,
  WinApi.Messages,
  System.SysUtils,
  vcl.StdCtrls,
  System.Classes,
  vcl.Controls,
  vcl.ExtCtrls,
  vcl.Graphics,
  vcl.Themes,
  vcl.Forms,
//  Winapi.Commctrl,
  vcl.ImgList;

{
procedure CNCtlColorBtn(var Message: TWMCtlColorBtn); message CN_CTLCOLORBTN;

procedure TCustomButton.CNCtlColorBtn(var Message: TWMCtlColorBtn);
begin
  with StyleServices do
    if Enabled then
    begin
      if (Parent <> nil) and Parent.DoubleBuffered then
        PerformEraseBackground(Self, Message.ChildDC)
      else
        DrawParentBackground(Handle, Message.ChildDC, nil, False);
      // Return an empty brush to prevent Windows from overpainting we just have created.
      Message.Result := GetStockObject(NULL_BRUSH);
    end
    else
      inherited;
end;
}
{
procedure TCustomForm.WMDpiChanged(var Message: TWMDpi);
var
  OldPPI: Integer;
begin
  if not (csDesigning in ComponentState) then
  begin
    if (Message.YDpi = 0) or not Scaled then
    begin
      if (Application.MainForm <> nil) and (Application.MainForm.Scaled) then
        FCurrentPpi := Application.MainForm.PixelsPerInch
      else
        Exit;
    end;

    if (Message.YDpi <> FCurrentPpi) and Scaled then
    begin
      if Assigned(FOnBeforeMonitorDpiChanged) then
        FOnBeforeMonitorDpiChanged(Self, FCurrentPPI, Message.YDpi);
      OldPPI := FCurrentPPI;
      ScaleForPPIRect(Message.YDpi, Message.ScaledRect);
      FCurrentPPI := Message.YDpi;
      if Assigned(FOnAfterMonitorDpiChanged) then
        FOnAfterMonitorDpiChanged(Self, OldPPI, FCurrentPPI);
    end;
    Message.Result := 0;
  end;
end;

}

//TODO: Skalierung einbauen

type
  TParentColortype = (
  pcSingle,              // = Hintergrundfrabe des Parent ist einfarbig
  pcMulti                // = Hintergrundfarbe des Parent ist mehrfarbig, z.b. Farbverlauf
  );

type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;
  PLine24 = ^TLine24;
  TLine24 = array[0..0] of TRGB24;
  PRGBArray = ^TRGBArray;
  TRGBArray = array[0..0] of TRGB24;

  TGlassButton = class(TCustomControl)
  private
    GlyphX, GlyphY: Integer;
    TextX, TextY: Integer;
    FBmp: TBitmap;
    FBtnIdx: Integer;
    FButtonDown: Boolean;
    FCaption: string;
    FColorMouseOver: TColor;
    FColorPressed: TColor;
    FColorFrame: TColor;
    FFont: TFont;
    FImages: TCustomImageList;
    FImageIndex: Integer;
    FDisableImageIndex: Integer;
    FImageAlignment: TImageAlignment;
    FParentColortype: TParentColortype;
    FPopup: Boolean;
//    FParentColor : TColor;
//    FParentWindowHandle: HWND;
    FOnPopup: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    procedure InitPos;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMPaint( var Message: TWMPaint ); message WM_PAINT;
    procedure WMERASEBKGND(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
//    procedure WMDpiChanged(var Message: TWMDpi); message WM_DPICHANGED;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure PaintButton;
    procedure SetColor(const Value: TColor);
    procedure SetFrameColor(const Value: TColor);
    procedure SetColorDown(const Value: TColor);
    procedure SetFont(const Value: TFont);//BUG - Änderungen zur Laufzeit werden nicht gleich gemalt
    procedure SetCaption(const Value: string);
    procedure SetImgIdx(const Value: Integer);
    procedure SetDisableImgIdx(const Value: Integer);
    procedure SetImageAlignment(const Value: TImageAlignment);
    procedure SetParentColortype(const Value: TParentColortype);
    procedure PaintAlphaTxt(ShowDown: Boolean);
    procedure PaintAlphaRect(ABitmap: TBitmap; ARect: TRect; AColor: TColor; Alpha: Byte=50);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure PaintWindow(DC: HDC); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
  published
    property Align;
    property Anchors;
//    property AutoSize; //Bug Button verschwindet!
    property ParentColortype : TParentColortype read FParentColortype write SetParentColortype;
    property Caption: string read FCaption write SetCaption;
    property ColorMouseOver: TColor read FColorMouseOver write SetColor default $00F4F4F4;
    property ColorPressed: TColor read FColorPressed write SetColorDown default clGray;
    property ColorFrame: TColor read FColorFrame write SetFrameColor default clSilver;
    property ImageIdx: Integer read FImageIndex write SetImgIdx default -1;
    property DisableImageIdx: Integer read FDisableImageIndex write SetDisableImgIdx default -1;
    property Enabled;
    property Font: TFont read FFOnt write SetFont;
    property Images: TCustomImageList read FImages write FImages;
    property ImageAlignment: TImageAlignment read FImageAlignment write SetImageAlignment default iaLeft;
    property Left;
    property Top;
    property Width;
    property Height;
    property ShowHint;
    property TabOrder;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnPopup: TNotifyEvent read FOnPopup write FOnPopup;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnKeyDown;
    property OnKeyUp;
    property OnResize;
  end;

procedure Register;

implementation

procedure DrawParentImage(Control: TControl; Dest: TCanvas; ParentColorType : TParentColortype);
var
  SaveIndex: Integer;
  DC: HDC;
  Position: TPoint;
begin
  with Control do
  begin
    if Parent = nil then
      Exit;
    DC := Dest.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, Position);
    SetViewportOrgEx(DC, Position.X - Left, Position.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);

    if pcSingle = ParentColorType then
    begin
      Parent.Perform(WM_ERASEBKGND, DC, 0);
      Parent.Perform(WM_PAINT, DC, 0);
    end
    else
    if pcMulti = ParentColorType then
    begin
      Parent.Perform(WM_PAINT, DC, 0);
    end;

    RestoreDC(DC, SaveIndex);
  end;
end;


function Blend(Color1, Color2: TColor; A: Byte): TColor;  inline;
var
  c1, c2: LongInt;
  r, g, b, v1, v2: byte;
begin
  A := Round(2.55 * A);
  c1 := ColorToRGB(Color1);
  c2 := ColorToRGB(Color2);
  v1 := Byte(c1);
  v2 := Byte(c2);
  r := Byte(A * (v1 - v2) shr 8 + v2);
  v1 := Byte(c1 shr 8);
  v2 := Byte(c2 shr 8);
  g := Byte(A * (v1 - v2) shr 8 + v2);
  v1 := Byte(c1 shr 16);
  v2 := Byte(c2 shr 16);
  b := Byte(A * (v1 - v2) shr 8 + v2);
  Result := (b shl 16) + (g shl 8) + r;
end;

procedure TGlassButton.PaintWindow(DC: HDC);
begin
  Canvas.Lock;
  try
    Canvas.Handle := DC;
    try
      FBmp.Canvas.Font.Assign(FFont);
      PaintButton;
    finally
      Canvas.Handle := 0;
    end;
  finally
    Canvas.Unlock;
  end;
end;

procedure TGlassButton.PaintAlphaTxt(ShowDown: Boolean);
var
  row, slSize, x, y, i: Integer;
  rowSrc, slSizeSrc: Integer;
  slPnt, slPntSrc: PRGB24;
  Bmp, BmpAlpha: TBitmap;
  DC: HDC;
  Glyph: Boolean;
begin
  Glyph:= (FImageIndex <> -1) and (Assigned(FImages));
  BmpAlpha:= TBitmap.Create;
  try
    BmpAlpha.PixelFormat:= pf24bit;
    BmpAlpha.Width:= FBmp.Width - 2;
    BmpAlpha.Height:= FBmp.Height - 2;
    BmpAlpha.Canvas.Brush.Color:= clWhite;
    BmpAlpha.Canvas.FillRect(BmpAlpha.Canvas.ClipRect);

    //Change: Seidel 2021-01-04
    //Font vom Canvas Skalieren; FScaleFactor kommt aus vcl.Controls
    if FScaleFactor <> 1 then
    begin
      FBmp.Canvas.Font.Size := Round( FBmp.Canvas.Font.Size * FScaleFactor )
    end;

    //entsprechende Bilder holen
    if Glyph then
    begin
      Bmp := TBitmap.Create;
      try
        Bmp.Monochrome := True;

        if Self.Enabled then
          FImages.GetBitmap(FImageIndex, bmp)
        else
        begin
          if FDisableImageIndex = -1 then
            FImages.GetBitmap(FImageIndex, bmp)
          else
            FImages.GetBitmap(FDisableImageIndex, bmp);
        end;

        BmpAlpha.Canvas.Brush.Color := clBlack;
        DC := BmpAlpha.Canvas.Handle;
        SetTextColor(DC, clBlack);
        SetBkColor(DC, clWhite);
        BitBlt(DC, GlyphX, GlyphY , Bmp.Width, Bmp.Height,
          Bmp.Canvas.Handle, 0, 0, SRCAND );
      finally
        Bmp.Free;
      end;
    end;

    if ShowDown then
      i:= 1
    else
      i:= 0;
    row:= Integer(FBmp.Scanline[i]);
    slSize:= Integer(FBmp.Scanline[i + 1]) - row;
    rowSrc:= Integer(BmpAlpha.Scanline[0]);
    slSizeSrc:= Integer(BmpAlpha.Scanline[1]) - rowSrc;
    row:= row  + (i * 3);
    for y := 0 to BmpAlpha.Height - 1 do
    begin
      slPnt := pRGB24(row);
      slPntSrc := pRGB24(rowSrc);
      for x := 0 to BmpAlpha.Width - 1 do
      begin
        slPnt.r := Byte(slPntSrc.R * (slPnt.R - 0) shr 8 + 0);
        slPnt.g := Byte(slPntSrc.R * (slPnt.G - 0) shr 8 + 0);
        slPnt.b := Byte(slPntSrc.R * (slPnt.B - 0) shr 8 + 0);
        inc(slPnt);
        Inc(slPntSrc);
      end;
      inc(row, slSize);
      inc(rowSrc, slSizeSrc);
    end;
    //malen der Bilder
    if Glyph then
    begin
      if Self.Enabled then
        FImages.Draw(FBmp.Canvas, GlyphX + i, GlyphY + i, FImageIndex)
      else
      begin
        if FDisableImageIndex = -1 then
          FImages.Draw(FBmp.Canvas, GlyphX + i, GlyphY + i, FImageIndex)
        else
          FImages.Draw(FBmp.Canvas, GlyphX + i, GlyphY + i, FDisableImageIndex);
      end;
//      FImages.Draw(FBmp.Canvas, GlyphX + i, GlyphY + i, FImageIndex);//Change: Seidel 2020-12-28
      FBmp.Canvas.TextOut(TextX + i, TextY + i, FCaption)
    end
    else
      FBmp.Canvas.TextOut(TextX + i, TextY + i, FCaption);
  finally
    BmpAlpha.Free;
  end;
end;

procedure TGlassButton.PaintAlphaRect(ABitmap: TBitmap; ARect: TRect; AColor: TColor; Alpha: Byte = 50);
var
  C: LongInt;
  i, row, slSize, x, y: Integer;
  Ra, Ga, Ba: array[0..255] of Byte;
  Col: TRGB24;
  slPnt: PRGB24;
  h: Integer;
begin
  C:= ColorToRGB(AColor);
  Col.B := (C shr 16) and $FF;
  Col.G := (C shr 8) and $FF;
  Col.R := C and $FF;
  for i := 0 to 255 do
  begin
    Ra[i] := Byte(Alpha * (Col.R - i) shr 8 + i);
    Ga[i] := Byte(Alpha * (Col.G - i) shr 8 + i);
    Ba[i] := Byte(Alpha * (Col.B - i) shr 8 + i);
  end;
  row:= Integer(ABitmap.Scanline[ARect.Top]);
  slSize:= Integer(ABitmap.Scanline[ARect.Top + 1]) - row;
  row:= row  + (ARect.Left * 3);
  h:= 0;
  for y := h to ARect.Bottom - 1 do
  begin
    slPnt := pRGB24(row);
    for x := ARect.Left to ARect.Right - 1 do
    begin
      slPnt.R := Ra[slPnt.R];
      slPnt.G := Ga[slPnt.G];
      slPnt.B := Ba[slPnt.B];
      inc(slPnt)
    end;
    inc(row, slSize);
  end;
end;

procedure TGlassButton.PaintButton;
//const
//  TxtOp: Integer = DT_END_ELLIPSIS or DT_SINGLELINE or DT_NOPREFIX or
//  DT_VCENTER;
var
  r: TRect;
  c1: TColor;
begin
  InitPos;
  FBmp.Width := ClientWidth;
  FBmp.Height := ClientHeight;
  FBmp.Canvas.Brush.Style := bsClear;
  DrawParentImage(self, FBmp.Canvas, FParentColortype);
  if (FBtnIdx <> -1) or (csDesigning in ComponentState) then
  begin
    //Zeichnen den Button, dass gedrückt wird entsprechend ColorMouseOver oder ColorPressed
    r:= ClientRect;
    InflateRect(r, -1, -1);
    //wenn es sich nicht im DesignTime Modus befindet
    if not (csDesigning in ComponentState) then
      if FButtonDown then
        PaintAlphaRect(FBmp, r, ColorPressed)
      else
        PaintAlphaRect(FBmp, r, ColorMouseOver);

    //Zeichnet den Rand entsprechend ColorFrame
    r:= ClientRect;
//    c1:= Blend(FBmp.Canvas.Pixels[r.Left, r.Bottom - 1], FBmp.Canvas.Pixels[r.Left, r.Top], 50);
//    c2:= Blend(FBmp.Canvas.Pixels[r.Left, r.Top], FBmp.Canvas.Pixels[r.Right - 1, r.Top], 50);
//    c3:= Blend(FBmp.Canvas.Pixels[r.Right - 1, r.Top], FBmp.Canvas.Pixels[r.Right -1, r. Bottom - 1], 50);
//    c4:= Blend(FBmp.Canvas.Pixels[r.Left, r.Bottom - 1], FBmp.Canvas.Pixels[r.Right -1, r.Bottom -1], 50);
//    c1:= Blend(c1, c2, 50);
//    c2:= Blend(c3, c4, 50);
//    c1:= Blend(c1, c2, 50);
//    c1:= Blend(c1, FColorFrame, 50);
    c1:= FColorFrame;
    FBmp.Canvas.Pen.Color:=  c1;
    FBmp.Canvas.Polyline([Point(r.Left, r.Top + 2), Point(r.Left + 2, r.Top),
      Point(r.Left + 2, r.Top), Point(r.Right - 3, r.Top), Point(r.Right - 1, r.Top + 2),
      Point(r.Right - 1, r.Bottom - 3), Point(r.Right - 3, r.Bottom - 1), Point(r.Left + 2, r.Bottom - 1),
      Point(r.Left, r.Bottom - 3), Point(r.Left, r.Top + 2)]);
//    FBmp.Canvas.Pixels[r.Left, R. Top + 1] := Blend(FBmp.Canvas.Pixels[r.Left, R. Top + 1], c1, 50);
//    FBmp.Canvas.Pixels[r.Left + 1, R. Top] := Blend(FBmp.Canvas.Pixels[r.Left + 1, R. Top], c1, 50);
//    FBmp.Canvas.Pixels[r.Right - 1, R. Top + 1] := Blend(FBmp.Canvas.Pixels[r.Right -1, R. Top + 1], c1, 50);
//    FBmp.Canvas.Pixels[r.Right - 2, R. Top] := Blend(FBmp.Canvas.Pixels[r.Right - 2, R. Top], c1, 50);
//    FBmp.Canvas.Pixels[r.Left, R. Bottom - 2] := Blend(FBmp.Canvas.Pixels[r.Left, R. Bottom - 2], c1, 50);
//    FBmp.Canvas.Pixels[r.Left + 1, R. Bottom - 1] := Blend(FBmp.Canvas.Pixels[r.Left + 1, R. Bottom -1], c1, 50);
//    FBmp.Canvas.Pixels[r.Right - 1, R. Bottom - 2] := Blend(FBmp.Canvas.Pixels[r.Right -1, R. Bottom - 2], c1, 50);
//    FBmp.Canvas.Pixels[r.Right - 2, R. Bottom - 1] := Blend(FBmp.Canvas.Pixels[r.Right - 2, R. Bottom - 1], c1, 50);

    //wenn der Button gedrückt wurde, wird ein 3D effekt erzeugt (eindrücken des Button in den Oberfläche)
    if FButtonDown then
    begin
      r:= ClientRect;
      FBmp.Canvas.Pen.Color:= Blend(c1, clBlack, 50);
      FBmp.Canvas.Polyline([Point(r.Left + 1, r.Bottom - 3), Point(r.Left + 1, r.Top + 2),
        Point(r.Left + 2, r.Top + 1), Point(r.Right - 2, r.Top + 1)]);
      FBmp.Canvas.Pen.Color:= Blend(c1, clWhite, 50);
      FBmp.Canvas.Polyline([Point(r.Right - 2, r.Top + 2), Point(r.Right - 2, r.Bottom - 3),
        Point(r.Right - 3, r.Bottom - 2), Point(r.Left + 1, r.Bottom - 2)]);
    end;

  end;
    PaintAlphaTxt(FButtonDown);
  BitBlt(Canvas.Handle, 0, 0, FBmp.Width, FBmp.Height, FBmp.Canvas.Handle, 0, 0,
    SRCCOPY);
end;

procedure TGlassButton.WMERASEBKGND(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;
//
procedure TGlassButton.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  Invalidate;
  inherited;
  if not (csLoading in ComponentState) then
    Resize;
end;

//procedure TGlassButton.WMDpiChanged(var Message: TWMDpi);
//begin
//  if not (csDesigning in ComponentState) then
//  begin
//    Application.MessageBox( PChar( 'WMDpiChanged'), nil, MB_OK );
//    Message.Result := 0;
//  end;
//end;

//procedure TGlassButton.ParentWndProc(var Msg: TMessage);
//begin
//  FParentWindowHandle( Msg );
//  if (Msg.Msg = WM_PAINT) then
//  begin
//    Application.MessageBox( PChar(''), PChar('parent malt'), MB_OK );
//  end
//  //alle anderen Nachrichten werden weitergeleitet
//  else
//    Msg.Result := DefWindowProc(FParentWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
//end;

procedure TGlassButton.SetCaption(const Value: string);
begin
  FCaption := Value;
  Invalidate;
end;

procedure TGlassButton.SetColor(const Value: TColor);
begin
  FColorMouseOver := ColorToRGB(Value);
  Invalidate;
end;

procedure TGlassButton.SetColorDown(const Value: TColor);
begin
  FColorPressed := Value;
  Invalidate;
end;

procedure TGlassButton.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Caption:= FCaption;
  Invalidate;
end;

procedure TGlassButton.SetFrameColor(const Value: TColor);
begin
  FColorFrame := ColorToRGB(Value);
  Invalidate;
end;

procedure TGlassButton.SetImgIdx(const Value: Integer);
begin
  FImageIndex := Value;
  Invalidate;
end;

procedure TGlassButton.SetDisableImgIdx(const Value: Integer);
begin
  FDisableImageIndex := Value;
  Invalidate;
end;

procedure TGlassButton.SetImageAlignment(const Value: TImageAlignment);
begin
  if Value <> FImageAlignment then
  begin
    FImageAlignment := Value;
    Invalidate;
  end;
end;

procedure TGlassButton.SetParentColortype(const Value: TParentColortype);
begin
  if Value <> FParentColortype then
  begin
    FParentColortype := Value;
    Invalidate;
  end;
end;

procedure TGlassButton.InitPos;
var
  ts: TSize;
begin
  if (FImageIndex <> -1) and Assigned(FImages) then
  begin
    case ImageAlignment of
      iaLeft: begin
        GlyphX:= 4;
        GlyphY:= Round( ( ClientHeight / 2 ) - ( FImages.Height / 2 ) );
      end;
      iaRight:begin
        GlyphX:= ClientWidth - FImages.Width - 4;
        GlyphY:= Round( ( ClientHeight / 2 ) - ( FImages.Height / 2 ) );
      end;
      iaTop:begin
        GlyphX:= Round( ( ClientWidth / 2 ) - ( FImages.Width / 2 ) );
        GlyphY:= 4;
      end;
      iaBottom:begin
        GlyphX:= Round( ( ClientWidth / 2 ) - ( FImages.Width / 2 ) );
        GlyphY:= ClientHeight - FImages.Height - 4;
      end;
      iaCenter:begin
        GlyphX:= Round( ( ClientWidth / 2 ) - ( FImages.Width / 2 ) );
        GlyphY:= Round( ( ClientHeight / 2 ) - ( FImages.Height / 2 ) );
      end;
    end;
  end;

  ts:= FBmp.Canvas.TextExtent(FCaption);
  TextX:= 4;
  if (FImageIndex <> -1) and Assigned(FImages) then
    TextX:= TextX + FImages.Height + 4;
  TextY:= (ClientHeight - ts.cy) shr 1;
end;

constructor TGlassButton.Create(AOwner: TComponent);
begin
  inherited;
//  FParentWindowHandle:=GetParentHandle;
  ColorMouseOver := clWhite;
  ColorFrame := clGray;
  ColorPressed := clBlack;
  ControlStyle := [csClickEvents, csCaptureMouse, csSetCaption];
  if AOwner is TWinControl then
    Parent := TWinControl(AOwner);
  FBmp := TBitmap.Create;
  FBmp.PixelFormat := pf24Bit;
  FParentColortype := pcSingle;
  FBtnIdx := -1;
  FButtonDown := False;
  FFont := TFont.Create;
  FFont.Name := 'Tahoma';
  FFont.Color := clBlack;
  FFont.Size := 10;
  FImageIndex:= -1;
  FDisableImageIndex := -1;
  FPopup:= False;
  Height := 40;
  ParentFont := False;
  Width := 80;
  Caption:= 'GlassButton';
  //FCurrentPPI kommt aus vcl.Control
end;

destructor TGlassButton.Destroy;
begin
  FBmp.Free;
  FFont.Free;
//  DeAllocateHwnd( FParentWindowHandle );
  inherited Destroy;
end;

procedure TGlassButton.Invalidate;
begin
  if assigned(parent) and parent.HandleAllocated then
  begin
    InvalidateRect(parent.Handle, BoundsRect, true);
    inherited Invalidate;
  end
  else
    inherited Invalidate;
end;


procedure TGlassButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    FButtonDown:= True;
    if x > ClientWidth - 20 then
      FBtnIdx:= 1
    else
    begin
      FBtnIdx:= 0;
      PaintButton;
    end;
    PaintButton;
  end;
  inherited;
end;

procedure TGlassButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FButtonDown := False;
  FBtnIdx := -1;
  FPopUp := False;
  Invalidate;
  inherited;
end;

procedure TGlassButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  idx: Integer;
begin
  if (PtInRect(ClientRect, Point(x, y))) and (not FButtonDown) then
  begin
    if x > ClientWidth - 20 then
      idx:= 1
    else
      idx:= 0;
    if idx <> FBtnIdx then
    begin
      FBtnIdx:= idx;
      Invalidate;
    end;
    FButtonDown:= (ssLeft In Shift);
  end;
  inherited;
end;

procedure TGlassButton.CMMouseEnter(var Msg: TMessage);
begin
  FButtonDown := False;
  FBtnIdx := -1;
  Invalidate;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
  inherited;
end;

procedure TGlassButton.CMMouseLeave(var Msg: TMessage);
begin
  if FPopup then
    Exit;
  FButtonDown := False;
  FBtnIdx := -1;
  Invalidate;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
  inherited;
end;

procedure TGlassButton.CMEnabledChanged(var Message: TMessage);
begin
//  Invalidate;
  PaintButton;
  inherited;
end;

procedure TGlassButton.CMFontChanged(var Message: TMessage);
begin
  Refresh;
//  PaintButton;
//  Inherited;
end;

procedure TGlassButton.WMPaint( var Message: TWMPaint );
begin
  inherited;
  PaintHandler( Message );

//  PaintWindow( Message.DC );
//  PaintButton;
end;

procedure TGlassButton.Resize;
begin
  //Application.MessageBox( PChar( 'Resize'), nil, MB_OK );
  Invalidate;
end;

procedure Register;
begin
  RegisterComponents('Basti_Komponenten', [TGlassButton]);
end;

end.



