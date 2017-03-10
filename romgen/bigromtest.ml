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
  let linbuf = input_line infile in
  let addr = ref (Scanf.sscanf linbuf "@%X" (fun x -> x)) in
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
  let databuf = cnv Sys.argv.(2) in
  let romfile1 = open_out Sys.argv.(3) in
  let romfile2 = open_out Sys.argv.(4) in
  let codetot = Bigromgen.romgen romfile1 32 "progmem" false false codebuf [||] in
  close_out romfile1;
  let datatot = Bigromgen.romgen romfile2 32 "datamem" false false databuf [||] in
  close_out romfile2;
  printf "Code Roms generated = %d\n" codetot;
  printf "Data Rams generated = %d\n" datatot;
  let romfile3 = open_out Sys.argv.(5) in
  let last = ref 0 in Array.iteri (fun ix itm -> if sign_big_int itm <> 0 then last := ix) codebuf;
  Array.iteri (fun ix itm -> if !full || ix <= !last then Printf.fprintf romfile3 "%.8X\n" (int_of_big_int itm)) codebuf;
  close_out romfile3;
  let romfile4 = open_out Sys.argv.(6) in
  let last = ref 0 in Array.iteri (fun ix itm -> if sign_big_int itm <> 0 then last := ix) databuf;
  Array.iteri (fun ix itm -> if !full || ix <= !last then Printf.fprintf romfile4 "%.8X\n" (int_of_big_int itm)) databuf;
  close_out romfile4
