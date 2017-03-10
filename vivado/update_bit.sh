python bmm_gen.py msoc.log msoc.bmm 32 131072
data2mem -bm msoc.bmm -bd ../software/bootstrap/code.mem0 -bt minion_top.runs/impl_1/eth_top.bit -o b minion_top.runs/impl_1/eth_top2.bit
