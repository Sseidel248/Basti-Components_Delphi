unit DBEditWithTextHint;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  DBEditWithTextHint
  Author: Sebastian Seidel
  Date:   10.10.2020

  ermöglicht eine TextHint beim TDBEdit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

interface

uses
  Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls,
  System.Types,Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, vcl.graphics;

type
  TDBEditWithTextHint = class(TDBEdit)
    procedure WMPaint( var Message: TWMPaint ); message WM_PAINT;
    procedure CMTextChanged(var Message: TMessage);
    procedure WMKEYUP( var Message: TWMPaint ); message WM_KEYUP;
    procedure DrawTextHint;
  private
    FTextHint : String;
    procedure CheckForInvalidate;
  published
    property TextHint : String read FTextHint write FTextHint;
  public
    constructor Create( AOwner : TComponent ); override;
  End;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Basti_Komponenten', [TDBEditWithTextHint]);
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
procedure TDBEditWithTextHint.CMTextChanged(var Message: TMessage);
begin
  inherited;
  CheckForInvalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
Constructor TDBEditWithTextHint.Create( AOwner : TComponent );
begin
  inherited Create( AOwner );
  FTextHint := '';
  Font.Size := 10;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TDBEditWithTextHint.CheckForInvalidate;
begin
  if Length( Trim( Text ) ) = 0 then
  begin
    Invalidate;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TDBEditWithTextHint.WMKEYUP(var Message: TWMPaint);
begin
  CheckForInvalidate;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TDBEditWithTextHint.WMPaint(var Message: TWMPaint);
begin
  inherited;
  if  Length( Trim( Text ) ) = 0   then
  begin
    DrawTextHint;
  end
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-10
-------------------------------------------------------------------------------}
procedure TDBEditWithTextHint.DrawTextHint;
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
    CC.Font.Size := OldFontSize;
    if length( Trim ( Text ) ) = 0 then
    begin
      CC.Font.Color := clSilver;
      CC.TextOut( 2, 2, '<' + TextHint + '>' );
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

end.
