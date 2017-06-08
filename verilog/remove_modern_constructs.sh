for i in $*; do
    git checkout $i
    tr '\012@' '@\012' < $i | sed -e 's=@import=// import=' -e 's=\(@module[^;]*;\)=\1 `include "riscv_defines.sv"=' | tr '@\012' '\012@' | sed -e 's=always_ff=always=' -e 's=always_comb=always @*=' -e 's=unique case=case=' >$i.tmp
    mv -f $i.tmp $i
done