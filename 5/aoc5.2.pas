{$mode objfpc}
program aoc5.part2;

{$H+}

{ This is probably one of my least favorite solutions. Because I just wanted to
  get it done, I just decided to give each seed range a thread for solving.
  This still takes ages (~25 minutes) and is really stupid. Maybe I wont be able
  to live with myself because of creating this solution and create a better one
  which is actually fast. Maybe I wont.}

uses cthreads, Crt, SysUtils, StrUtils, Types;

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

  TThreadData = record
    map: TMap;
    start: UInt64;
    amount: UInt64;
  end;

  PThreadData = ^TThreadData;

var
  critical: TRTLCriticalSection;
  thread_results: TUInt64DynArray;

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

function get_dest(const map: TMap; const key: UInt64): UInt64;
var
  dest: TRangeDynArray;
  range: TRange;
  found: Boolean;
begin
  case map.mapdest of
    mdSOIL: dest := map.soil;
    mdFERT: dest := map.fert;
    mdWATER: dest := map.water;
    mdLIGHT: dest := map.light;
    mdTEMP: dest := map.temp;
    mdHUMID: dest := map.humid;
    mdLOC: dest := map.loc;
  end;

  get_dest := key;
  for range in dest do
  begin
    { If key is outside the range fuck off }
    if (range.org > key) then continue;
    if (range.org + range.len - 1) < key then continue;

    get_dest := range.dest + (key - range.org);
    break;
  end;
end;

function make_range(const start: UInt64; const _end: UInt64): TUInt64DynArray;
var
  ix: UInt64;
begin
  SetLength(make_range, _end);
  for ix := 0 to Length(make_range) - 1 do
    make_range[ix] := start + ix;
end;

function crunch(p: Pointer): Int64;
var
  thread_data: TThreadData;
  map: TMap;
  solve, seed, seedix, tmp: UInt64;
  seeds: TUInt64DynArray;
  dest: TMapDest;
  first: Boolean;
begin
  solve := 0;
  first := True;

  thread_data := PThreadData(p)^;
  map := thread_data.map;

  seeds := make_range(thread_data.start, thread_data.amount);
  for seed in seeds do
  begin
    tmp := seed;
    for dest := mdSOIL to mdLOC do
    begin
      map.mapdest := dest;
      tmp := get_dest(map, tmp);
    end;

    if (tmp < solve) or first then
      solve := tmp;

    first := False;
  end;

  EnterCriticalSection(critical);
  SetLength(thread_results, Length(thread_results) + 1);
  thread_results[HIGH(thread_results)] := solve;
  LeaveCriticalSection(critical);
  Dispose(p);
  writeln('thread done!');
end;

function solve(map: TMap): UInt64;
var
  nthreads, i: Integer;
  thread_data: PThreadData;
begin
  InitCriticalSection(critical);
  nthreads := Length(map.seeds) div 2;
  writeln('crunching with ', nthreads, ' threads!');
  SetLength(thread_results, 0);
  for i := 0 to nthreads - 1 do
  begin
    { This leaks memory, too bad! (?) }
    New(thread_data);
    thread_data^.map := map;
    thread_data^.start := map.seeds[i * 2];
    thread_data^.amount := map.seeds[(i * 2) + 1];
    BeginThread(@crunch, thread_data);
  end;

  while True do
  begin
    EnterCriticalSection(critical);
    if Length(thread_results) = nthreads then
    begin
      LeaveCriticalSection(critical);
      delay(100);
      break;
    end;
    LeaveCriticalSection(critical);
    delay(100);
  end;
  DoneCriticalSection(critical);

  solve := thread_results[0];
  for i := 1 to Length(thread_results) - 1 do
    if thread_results[i] < solve then
      solve := thread_results[i];
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
