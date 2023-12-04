{$mode fpc}
program aoc4;

{$H+}

uses SysUtils, StrUtils, Types;

type
  TInt64DynArray = array of Int64;

function StrArrToIntArr(const inarr: TStringDynArray): TInt64DynArray;
var
  wix, ix: Int64;
begin
  wix := 0;
  for ix := 0 to Length(inarr) - 1 do
  begin
    if inarr[ix] = '' then 
    begin
      SetLength(StrArrToIntArr, Length(StrArrToIntArr) - 1 );
      continue;
    end;

    StrArrToIntArr[wix] := StrToInt(inarr[ix]);
    wix := wix + 1;
  end;
end;

function process(_str: String): Int64;
var
  tmp, swinning, shand: TStringDynArray;
  ix, ix2: Int64;
  winning, hand: TInt64DynArray;
begin
  process := 0;

  tmp := SplitString(Copy(
      _str,
      pos(':', _str) + 1,
      Length(_str)
    )
    , '|');

  swinning := SplitString(Trim(tmp[0]), ' ');
  shand := SplitString(Trim(tmp[1]), ' ');

  SetLength(winning, Length(swinning));
  SetLength(hand, Length(shand));

  winning := StrArrToIntArr(swinning);
  hand := StrArrToIntArr(shand);

  for ix := 0 to Length(hand) - 1 do
  begin
    for ix2 := 0 to Length(winning) - 1 do
    begin
      if winning[ix2] = hand[ix] then
        if process = 0 then
          process := 1
        else
          process := process * 2;
    end;
  end;
end;

var
  in_fl: TextFile;
  inval: String;
  out: Int64;
begin
  Assign(in_fl, 'input');
  ReSet(in_fl);

  out := 0;

  while not eof(in_fl) do
  begin
    readln(in_fl, inval);
    out := out + process(inval);
  end;

  Close(in_fl);
  writeln(out);
end.
