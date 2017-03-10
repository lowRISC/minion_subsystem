open Printf
open Big_int

let rbin (str:string) =
let value = ref zero_big_int in
for idx = 0 to String.length(str)-1 do let ch = Char.lowercase(str.[idx]) in
match ch with
| ' ' -> ()
| '_' -> ()
| '0'..'9' -> value := add_big_int (shift_left_big_int !value 4) (big_int_of_int (int_of_char ch - int_of_char '0'));
| 'a'..'f' -> value := add_big_int (shift_left_big_int !value 4) (big_int_of_int (int_of_char ch - int_of_char 'a' + 10));
| 'A'..'F' -> value := add_big_int (shift_left_big_int !value 4) (big_int_of_int (int_of_char ch - int_of_char 'A' + 10));
| _ -> failwith (String.sub str idx (String.length str - idx))
done;
!value

let cnv inf =
  Printexc.record_backtrace true;
  let infile = open_in inf
  and bigbuf = Array.make (1 lsl 16) (zero_big_int) in
  let addr = ref 0 in
  print_endline ("Start = "^string_of_int !addr);
  (try while true do
    let linbuf = ref (input_line infile ^ " ") and lst = ref [] in
    while String.contains !linbuf ' ' do
      let spc = String.index !linbuf ' ' in
      let sub = String.sub !linbuf 0 spc in
      let itm = rbin sub in
      let skip = ref spc in
      while !skip < String.length !linbuf && (!linbuf.[!skip] = ' ' || !linbuf.[!skip] = '\r') do incr skip done;
      linbuf := String.sub !linbuf !skip (String.length !linbuf - !skip);
      lst := itm :: !lst
    done;
    let rlst = List.rev !lst in
    List.iter (fun data ->
      bigbuf.(!addr) <- data;
      incr addr;
    ) rlst;
    done;
  with End_of_file -> ());
  for i = 0 to !addr do
      bigbuf.(i) <- if (i*4+3 < !addr) then
          add_big_int (add_big_int (shift_left_big_int bigbuf.(i*4+3) 24)
                               (shift_left_big_int bigbuf.(i*4+2) 16))
                               (add_big_int (shift_left_big_int bigbuf.(i*4+1) 8) 
					  (shift_left_big_int bigbuf.(i*4+0) 0)) else zero_big_int;
(*
 Printf.printf "%X: %LX\n" i bigbuf.(i)
 *)
done;
  Array.sub bigbuf 0 (1 lsl 14)

let full = ref true

let _ =
  let codebuf = cnv Sys.argv.(1) in
  let romfile1 = open_out Sys.argv.(2) in
  let codetot = Bigromgen.romgen romfile1 128 "progmem" false false codebuf [||] in
  close_out romfile1;
  printf "Code Roms generated = %d\n" codetot
