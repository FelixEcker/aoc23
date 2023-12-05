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

    StrArrToIntArr[wix] := StrToInt64(inarr[ix]);
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

function get_dest(const map: TMap; const key: UInt64): TUInt64DynArray;
var
  dest: TRangeDynArray;
  range: TRange;
  matches: UInt64;
  found: Boolean;
begin
  get_dest := [key];
  case map.mapdest of
    mdSOIL: dest := map.soil;
    mdFERT: dest := map.fert;
    mdWATER: dest := map.water;
    mdLIGHT: dest := map.light;
    mdTEMP: dest := map.temp;
    mdHUMID: dest := map.humid;
    mdLOC: dest := map.loc;
  end;

  matches := 0;
  for range in dest do
  begin
    { If key is outside the range fuck off }
    if (range.org > key) then continue;
    if (range.org + range.len - 1) < key then continue;

    matches := matches + 1;
    SetLength(get_dest, matches);
    get_dest[HIGH(get_dest)] := range.dest + (key - range.org);
  end;
  writeln(matches);
end;

function sub_solve(map: TMap; const start: TMapDest; const key: UInt64): UInt64;
var
  tmp, tmp2, tmp3, ix: UInt64;
  results: TUInt64DynArray;
  dest: TMapDest;
  first, first_sub, check2: Boolean;
begin
  writeln('subsolve');
  first := True;
  for dest := start to mdLOC do
  begin
    map.mapdest := dest;
    results := get_dest(map, tmp);
    tmp := results[0];

    if Length(results) > 1 then
    begin
      check2 := True;
      first_sub := True;
      for ix := 1 to Length(results) - 1 do
      begin
        tmp3 := sub_solve(map, TMapDest(Int64(dest) + 1), results[ix]);
        if (tmp2 > tmp3) or first_sub then
          tmp2 := tmp3;
        first_sub := False;
      end;
    end;
    if (tmp < sub_solve) or first then
      sub_solve := tmp;
    if check2 and (tmp2 < sub_solve) then
      sub_solve := tmp2;
  end;
  

  first := False;
end;

function solve(map: TMap): UInt64;
var
  seed, tmp, tmp2, tmp3, ix: UInt64;
  results: TUInt64DynArray;
  dest: TMapDest;
  first, first_sub, check2: Boolean;
begin
  solve := 0;
  first := True;

  for seed in map.seeds do
  begin
    tmp := seed;
    check2 := False;
    for dest := mdSOIL to mdLOC do
    begin
      map.mapdest := dest;
      results := get_dest(map, tmp);
      tmp := results[0];

      { Consider overlapping ranges by recursively sub-solving.
        Got a bit hacky out of desperation }
      if Length(results) > 1 then
      begin
        check2 := True;
        first_sub := True;
        for ix := 1 to Length(results) - 1 do
        begin
          tmp3 := sub_solve(map, TMapDest(Int64(dest) + 1), results[ix]);
          if (tmp2 > tmp3) or first_sub then
            tmp2 := tmp3;
          first_sub := False;
        end;
      end;
    end;

    if (tmp < solve) or first then
      solve := tmp;
    if check2 and (tmp2 < solve) then
      solve := tmp2;

    first := False;
  end;
end;

var
  in_fl: TextFile;
  inval: String;
  out: Int64;
  map: TMap;
begin
  Assign(in_fl, 'input');
  ReSet(in_fl);

  while not eof(in_fl) do
  begin
    readln(in_fl, inval);
    parse_map(map, inval);
  end;

  Close(in_fl);

  writeln(solve(map));
end.
