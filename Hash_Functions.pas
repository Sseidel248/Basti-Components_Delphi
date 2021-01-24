{******************************************************************************
Hash_Functions

Author: copyright (c) Sebastian Seidel

Funktionen zum Verschlüsseln von wichtigen Informationen
*******************************************************************************}

unit Hash_Functions;

interface

uses
  System.Hash;

function GetMD5String( str : String ) : String;
function GetSHA256String( str : String ) : String;
function GetSHA224String( str : String ) : String;
function GetSHA384String( str : String ) : String;
function GetSHA512String( str : String ) : String;
function GetSHA512_256String( str : String ) : String;
function GetCryptStr( str1, str2, str3 : String ) : String;

implementation

uses
  System.SysUtils;

function GetMD5String( str : String ) : String;
//var
//HashMD5 : THashMD5;
begin
  Result := THashMD5.GetHashString( str );
end;

function GetSHA256String( str : String ) : String;
//var
//HashSHA2 : THashSHA2;
begin
  Result := THashSHA2.GetHashString( str, SHA256 );
end;

function GetSHA224String( str : String ) : String;
//var
//HashSHA2 : THashSHA2;
begin
  Result := THashSHA2.GetHashString( str, SHA224 );
end;

function GetSHA384String( str : String ) : String;
//var
//HashSHA2 : THashSHA2;
begin
  Result := THashSHA2.GetHashString( str, SHA384 );
end;

function GetSHA512String( str : String ) : String;
//var
//HashSHA2 : THashSHA2;
begin
  Result := THashSHA2.GetHashString( str, SHA512 );
end;

function GetSHA512_256String( str : String ) : String;
//var
//HashSHA2 : THashSHA2;
begin
  Result := THashSHA2.GetHashString( str, SHA512_256 );
end;

function CutAtFront( str : String) : String;
var
CountToCut : Integer;
begin
  case str.Chars[0] of
    'a': CountToCut := 11;
    'b': CountToCut := 12;
    'c': CountToCut := 13;
    'd': CountToCut := 14;
    'e': CountToCut := 15;
    'f': CountToCut := 16;
    else begin
      CountToCut := StrToInt( str.Chars[0] ) +1;
    end;
  end;
  Result := copy( str, CountToCut, length( str ) );
end;

function ReplaceSameAsLast( str : String ) : String;
var
LastChar : Char;
begin
  LastChar := str.Chars[ length( str )-1 ];
  Result := StringReplace( str, LastChar, '$', [rfReplaceAll] );
end;

function GetCryptStr( str1, str2, str3 : String ) : String;
var
//HashMD5 : THashMD5;
//HashSHA2 : THashSHA2;
part1, part2, part3 : String;
part4, part5 : string;
begin
  //Stufe 1
  part1 := THashMD5.GetHashString( str1 );
  part2 := THashMD5.GetHashString( str2 );
  part3 := THashMD5.GetHashString( str3 );
  //Stufe 2
  part1 := THashSHA2.GetHashString( part1, SHA256 );
  part2 := THashSHA2.GetHashString( part2, SHA224 );
  part3 := THashSHA2.GetHashString( part3, SHA512 );
  //Stufe 3
  part1 := CutAtFront( part1 );
  part2 := CutAtFront( part2 );
  part3 := CutAtFront( part3 );
  //Strufe 4
  part4 := Concat( part1, part2, part3 );
  //Stufe 5
  part5 := THashSHA2.GetHashString( part4, SHA512_256 );
  //Stufe 6
  Result := ReplaceSameAsLast( part5 );
end;

end.
