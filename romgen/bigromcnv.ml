open Printf
open Big_int

let stem str = if String.contains str '/' then
    let base = String.rindex str '/' in
    String.sub str (base+1) (String.length str - base - 1) else
    str

let rbin (str:string) =
let value = ref zero_big_int in
for idx = 0 to String.length(str)-1 do let ch = Char.lowercase(str.[idx]) in
match ch with
| ' ' -> ()
| '_' -> ()
| '0' -> value := Big_int.shift_left_big_int !value 1
| '1' -> value := Big_int.succ_big_int (Big_int.shift_left_big_int !value 1)
| _ -> failwith (String.sub str idx (String.length str - idx))
done;
!value

let rec wbin width n =
  (if width > 1 then wbin (width-1) (Big_int.shift_right_big_int n 1) else "")^String.make 1 ("01".[Big_int.int_of_big_int (Big_int.extract_big_int n 0 1)])

let rec whex width n =
  (if width > 4 then whex (width-4) (Big_int.shift_right_big_int n 4) else "")^String.make 1 ("0123456789ABCDEF".[Big_int.int_of_big_int (Big_int.extract_big_int n 0 4)])

let rec wraw bin width n =
  let lsbyte = Big_int.int_of_big_int (Big_int.extract_big_int n 0 4) in
  output_byte bin lsbyte;
  if width > 8 then wraw bin (width-8) (Big_int.shift_right_big_int n 8)

let main str =
  let (nam,minimize) = try Sys.getenv "PROGMEM",false with _ -> "progmem",false in
  let infile = open_in str in
  let lst = ref [] in (try 
    while true do lst := input_line infile :: !lst done
  with End_of_file ->
    close_in infile);
  let ids = ref [] in (try 
    let idnam = str^".ident" in
    let idfile = open_in idnam in
    (try while true do ids := input_line idfile :: !ids done
    with End_of_file -> close_in idfile)
      with _ -> print_endline "No id file");
  let idsarr = Array.of_list (List.rev !ids) in
  let bigbuf = Array.of_list (List.map rbin (List.rev !lst)) in
  let width = String.length (List.hd !lst) in
  print_endline ("width = "^string_of_int width^", id list length = "^string_of_int (Array.length idsarr));
  let logfile = stem str^".log" in
  let log = open_out logfile in
  Array.iter (fun arg -> output_string log (wbin width arg^"\n")) bigbuf;
  close_out log;
  let hexfile = stem str^"_data2mem.mem" in
  let hex = open_out hexfile in
  Array.iter (fun arg -> output_string hex (whex width arg^"\n")) bigbuf;
  close_out hex;
  let binfile = stem str^"_data2mem.bin" in
  let bin = open_out binfile in
  Array.iter (wraw bin width) bigbuf;
  close_out bin;
  let outfile = try Sys.getenv "OUTFILE" with _ -> stem str^".v" in
  let out = open_out outfile in
  let romtot = Bigromgen.romgen out width nam false minimize bigbuf idsarr in
  close_out out;
  printf "Rom %s, width = %d:0, length = %d, total instances = %d\n" outfile (width-1) (Array.length bigbuf) romtot

let _ = main Sys.argv.(1)
