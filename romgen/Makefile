.SUFFIXES: .mem .v

all: romgen bigromgen bigromtest romgen.byte bigromgen.byte bigromtest.byte

romgen: romgen.ml romtest.ml
	ocamlopt romgen.ml romtest.ml -o $@ -g

bigromgen: bigromgen.ml bigromcnv.ml
	ocamlopt nums.cmxa bigromgen.ml bigromcnv.ml -o $@ -g

bigromtest: bigromgen.ml bigromtest.ml
	ocamlopt nums.cmxa bigromgen.ml bigromtest.ml -o $@ -g

bigromwide: bigromgen.ml bigromwide.ml
	ocamlopt nums.cmxa bigromgen.ml bigromwide.ml -o $@ -g

romgen.byte: romgen.ml romtest.ml
	ocamlc -g romgen.ml romtest.ml -o $@

bigromgen.byte: bigromgen.ml bigromcnv.ml
	ocamlc -g nums.cma bigromgen.ml bigromcnv.ml -o $@

bigromtest.byte: bigromgen.ml bigromtest.ml
	ocamlc -g nums.cma bigromgen.ml bigromtest.ml -o $@

bigromwide.byte: bigromgen.ml bigromwide.ml
	ocamlc -g nums.cma bigromgen.ml bigromwide.ml -o $@
