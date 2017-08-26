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

uint64_t main_time = 0;
unsigned int exit_delay = 0;
unsigned int exit_code = 0;

uint64_t max_time = 0;

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

    // init top verilog instance
    Vminion_soc* top = new Vminion_soc;
    top->rstn = 0;

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

    while(!Verilated::gotFinish() && (!exit_code || exit_delay > 1) &&
          (max_time == 0 || main_time < max_time) &&
          (exit_delay != 1)
          ) {

      if(main_time > 133) {
        top->rstn = 1;
      }
      if((main_time % 10) == 0) { // 10ns clk
        top->clk_in1 = 1;
      }
      if((main_time % 10) == 5) {
        top->clk_in1 = 0;
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
