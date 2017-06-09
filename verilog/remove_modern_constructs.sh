#!/bin/bash
for i in $*; do
    sed -e 's=always_ff=always=' -e 's=always_comb=always @*=' -e 's=unique case=case=' -e 's=input[\ ]*logic=input wire=' <$i >$i.tmp
    mv -f $i.tmp $i
done
