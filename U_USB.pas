{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  U_USB
  Author: copyright (c) Sebastian Seidel
  Date:   30.09.2020

  Erkennt das anstecken und abziehen eines USB-Speichers
  Kann den laufwerksbuchstaben zurück geben
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

unit U_USB;

interface

uses
  Windows, Messages, SysUtils, Classes,
  vcl.Forms;

type

  PDevBroadcastHdr  = ^DEV_BROADCAST_HDR;
  DEV_BROADCAST_HDR = packed record
    dbch_size: DWORD;
    dbch_devicetype: DWORD;
    dbch_reserved: DWORD;
  end;

  PDevBroadcastDeviceInterface  = ^DEV_BROADCAST_DEVICEINTERFACE;
  DEV_BROADCAST_DEVICEINTERFACE = record
    dbcc_size: DWORD;
    dbcc_devicetype: DWORD;
    dbcc_reserved: DWORD;
    dbcc_classguid: TGUID;
    dbcc_name: short;
  end;


  PDevBroadCastVolume = ^DEV_BROADCAST_VOLUME;
  DEV_BROADCAST_VOLUME = record
    dbcv_size : DWORD;
    dbcv_devicetype : DWORD;
    dbcv_reserved: DWORD;
    dbcv_unitmask: DWORD;
    dbcv_flags: WORD;
  end;

const
  GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';
  DBT_DEVICEARRIVAL          = $8000;          // system detected a new device
  DBT_DEVICEREMOVECOMPLETE   = $8004;          // device is gone
  DBT_DEVTYP_DEVICEINTERFACE = $00000005;      // device interface class
  DBT_DEVTYPE_VOLUME         = $0002;


type
  TGetUSBDriveEvent = procedure( Sender : TObject; const DrivePath : String ) of object;

  TComponentUSB = class(TComponent)
  private
    FWindowHandle: HWND;
    FOnUSBArrival: TNotifyEvent;
    FOnUSBGetDriveLetter: TGetUSBDriveEvent;
    FOnUSBRemove: TNotifyEvent;
    FDriveChar : char;
    FDrivePath : string;
    FRequired : Boolean;
    procedure WndProc(var Msg: TMessage);
    function USBRegister: Boolean;
    procedure SetDriveFromMask( unitmask : DWORD );
    procedure SetDrivePath;
  protected
    procedure WMDeviceChange(var Msg: TMessage); dynamic;
  public
    property DriveChar : char read FDriveChar write FDriveChar;
    property DrivePath : string Read FDrivePath write FDrivePath;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnUSBArrival: TNotifyEvent read FOnUSBArrival write FOnUSBArrival;
    property OnUSBGetDriveLetter: TGetUSBDriveEvent read FOnUSBGetDriveLetter write FOnUSBGetDriveLetter;
    property OnUSBRemove: TNotifyEvent read FOnUSBRemove write FOnUSBRemove;
    property Required : Boolean read FRequired write FRequired;
  end;

procedure Register;

implementation

constructor TComponentUSB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWindowHandle := AllocateHWnd(WndProc);
  USBRegister;
end;

destructor TComponentUSB.Destroy;
begin
  DeallocateHWnd(FWindowHandle);
  inherited Destroy;
end;

procedure TComponentUSB.WndProc(var Msg: TMessage);
begin
  if FRequired then
  begin
    if (Msg.Msg = WM_DEVICECHANGE) then
    begin
      try
        WMDeviceChange(Msg);
      except
        Application.HandleException(Self);
      end;
    end
    else
      Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
  end;
end;

procedure TComponentUSB.WMDeviceChange(var Msg: TMessage);
var
  devType: Integer;
  Datos: PDevBroadcastHdr;
  pDBCV : PDevBroadCastVolume;
begin
  if (Msg.wParam = DBT_DEVICEARRIVAL) or (Msg.wParam = DBT_DEVICEREMOVECOMPLETE) then
  begin
    Datos := PDevBroadcastHdr(Msg.lParam);
    devType := Datos^.dbch_devicetype;

    if devType = DBT_DEVTYP_DEVICEINTERFACE then
    begin
      if Msg.wParam = DBT_DEVICEARRIVAL then
      begin
        // ein USB gerät wurde eingesteckt
//        if Assigned(FOnUSBGetDriveLetter) then
//          FOnUSBGetDriveLetter( Self, FDrivePath );
        if Assigned(FOnUSBArrival) then
          FOnUSBArrival(Self);
      end
      else
      begin
        // ein USB gerät wurde entfernt
        if Assigned(FOnUSBRemove) then
          FOnUSBRemove(Self);
      end;
    end;

    if devType = DBT_DEVTYPE_VOLUME then
    begin
      if Msg.wParam = DBT_DEVICEARRIVAL then
      begin
        // ermitteln des zugeteilten Laufwerksbuchstabes
        Datos := PDevBroadcastHdr(Msg.lParam);
        pDBCV := PDevBroadCastVolume( Datos );
        SetDriveFromMask( pDBCV^.dbcv_unitmask );
//        if Assigned(FOnUSBArrival) then
//          FOnUSBArrival(Self);
        if Assigned(FOnUSBGetDriveLetter) then
          FOnUSBGetDriveLetter( Self, FDrivePath );
      end;
    end;
  end;
end;

function TComponentUSB.USBRegister: Boolean;
var
  dbi: DEV_BROADCAST_DEVICEINTERFACE;
  Size: Integer;
  r: Pointer;
begin
  Result := False;
  Size := SizeOf(DEV_BROADCAST_DEVICEINTERFACE);
  ZeroMemory(@dbi, Size);
  dbi.dbcc_size := Size;
  dbi.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;
  dbi.dbcc_reserved := 0;
  dbi.dbcc_classguid  := GUID_DEVINTERFACE_USB_DEVICE;
  dbi.dbcc_name := 0;

  r := RegisterDeviceNotification(FWindowHandle, @dbi,
    DEVICE_NOTIFY_WINDOW_HANDLE
    );
  if Assigned(r) then Result := True;
end;

procedure TComponentUSB.SetDriveFromMask( unitmask : DWORD );
var
OrdChar,
I : Integer;
begin
  OrdChar := Ord( 'A' );
  for I := 0 to 26 do
  begin
    if ( ( unitmask shr I ) and 1 ) = 1 then
    begin
      OrdChar := OrdChar + I;
      break;
    end;
  end;
  FDriveChar := char( OrdChar );
  SetDrivePath;
end;

procedure TComponentUSB.SetDrivePath;
begin
  FDrivePath := Concat( FDriveChar , ':\' );
end;

procedure Register;
begin
  RegisterComponents('Basti_Komponenten',[TComponentUSB]);
end;

end.
