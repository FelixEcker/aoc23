{$mode fpc}
program aoc1;

{$H+}

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
      if first > 10 then
        first := Byte(_str[ix]) - Byte('0')
      else
        last := Byte(_str[ix]);

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
