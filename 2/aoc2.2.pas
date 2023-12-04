{$mode fpc}
program aoc2.part2;

uses SysUtils, StrUtils, Types;

{$H+}

const
  REDS = 12;
  GREENS = 13;
  BLUES = 14;

function process(_str: String): UInt64;
var
  ix, ix_2, n: UInt64;
  r_highest, g_highest, b_highest: UInt64;
  tmp, tmp_2, tmp_3: TStringDynArray;
begin
  tmp := SplitString(Copy(
    _str,
    pos(':', _str) + 2,
    Length(_str)
    ), ';');

  r_highest := 0;
  g_highest := 0;
  b_highest := 0;

  for ix := 0 to Length(tmp) - 1 do
  begin
    tmp_2 := SplitString(Trim(tmp[ix]), ',');
    for ix_2 := 0 to Length(tmp_2) - 1 do
    begin
      tmp_3 := SplitString(Trim(tmp_2[ix_2]), ' ');
      n := StrToInt(tmp_3[0]);
      if (tmp_3[1] = 'blue') and (n > b_highest) then b_highest := n;
      if (tmp_3[1] = 'red') and (n > r_highest) then r_highest := n;
      if (tmp_3[1] = 'green') and (n > g_highest) then g_highest := n;
    end;
  end;

  process := r_highest * g_highest * b_highest;
end;

var
  in_fl: TextFile;
  inval: String;
  out: UInt64;
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
