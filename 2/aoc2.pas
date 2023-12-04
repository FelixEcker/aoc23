{$mode fpc}
program aoc2;

uses SysUtils, StrUtils, Types;

{$H+}

const
  REDS = 0;
  GREENS = 0;
  BLUES = 0;

function process(_str: String): Integer;
var
  ix, game_id: Integer;
  sets: array of TStringDynArray;
  tmp: TStringDynArray;
  _set: String;
begin
  tmp := SplitString(Copy(
    _str,
    pos(':', _str) + 2,
    Length(_str)
    ), ';');

  SetLength(sets, Length(tmp));
  for ix := 0 to Length(sets) - 1 do
  begin
    sets[ix] := SplitString(Trim(tmp[ix]), ',');
    writeln(Trim(tmp[ix]));
  end;
  writeln('end');
end;

var
  in_fl: TextFile;
  inval: String;
  out: Integer;
begin
  Assign(in_fl, 'test_input');
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
