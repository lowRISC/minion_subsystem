#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdlib.h>
#include "minion_lib.h"

#include "bbl.h"
#include "vm.h"
#include "driver/diskio.h"

int sstatus = CSR_SSTATUS;
int mepc = CSR_MEPC;
int sptbr = CSR_SPTBR;
int csr[512];
FATFS FatFs;   /* Work area (file system object) for logical drive */

uintptr_t mem_size = 2 << 20;
uint32_t num_harts = 0;

void set_csr(int mip, int bit)
{
  if (mip > sizeof(csr)/sizeof(*csr)) abort();
  csr[mip] |= bit;
}

void swap_csr(int mip, int val)
{
  if (mip > sizeof(csr)/sizeof(*csr)) abort();
}

int clear_csr(int mip, int val)
{
  if (mip > sizeof(csr)/sizeof(*csr)) abort();
  csr[mip] &= ~val;
}

int _write_csr(int mip, int data)
{
  if (mip > sizeof(csr)/sizeof(*csr)) abort();
  csr[mip] = data;
}

int read_csr(int addr)
{
  abort();
}

void mb(void)
{
  abort();
}

void eret(void)
{
  abort();
}

void flush_tlb(void)
{

}

void sd_disable() {

}

uint8_t sd_send(uint8_t dat) {
}

void sd_send_multi(const uint8_t* dat, uint8_t n) {
}

void sd_recv_multi(uint8_t* dat, uint8_t n) {
}

void sd_select_slave(uint8_t id) {
}

void sd_deselect_slave(uint8_t id) {
}

void die(int code)
{
  exit(code);
}

int main(void)
{
  //  uart_init();
  //  vm_init();
  f_mount(&FatFs, "", 0);
  boot_loader();
}

int stack()
{

}

/*-----------------------------------------------------------------------*/
/* Transmit/Receive data from/to MMC via SPI  (Platform dependent)       */
/*-----------------------------------------------------------------------*/

/* Exchange a byte */
static
uint8_t xchg_spi (                /* Returns received data */
                  uint8_t dat     /* Data to be sent */
                                  )
{
  return sd_send(dat);
}

/* Send a data block fast */
static
void xmit_sd_multi (
                     const uint8_t *p,  /* Data block to be sent */
                     uint32_t cnt       /* Size of data block (must be multiple of 2) */
                     )
{
  int i = 0;
  for(i=0; i<cnt; i=i+16) {
    if(cnt >= i+16)
      sd_send_multi(p+i, 16);
    else
      sd_send_multi(p+i, cnt-i);
  }
}

/* Receive a data block fast */
static
void rcvr_sd_multi (
                     uint8_t *p,    /* Data buffer */
                     uint32_t cnt   /* Size of data block (must be multiple of 2) */
                     )
{
  int i = 0;
  for(i=0; i<cnt; i=i+16) {
    if(cnt >= i+16)
      sd_recv_multi(p+i, 16);
    else
      sd_recv_multi(p+i, cnt-i);
  }
}

/*-----------------------------------------------------------------------*/
/* Wait for card ready                                                   */
/*-----------------------------------------------------------------------*/

int wait_ready (                /* 1:Ready, 0:Timeout */
                uint32_t wt     /* Timeout [ms] */
                                )
{
  uint8_t d;
  uint32_t timeout = wt*5000;

  do {
    d = xchg_spi(0xFF);
    timeout--;
  } while (d != 0xFF && timeout);

  return (d == 0xFF) ? 1 : 0;
}



/*-----------------------------------------------------------------------*/
/* Deselect the card and release SPI bus                                 */
/*-----------------------------------------------------------------------*/

void sd_deselect (void)
{
  sd_deselect_slave(0);
}

/*-----------------------------------------------------------------------*/
/* Select the card and wait for ready                                    */
/*-----------------------------------------------------------------------*/

int sd_select (void)   /* 1:Successful, 0:Timeout */
{
  sd_select_slave(0);
  if (wait_ready(500)) return 1;  /* Wait for card ready */

  sd_deselect();
  return 0;   /* Timeout */
}

/*-----------------------------------------------------------------------*/
/* Send a data packet to MMC                                             */
/*-----------------------------------------------------------------------*/

int xmit_datablock (
                    const uint8_t *buff,   /* 512 byte data block to be transmitted */
                    uint8_t token          /* Data/Stop token */
                    )
{
  uint8_t resp;


  if (!wait_ready(500)) return 0;

  xchg_spi(token);                    /* Xmit data token */
  if (token != 0xFD) {    /* Is data token */
    xmit_sd_multi(buff, 512);      /* Xmit the data block to the MMC */
    while(xchg_spi(0xFF) == 0x00);  /* CRC (Dummy) */
    while(xchg_spi(0xFF) == 0x00);  /* CRC (Dummy) */
    resp = xchg_spi(0xFF);          /* Reveive data response */
    if ((resp & 0x1F) != 0x05)      /* If not accepted, return with error */
      return 0;
  }

  wait_ready(500);
  return 1;
}

void abort()
{
  for(;;);
}

int echo = 0;

uintptr_t __do_mmap(uintptr_t addr, size_t length, int prot, int flags, file_t* f, off_t offset)
{

}

void populate_mapping(const void* start, size_t size, int prot)
{

}

int __valid_user_range(uintptr_t vaddr, size_t len)
{
  return 1;
}

void run_loaded_program()
{

}
