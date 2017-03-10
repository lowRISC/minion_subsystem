#include "bbl.h"
#include "vm.h"
#include "mtrap.h"
#include "driver/ff.h"
#include "driver/uart.h"

uintptr_t mem_size;
uint32_t num_harts = 1;
uint32_t num_harts_booted = 1;

static void mstatus_init()
{
  if (!supports_extension('S'))
    panic("supervisor support is required");

  uintptr_t ms = 0;
  ms = INSERT_FIELD(ms, MSTATUS_PRV, PRV_M);
  ms = INSERT_FIELD(ms, MSTATUS_PRV1, PRV_S);
  ms = INSERT_FIELD(ms, MSTATUS_PRV2, PRV_U);
  ms = INSERT_FIELD(ms, MSTATUS_IE2, 1);
  ms = INSERT_FIELD(ms, MSTATUS_VM, VM_CHOICE);
  ms = INSERT_FIELD(ms, MSTATUS_FS, 3);
  ms = INSERT_FIELD(ms, MSTATUS_XS, 3);
  write_csr(mstatus, ms);
  ms = read_csr(mstatus);

  if (EXTRACT_FIELD(ms, MSTATUS_VM) != VM_CHOICE)
    have_vm = 0;

  write_csr(mtimecmp, 0);
  clear_csr(mip, MIP_MSIP);
  set_csr(mie, MIP_MSIP);
}

static void memory_init()
{
  // set memory size
  uintptr_t mem_mb = 128;       /* 128 MB DDR2 for NEXYS4-DDR*/
  mem_size = mem_mb << 20;
  if ((mem_size >> 20) < mem_mb)
    mem_size = (typeof(mem_size))-1 & -RISCV_PGSIZE;

  if (mem_size == 0)
    panic("could not determine memory capacity");

  if (num_harts == 0)
    panic("could not determine number of harts");
}

static void fp_init()
{
  kassert(read_csr(mstatus) & MSTATUS_FS);

#ifdef __riscv_hard_float
  if (!supports_extension('D'))
    panic("FPU not found; recompile pk with -msoft-float");
  for (int i = 0; i < 32; i++)
    init_fp_reg(i);
  write_csr(fcsr, 0);
#else
  if (supports_extension('D'))
    panic("FPU unexpectedly found; recompile pk without -msoft-float");
#endif
}

static void hls_init(uint32_t hart_id)
{
  memset(HLS(), 0, sizeof(*HLS()));
  HLS()->hart_id = hart_id;
}

static void init_first_hart()
{
  file_init();
  memory_init();
  vm_init();
  boot_loader();
}

static void init_other_hart()
{
  // wait until virtual memory is enabled
  while (root_page_table == NULL)
    asm volatile ("" ::: "memory");
  mb();
  write_csr(sptbr, root_page_table);

  // then make sure we're in bounds
  if (HLS()->hart_id >= num_harts) {
    while (1)
      wfi();
  }

  boot_other_hart();
}

FATFS FatFs;   /* Work area (file system object) for logical drive */

void machine_init(uint32_t hart_id)
{
  uart_init();
  /* Register work area to the default drive */
  f_mount(&FatFs, "", 0);

  hls_init(hart_id);
  mstatus_init();
  fp_init();

  if (hart_id == 0) {
    init_first_hart();
  } else
    init_other_hart();
}
