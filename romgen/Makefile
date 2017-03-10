.SUFFIXES: .mem .v

all: romgen bigromgen bigromtest

romgen: romgen.ml romtest.ml
	ocamlopt romgen.ml romtest.ml -o $@ -g

bigromgen: bigromgen.ml bigromcnv.ml
	ocamlopt nums.cmxa bigromgen.ml bigromcnv.ml -o $@ -g

bigromtest: bigromgen.ml bigromtest.ml
	ocamlopt nums.cmxa bigromgen.ml bigromtest.ml -o $@ -g

bigromwide: bigromgen.ml bigromwide.ml
	ocamlopt nums.cmxa bigromgen.ml bigromwide.ml -o $@ -g
