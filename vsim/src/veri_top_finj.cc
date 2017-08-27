#include "Vminion_soc.h"
#include "verilated.h"
#ifdef VM_TRACE
 #include <verilated_vcd_c.h>
#endif
#include <string>
#include <vector>
#include <iostream>
#include <signal.h>

using std::string;
using std::vector;

#define MAX_FTIME 100000
#define MIN_FTIME    100

uint64_t main_time = 0;
unsigned int exit_delay = 0;
unsigned int exit_code = 0;

uint64_t max_time = 0;

uint64_t randFaultTime = 0;
int f_flag = 0;

double sc_time_stamp() { return main_time; }

void exit_function(int signal) {
   exit_delay = 100;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    signal(SIGINT, exit_function);

    // handle arguements
    bool vcd_enable = false;
    string vcd_name = "verilated.vcd";

    vector<string> args(argv + 1, argv + argc);
    for(vector<string>::iterator it = args.begin(); it != args.end(); ++it) {
      if(*it == "+vcd") {
        vcd_enable = true;
      }
      else if(it->find("+max-cycles=") == 0) {
        max_time = 10 * strtoul(it->substr(strlen("+max-cycles=")).c_str(), NULL, 10);
      }
      else if(it->find("+vcd_name=") == 0) {
        vcd_name = it->substr(strlen("+vcd_name="));
      }
    }

    cout<<"Starting simulation"<<endl;

    // init top verilog instance
    Vminion_soc* top = new Vminion_soc;
    top->rstn = 0;

    top->finj_fault = 0;
    top->finj_index = 0;

  // VCD dump
  #ifdef VM_TRACE
    VerilatedVcdC* vcd = new VerilatedVcdC;
    if(vcd_enable) {
      Verilated::traceEverOn(true);
      top->trace(vcd, 99);
      vcd->open(vcd_name.c_str());
    }
  #endif

    top->eval();


    randFaultTime = rand()%(MAX_FTIME-MIN_FTIME + 1) + MIN_FTIME;
    cout<<"Next fault in "<<randFaultTime<<endl;

    while(!Verilated::gotFinish() && (!exit_code || exit_delay > 1) &&
          (max_time == 0 || main_time < max_time) &&
          (exit_delay != 1)
          ) {

      if(main_time > 133) {
        top->rstn = 1;
      }
      if((main_time % 10) == 0) { // 10ns clk
        top->msoc_clk = 1;
        if(f_flag == 2) {
          top->finj_fault = 1;
          f_flag = 1;
        } else if(f_flag == 1) {
          top->finj_fault = 0;
          top->finj_index = 0;
          f_flag = 0;
        }
      }
      if((main_time % 10) == 5) {
        top->msoc_clk = 0;
      }

      top->eval();

  #ifdef VM_TRACE
      if(vcd_enable) vcd->dump(main_time);       // do the dump
  #endif

      if(main_time < 140)
        main_time++;
      else
        main_time += 5;

      if((main_time % 10) == 0 && exit_delay > 1)
        exit_delay--;             // postponed delay to allow VCD recording

      if((main_time % 10000000) == 0)
        std::cerr << "simulation has run for " << main_time/10 << " cycles..." << std::endl;

      if(randFaultTime < main_time) {
        signed int findex;

        randFaultTime = rand()%(MAX_FTIME-MIN_FTIME + 1) + MIN_FTIME;
        randFaultTime += main_time;

        cout<<"Fault injected? just give index ";
        cout<<"-1 for no fault injection for this cycle";
        cout<<"-2 for no fault injection anymore";
        cout<<"-3 for exit";
        cin>>findex;
        if(findex == -1) {
          cout<<"No fault injection for this cycle"<<endl;
        } else if (findex == -2) {
          randFaultTime = 10000000;
          cout<<"No fault injection anymore"<<endl;
        } else if (findex == -3) {
          exit_delay = 100;
          cout<<"Exiting"<<endl;
        } else {
          int fwire;
          //printf("Wire value %x\n",top->minion_soc__DOT__RISCV_CORE__DOT__cls_assist__DOT__core_data_req);
          //cout<<"Wire value "<<top->minion_soc->RISCV_CORE->cls_assist->data_req_ms<<endl;
          //cout<<"Wire please: ";
          //cin>>fwire;
          top->finj_index = findex; // (findex << 5 ) | fwire;
          f_flag = 2;
          cout<<"Fault injection at index "<<findex<<endl;
        }

        cout<<"Next fault in "<<randFaultTime<<endl;

      }
    }

    top->final();
  #ifdef TRACE_VCD
    if(vcd_enable) vcd->close();
  #endif

    delete top;

    if(max_time == 0 || main_time < max_time)
      return exit_code;
    else
      return -1;                  // timeout
}
