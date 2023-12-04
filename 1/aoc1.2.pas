{$mode objfpc}
program aoc1.part2;

{$H+}

{ dümmste kack lösung die ich jemals für irgendwas geschrieben habe geb mir einfach sternchen }

function parse_str(_str: String; const offs: UInt64; const fallback: Byte): Byte;
var
  ix: UInt64;
begin
  if (Length(_str) - offs) < 0 then
    exit(fallback);

  parse_str := fallback;
  _str := Copy(_str, offs, Length(_str) - offs + 1);
  for ix := Length(_str) downto 3 do
  begin
    case Copy(_str, 1, ix) of
      'one': exit(1);
      'two': exit(2);
      'three': exit(3);
      'four': exit(4);
      'five': exit(5);
      'six': exit(6);
      'seven': exit(7);
      'eight': exit(8);
      'nine': exit(9);
      'zero': exit(0);
    end;
  end;
end;

function process(_str: String): UInt64;
var
  ix: UInt64;
  first, last: Byte;
begin
  first := 255;
  last := 0;
  for ix := 1 to Length(_str) do
    if (Byte(_str[ix]) >= Byte('0'))
    and (Byte(_str[ix]) <= Byte('9')) then
    begin
      if first > 10 then
        first := Byte(_str[ix]) - Byte('0')
      else
        last := Byte(_str[ix])
    end else
    begin
      if first > 10 then
        first := parse_str(_str, ix, first)
      else
        last := parse_str(_str, ix, last - Byte('0')) + Byte('0');
    end;

  if last = 0 then
    last := first
  else
    last := last - Byte('0');
  
  process := first * 10 + last;
end;

var
  fl_in: TextFile;
  inval: String;
  out: UInt64;
begin
  Assign(fl_in, 'input');
  ReSet(fl_in);

  out := 0;
  while not eof(fl_in) do
  begin
    readln(fl_in, inval);
    out := out + process(inval);
  end;

  Close(fl_in);
  writeln(out);
end.
