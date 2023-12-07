{$mode fpc}
program aoc6.part2;

{$H+}

uses SysUtils, StrUtils, Types;

type
  TUInt64DynArray = array of UInt64;

  TRaceHistory = record
    durations: UInt64;
    records: UInt64;
  end;

function StrArrToIntArr(inarr: TStringDynArray): TUInt64DynArray;
var
  wix, ix: UInt64;
begin
  SetLength(StrArrToIntArr, Length(inarr));
  wix := 0;
  for ix := 0 to Length(inarr) - 1 do
  begin
    inarr[ix] := Trim(inarr[ix]);
    if inarr[ix] = '' then 
    begin
      SetLength(StrArrToIntArr, Length(StrArrToIntArr) - 1 );
      continue;
    end;

    StrArrToIntArr[wix] := StrToInt64(inarr[ix]);
    wix := wix + 1;
  end;
end;

procedure parse(_str: String; var racehis: TRaceHistory);
var
  dest: String;
  tmp: UInt64;
begin
  dest := Copy(_str, 1, pos(':', _str) - 1);
  tmp := StrToInt64(StringReplace(Trim(Copy(
    _str,
    pos(':', _str) + 1,
    Length(_str)
  )), ' ', '', [rfReplaceAll]));

  if (dest = 'Time') then
    racehis.durations := tmp
  else
    racehis.records := tmp;
end;

function single_solve(const len: UInt64; const rec: UInt64): UInt64;
var
  hold_time, mm_ms, distance: UInt64;
  initial: Boolean;
begin
  single_solve := 0;

  initial := False;
  for hold_time := 1 to len do
  begin
    { distance = mm_ms * (len - hold_time) }
    distance := hold_time * (len - hold_time);
    if distance > rec then
    begin
      if not initial then initial := True;
      single_solve := single_solve + 1;
    end else if (distance < rec) and initial then
      break;
  end;
end;

function solve(const racehis: TRaceHistory): UInt64;
var
  ix: UInt64;
begin
  solve := single_solve(racehis.durations, racehis.records);
end;

var
  in_fl: TextFile;
  inval: String;
  racehis: TRaceHistory;
begin
  Assign(in_fl, 'input');
  ReSet(in_fl);

  while not eof(in_fl) do
  begin
    readln(in_fl, inval);
    parse(inval, racehis);
  end;

  Close(in_fl);

  writeln(solve(racehis));
end.
