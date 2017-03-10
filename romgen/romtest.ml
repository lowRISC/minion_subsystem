open Printf

let cnv inf =
  Printexc.record_backtrace true;
  let infile = open_in inf
  and bigbuf = Array.make (1 lsl 16) (Int64.zero) in
  let linbuf = input_line infile in
  let addr = ref (Scanf.sscanf linbuf "@%X" (fun x -> x)) in
  print_endline ("Start = "^string_of_int !addr);
  (try while true do
    let linbuf = ref (input_line infile ^ " ") and lst = ref [] in
    while String.contains !linbuf ' ' do
      let spc = String.index !linbuf ' ' in
      let sub = String.sub !linbuf 0 spc in
      let itm = Scanf.sscanf sub "%X " (fun data -> data) in
      let skip = ref spc in
      while !skip < String.length !linbuf && (!linbuf.[!skip] = ' ' || !linbuf.[!skip] = '\r') do incr skip done;
      linbuf := String.sub !linbuf !skip (String.length !linbuf - !skip);
      lst := itm :: !lst
    done;
    let rlst = List.rev !lst in
    printf "Addr %.4X:" !addr;
    List.iter (fun data ->
      printf " %.2X" data;
      bigbuf.(!addr) <- Int64.of_int data;
      incr addr;
    ) rlst;
    print_newline();
    done;
  with End_of_file -> ());
  for i = 0 to !addr do
      bigbuf.(i) <- if (i*4+3 < !addr) then
          Int64.add (Int64.add (Int64.shift_left bigbuf.(i*4+3) 24)
                               (Int64.shift_left bigbuf.(i*4+2) 16))
                               (Int64.add (Int64.shift_left bigbuf.(i*4+1) 8) 
					  (Int64.shift_left bigbuf.(i*4+0) 0)) else 0L;
(*
 Printf.printf "%X: %LX\n" i bigbuf.(i)
 *)
done;
  bigbuf

let _ =
  let codebuf = cnv Sys.argv.(1) in
  let databuf = cnv Sys.argv.(2) in
  let romfile1 = open_out Sys.argv.(3) in
  let romfile2 = open_out Sys.argv.(4) in
  let codetot = Romgen.romgen romfile1 32 "progmem" 0 false false false codebuf in
  let datatot = Romgen.romgen romfile2 32 "datamem" 0 false false false databuf in
  printf "Code Roms generated = %d\n" codetot;
  printf "Data Rams generated = %d\n" datatot
