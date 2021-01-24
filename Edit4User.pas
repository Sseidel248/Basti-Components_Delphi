{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Edit4User
  Author: copyright (c) Sebastian Seidel
  Date:   08.10.2020

  Spezielle Anpassungen für eine Benutzereingabe
  Rahmen wird rot wenn FUserExist = true und grün wenn FUserExist = false
  Zudem wird ein passender Hint erzeugt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

unit Edit4User;

interface

uses
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  vcl.Controls,
  vcl.Graphics,
  EditEx;

type
  TEdit4User = Class(TEditEx)
    procedure WMPaint( var Message: TWMPaint ); message WM_PAINT;
    procedure CMTextChanged( var Message: TMessage ); message CM_TEXTCHANGED;
    procedure WMKEYUP( var Message: TWMPaint ); message WM_KEYUP;
  private
    FPainted: Boolean;
    FRequired: Boolean;
    FUserExist : Boolean;
    procedure CheckForInvalidate;
    procedure ChangeBorder( const AColor : TColor );
  published
    Property Required: Boolean read FRequired write FRequired default false;
  public
    constructor Create(AOwner: TComponent); override;
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

constructor TEdit4User.Create(AOwner: TComponent);
begin
  inherited Create( AOwner );
  ShowHint := true;
end;

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
    ChangeBorder( clRed );
    if Length( Trim( Text ) ) = 0 then
      Hint := 'Bitte einen Benutzer eingeben!'
    else
      Hint := 'Der eigebene Benutzer ist bereits vorhanden!' + sLineBreak + 'Bitte wählen Sie einen Anderen.';
  end
  else
  if Required and ( not UserExist ) then
  begin
    FPainted := false;
    ChangeBorder( clGreen );
    Hint := 'Der eigebene Benutzer kann verwendet werden.';
  end
  else
  begin
    ChangeBorder( clNone );
    FPainted := false;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TEdit4User.ChangeBorder( const AColor : TColor );
begin
  Self.Bordercolor := AColor;
  Self.FocusBorderColor := AColor;
end;
{------------------------------------------------------------------------------
*******************************************************************************
TEdit mit Farbigen Rand - Ende
*******************************************************************************
-------------------------------------------------------------------------------}

end.
