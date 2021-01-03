unit Edit4User;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Edit4User
  Author: Sebastian Seidel
  Date:   08.10.2020

  ermöglicht bei einer falschen Eingabe ein roten Rahmen und bei richtiger
  Eingabe einen grünen Rahmen, mit TextHint
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

interface

uses
  Winapi.Messages, System.UITypes, System.SysUtils, System.Types, System.Classes,
  Vcl.Controls, Vcl.Graphics ,Vcl.StdCtrls;

type
  TEdit4User = Class(Vcl.StdCtrls.TEdit)
    procedure WMPaint( var Message: TWMPaint ); message WM_PAINT;
    procedure CMTextChanged( var Message: TMessage ); message CM_TEXTCHANGED;
    procedure WMKEYUP( var Message: TWMPaint ); message WM_KEYUP;
  private
    FPainted: Boolean;
    FRequired: Boolean;
    FUserExist : Boolean;
    procedure CheckForInvalidate;
    procedure DrawBorder( AColor : TColor );
  published
    Property Required: Boolean read FRequired write FRequired default false;
  public
    Property UserExist: Boolean read FUserExist Write FUserExist default false;
  End;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Basti_Komponenten', [TEdit4User]);
end;

{------------------------------------------------------------------------------
*******************************************************************************
TEdit mit Farbigen Rand
*******************************************************************************
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
procedure TEdit4User.CMTextChanged(var Message: TMessage);
begin
  inherited;
  CheckForInvalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEdit4User.CheckForInvalidate;
begin
  if Required and ( ( Length( Trim( Text ) ) = 0 ) or UserExist ) then
  begin
    if not FPainted then
      Invalidate;
  end
  else if Required and not UserExist then
  begin
    if FPainted then
      Invalidate;
  end
  else if FPainted then
    Invalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEdit4User.WMKEYUP(var Message: TWMPaint);
begin
  CheckForInvalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEdit4User.WMPaint(var Message: TWMPaint);
begin
  inherited;
  if Required and ( ( Length( Trim( Text ) ) = 0 ) or UserExist ) then
  begin
    FPainted := true;
    DrawBorder( clRed );
    if Length( Trim( Text ) ) = 0 then
      Hint := 'Bitte einen Benutzer eingeben!'
    else
      Hint := 'Der eigebene Benutzer ist bereits vorhanden!' + sLineBreak + 'Bitte wählen Sie einen Anderen.';
  end
  else
  if Required and ( not UserExist ) then
  begin
    FPainted := false;
    DrawBorder( clGreen );
    Hint := 'Der eigebene Benutzer kann verwendet werden.';
  end
  else
  begin
    FPainted := false;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEdit4User.DrawBorder( AColor : TColor );
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
