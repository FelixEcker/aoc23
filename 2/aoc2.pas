{$mode fpc}
program aoc2;

uses SysUtils, StrUtils, Types;

{$H+}

const
  REDS = 12;
  GREENS = 13;
  BLUES = 14;

function process(_str: String): Integer;
var
  ix, ix_2, n, game_id: Integer;
  tmp, tmp_2, tmp_3: TStringDynArray;
begin
  tmp := SplitString(Copy(
    _str,
    pos(':', _str) + 2,
    Length(_str)
    ), ';');
  
  { Extract game id }
  game_id := StrToInt(Copy(_str, pos(' ', _str), pos(':', _str) - pos(' ', _str)));

  for ix := 0 to Length(tmp) - 1 do
  begin
    tmp_2 := SplitString(Trim(tmp[ix]), ',');
    for ix_2 := 0 to Length(tmp_2) - 1 do
    begin
      tmp_3 := SplitString(Trim(tmp_2[ix_2]), ' ');
      n := StrToInt(tmp_3[0]);
      if (tmp_3[1] = 'blue') and (n > BLUES) then exit;
      if (tmp_3[1] = 'red') and (n > REDS) then exit;
      if (tmp_3[1] = 'green') and (n > GREENS) then exit;
    end;
  end;

  process := game_id;
end;

var
  in_fl: TextFile;
  inval: String;
  out: Integer;
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
