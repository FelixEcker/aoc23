{$mode fpc}
program aoc3;

uses SysUtils, StrUtils, Types;

{$H+}

var
  in_fl: TextFile;
  inval: String;
  map: String;
  part_positions: array of array of Int64;

function is_digit(const b: Byte): Boolean;
begin
  is_digit := (b <= Byte('9')) and (b >= Byte('0'));
end;

function check_duplicate(const x: Int64; const y: Int64): Boolean;
var
  x
begin
end;

procedure save_part_pos(const x: Int64; const y: Int64);
begin
  SetLength(part_positions, Length(part_positions) + 1);
  part_positions[HIGH(part_positions)] := [x, y];
end;

function find_part(const rows: TStringDynArray; const partnum: Int64; const ox: Int64; const oy: Int64; const digits: Integer): Int64;
var
  x, y: Int64;
begin
  for y := oy - 1 to oy + 1 do
  begin
    if y < 0 then continue;
    if y >= Length(rows) then break;
    for x := ox - 1 to ox + digits do
    begin
      if x < 0 then continue;
      if x >= Length(rows[y]) then break;
      if (rows[y][x] <> '.') and not is_digit(Byte(rows[y][x])) then
      begin
        save_part_pos(x, y);
        exit(partnum);
      end;
    end;
  end;
  exit;
end;

function solve(const map: String): Int64;
var
  rows: TStringDynArray;
  x, y, curnum: Int64;
  num_start: Int64;
  parse_num: Boolean;
begin
  solve := 0;
  rows := SplitString(map, sLineBreak);
  for y := 0 to Length(rows) - 1 do
  begin
    for x := 1 to Length(rows[y]) do
    begin
      if not is_digit(Byte(rows[y][x])) or (x = Length(rows[y])) then
      begin
        if parse_num then
        begin
          parse_num := False;
          curnum := StrToInt(Copy(rows[y], num_start, x - num_start));
          solve := solve + find_part(rows, curnum, num_start, y, x - num_start);
        end;
        continue;
      end;

      if not parse_num then 
      begin
        parse_num := True;
        num_start := x;
      end;
    end;
  end;
end;

begin
  Assign(in_fl, 'input');
  ReSet(in_fl);

  map := '';
  while not eof(in_fl) do
  begin
    readln(in_fl, inval);
    map := map + inval + sLineBreak;
  end;
  Close(in_fl);
  writeln(solve(map));
end.
