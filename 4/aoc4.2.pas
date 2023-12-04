{$mode fpc}
program aoc4.part2;

{$H+}

uses SysUtils, StrUtils, Types;

type
  TInt64DynArray = array of Int64;

  TCard = record
    winning: TInt64DynArray;
    hand: TInt64DynArray;
    copies: Int64;
  end;

  TCardDynArray = array of TCard;

function StrArrToIntArr(const inarr: TStringDynArray): TInt64DynArray;
var
  wix, ix: Int64;
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

procedure process(_str: String; var cards: TCardDynArray);
var
  tmp, swinning, shand: TStringDynArray;
begin
  tmp := SplitString(Copy(
      _str,
      pos(':', _str) + 1,
      Length(_str)
    )
    , '|');

  swinning := SplitString(Trim(tmp[0]), ' ');
  shand := SplitString(Trim(tmp[1]), ' ');

  SetLength(cards, Length(cards) + 1);
  cards[HIGH(cards)].winning := StrArrToIntArr(swinning);
  cards[HIGH(cards)].hand := StrArrToIntArr(shand);
  cards[HIGH(cards)].copies := 1;
end;

procedure apply_winnings(var cards: TCardDynArray; const org: Int64; const amount: Int64);
var
  ix: Int64;
begin
  for ix := org + 1 to org + amount do
  begin
    cards[ix].copies := cards[ix].copies + 1;
  end;
end;

procedure play(var cards: TCardDynArray);
var
  cix, ix, ix2: Int64;
  matches, plays: Int64;
begin
  for cix := 0 to Length(cards) - 1 do
  begin
    plays := 0;
    matches := 0;
    for ix := 0 to Length(cards[cix].hand) - 1 do
    begin
      for ix2 := 0 to Length(cards[cix].winning) - 1 do
      begin
        if cards[cix].winning[ix2] = cards[cix].hand[ix] then
          matches := matches + 1;
      end;
    end;


    repeat
      plays := plays + 1;
      if matches > 0 then
        apply_winnings(cards, cix, matches);
    until plays = cards[cix].copies;
  end;
end;

var
  in_fl: TextFile;
  inval: String;
  out: Int64;
  cards: TCardDynArray;
  card: TCard;
begin
  Assign(in_fl, 'input');
  ReSet(in_fl);

  SetLength(cards, 0);

  while not eof(in_fl) do
  begin
    readln(in_fl, inval);
    process(inval, cards);
  end;

  Close(in_fl);

  play(cards);

  out := 0;
  for card in cards do
    out := out + card.copies;

  writeln(out);
end.
