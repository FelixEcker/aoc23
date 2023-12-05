{$mode objfpc}
program aoc5;

{$H+}

uses SysUtils, StrUtils, Types;

type 
  TUInt64DynArray = array of UInt64;

  TRange = record
    org: UInt64;
    dest: UInt64;
    len: UInt64;
  end;

  PRange = ^TRange;

  TRangeDynarray = array of TRange;

  TMapDest = (mdSOIL, mdFERT, mdWATER, mdLIGHT, mdTEMP, mdHUMID, mdLOC);

  TMap = record
    seeds: TUInt64DynArray;
    soil: TRangeDynArray;
    fert: TRangeDynArray;
    water: TRangeDynArray;
    light: TRangeDynArray;
    temp: TRangeDynArray;
    humid: TRangeDynArray;
    loc: TRangeDynArray;

    mapdest: TMapDest;
  end;

function is_digit(const c: Char): Boolean;
begin
  if (Byte(c) >= Byte('0')) and (Byte(c) <= Byte('9')) then exit(True);
  exit(False);
end;

function StrArrToIntArr(const inarr: TStringDynArray): TUInt64DynArray;
var
  wix, ix: UInt64;
begin
  SetLength(StrArrToIntArr, Length(inarr));
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

procedure parse_seeds(var map: TMap; _str: String);
begin
  _str := Trim(Copy(_str, pos(':', _str) + 1, Length(_str)));
  map.seeds := StrArrToIntArr(SplitString(_str, ' '));
end;

procedure parse_range(var map: TMap; _str: String);
var
  tmp: TUInt64DynArray;
  dest: PRange;
begin
  tmp := StrArrToIntArr(SplitString(Trim(_str), ' '));
  case map.mapdest of
    mdSOIL: begin
      SetLength(map.soil, Length(map.soil) + 1);
      dest := @map.soil[HIGH(map.soil)];
    end;
    mdFERT: begin
      SetLength(map.fert, Length(map.fert) + 1);
      dest := @map.fert[HIGH(map.fert)];
    end;
    mdWATER: begin
      SetLength(map.water, Length(map.water) + 1);
      dest := @map.water[HIGH(map.water)];
    end;
    mdLIGHT: begin
      SetLength(map.light, Length(map.light) + 1);
      dest := @map.light[HIGH(map.light)];
    end;
    mdTEMP: begin
      SetLength(map.temp, Length(map.temp) + 1);
      dest := @map.temp[HIGH(map.temp)];
    end;
    mdHUMID: begin
      SetLength(map.humid, Length(map.humid) + 1);
      dest := @map.humid[HIGH(map.humid)];
    end;
    mdLOC: begin
      SetLength(map.loc, Length(map.loc) + 1);
      dest := @map.loc[HIGH(map.loc)];
    end;
  end;
  dest^.org := tmp[1]; 
  dest^.dest := tmp[0];
  dest^.len := tmp[2];
end;

procedure parse_map(var map: TMap; const _str: String);
var
  tmp: String;
begin
  if Length(_str) < 1 then exit;
  if not is_digit(_str[1]) then
  begin
    tmp := Copy(_str, 1, pos(':', _str) - 1);
    if tmp = 'seeds' then
    begin 
      parse_seeds(map, _str); 
      exit; 
    end;
    tmp := SplitString(_str, '-')[0];
    case tmp of
      'seed': map.mapdest := mdSOIL;
      'soil': map.mapdest := mdFERT;
      'fertilizer': map.mapdest := mdWATER;
      'water': map.mapdest := mdLIGHT;
      'light': map.mapdest := mdTEMP;
      'temperature': map.mapdest := mdHUMID;
      'humidity': map.mapdest := mdLOC;
    end;
    exit;
  end;

  parse_range(map, _str);
end;

function solve(const map: TMap): UInt64;
begin
  solve := 0
end;

var
  in_fl: TextFile;
  inval: String;
  out: Int64;
  map: TMap;
begin
  Assign(in_fl, 'test');
  ReSet(in_fl);

  while not eof(in_fl) do
  begin
    readln(in_fl, inval);
    parse_map(map, inval);
  end;

  Close(in_fl);

  writeln(solve(map));
end.
