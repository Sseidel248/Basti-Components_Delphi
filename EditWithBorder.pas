unit EditWithBorder;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  EditWithBorder
  Author: Sebastian Seidel
  Date:   10.10.2020

  ermöglicht das Zeichnen eines Rahmens wenn die Eingabe leer ist, mit TextHint
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

interface

uses
  Winapi.Messages, System.SysUtils, System.Classes, System.Types, Vcl.Controls,
  Vcl.StdCtrls, vcl.graphics;

type
  TEditWithBorder = Class(Vcl.StdCtrls.TEdit)
    procedure WMPaint( var Message: TWMPaint ); message WM_PAINT;
    procedure CMTextChanged(var Message: TMessage);
    procedure WMKEYUP( var Message: TWMPaint ); message WM_KEYUP;
  private
    FPainted: Boolean;
    F4EmptyText : Boolean;
    FRequired: Boolean;
    FTextBorderColor : TColor;
    procedure CheckForInvalidate;
    procedure DrawBorder( AColor : TColor );
  published
    Property Required: Boolean read FRequired write FRequired;
    Property ForEmptyText : Boolean read F4EmptyText write F4EmptyText;
    property TextBorderColor : TColor read FTextBorderColor write FTextBorderColor;
  public
    constructor Create( AOwner : TComponent ); override;
  End;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Basti_Komponenten', [TEditWithBorder]);
end;

{------------------------------------------------------------------------------
*******************************************************************************
TEdit mit Farbigen Rand
*******************************************************************************
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
Constructor TEditWithBorder.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  FPainted := false;
  FRequired := false;
  FTextBorderColor := clNone;
  F4EmptyText := true;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
procedure TEditWithBorder.CMTextChanged(var Message: TMessage);
begin
  inherited;
  CheckForInvalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEditWithBorder.CheckForInvalidate;
var
isTextEmpty : Boolean;
begin
  if F4EmptyText then
    isTextEmpty := ( Length( Trim( Text ) ) = 0 )
  else
    isTextEmpty := true;

  if Required and {( Length( Trim( Text ) ) = 0 )}isTextEmpty then
  begin
    if not FPainted then
      Invalidate;
  end
  else if FPainted then
    Invalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEditWithBorder.WMKEYUP(var Message: TWMPaint);
begin
  CheckForInvalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEditWithBorder.WMPaint(var Message: TWMPaint);
var
isTextEmpty : Boolean;
begin
  inherited;

  if F4EmptyText then
    isTextEmpty := ( Length( Trim( Text ) ) = 0 )
  else
    isTextEmpty := true;

  if Required and {( Length( Trim( Text ) ) = 0 )}isTextEmpty then
  begin
    FPainted := true;
    DrawBorder( TextBorderColor );
  end
  else
  begin
    FPainted := false;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEditWithBorder.DrawBorder( AColor : TColor );
var
  CC: TControlCanvas;
  OldFontSize : Integer;
  TextStr : String;
  Rect : TRect;
begin
  OldFontSize := Font.Size;
  TextStr := Text;
  Rect := ClientRect;
  CC := TControlCanvas.Create;
  try
    CC.Control := Self;
    CC.Pen.Color := AColor;
    CC.Pen.Width := 3;
    CC.Rectangle( ClientRect );
    CC.Font.Size := OldFontSize;
    if length( Trim ( Text ) ) = 0 then
    begin
      CC.Font.Color := clSilver;
      CC.TextOut( 2, 2, TextHint )
    end
    else
    begin
      CC.Font.Color := clBlack;
      CC.TextOut( 2, 2, Text );
    end;

  finally
    CC.Free;
  end;
end;
{------------------------------------------------------------------------------
*******************************************************************************
TEdit mit Farbigen Rand - Ende
*******************************************************************************
-------------------------------------------------------------------------------}

end.
