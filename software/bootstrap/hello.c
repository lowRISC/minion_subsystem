#include <stdint.h>

/* Register offsets for the EmacLite Core */
#define XEL_TXBUFF_OFFSET       0x0             /* Transmit Buffer */
#define XEL_MDIOADDR_OFFSET     0x07E4          /* MDIO Address Register */
#define XEL_MDIOWR_OFFSET       0x07E8          /* MDIO Write Data Register */
#define XEL_MDIORD_OFFSET       0x07EC          /* MDIO Read Data Register */
#define XEL_MDIOCTRL_OFFSET     0x07F0          /* MDIO Control Register */
#define XEL_GIER_OFFSET         0x07F8          /* GIE Register */
#define XEL_TSR_OFFSET          0x07FC          /* Tx status */
#define XEL_TPLR_OFFSET         0x07F4          /* Tx packet length */

#define XEL_RXBUFF_OFFSET       0x1000          /* Receive Buffer */
#define XEL_RPLR_OFFSET         0x100C          /* Rx packet length */
#define XEL_RSR_OFFSET          0x17FC          /* Rx status */

#define XEL_BUFFER_OFFSET       0x0800          /* Next Tx/Rx buffer's offset */

/* MDIO Address Register Bit Masks */
#define XEL_MDIOADDR_REGADR_MASK  0x0000001F    /* Register Address */
#define XEL_MDIOADDR_PHYADR_MASK  0x000003E0    /* PHY Address */
#define XEL_MDIOADDR_PHYADR_SHIFT 5
#define XEL_MDIOADDR_OP_MASK      0x00000400    /* RD/WR Operation */

/* MDIO Write Data Register Bit Masks */
#define XEL_MDIOWR_WRDATA_MASK    0x0000FFFF    /* Data to be Written */

/* MDIO Read Data Register Bit Masks */
#define XEL_MDIORD_RDDATA_MASK    0x0000FFFF    /* Data to be Read */

/* MDIO Control Register Bit Masks */
#define XEL_MDIOCTRL_MDIOSTS_MASK 0x00000001    /* MDIO Status Mask */
#define XEL_MDIOCTRL_MDIOEN_MASK  0x00000008    /* MDIO Enable */

/* Global Interrupt Enable Register (GIER) Bit Masks */
#define XEL_GIER_GIE_MASK        0x80000000      /* Global Enable */

/* Transmit Status Register (TSR) Bit Masks */
#define XEL_TSR_XMIT_BUSY_MASK   0x00000001     /* Tx complete */
#define XEL_TSR_PROGRAM_MASK     0x00000002     /* Program the MAC address */
#define XEL_TSR_XMIT_IE_MASK     0x00000008     /* Tx interrupt enable bit */
#define XEL_TSR_XMIT_ACTIVE_MASK 0x80000000     /* Buffer is active, SW bit
                                                 * only. This is not documented
                                                 * in the HW spec */

/* Define for programming the MAC address into the EmacLite */
#define XEL_TSR_PROG_MAC_ADDR   (XEL_TSR_XMIT_BUSY_MASK | XEL_TSR_PROGRAM_MASK)

/* Define for programming the MAC address into the EmacLite */
#define XEL_TSR_PROG_MAC_ADDR   (XEL_TSR_XMIT_BUSY_MASK | XEL_TSR_PROGRAM_MASK)

/* Receive Status Register (RSR) */
#define XEL_RSR_RECV_DONE_MASK  0x00000001      /* Rx complete */
#define XEL_RSR_RECV_IE_MASK    0x00000008      /* Rx interrupt enable bit */

/* Transmit Packet Length Register (TPLR) */
#define XEL_TPLR_LENGTH_MASK    0x0000FFFF      /* Tx packet length */

/* Receive Packet Length Register (RPLR) */
#define XEL_RPLR_LENGTH_MASK    0x0000FFFF      /* Rx packet length */

#define XEL_HEADER_OFFSET       12              /* Offset to length field */
#define XEL_HEADER_SHIFT        16              /* Shift value for length */

/* General Ethernet Definitions */
#define XEL_ARP_PACKET_SIZE             28      /* Max ARP packet size */
#define XEL_HEADER_IP_LENGTH_OFFSET     16      /* IP Length Offset */

void exit (int i) {
  while (1);
}

void illegal_insn_handler_c(void)
{
  for(;;);
}

void int_time_cmp (void)
{

}

void int_main(void)
{
  // select correct interrupt
  // read cause register to get pending interrupt
  // execute ISR.
}

void uart_set_cfg(int parity, uint16_t clk_counter)
{

}

void __libc_init_array(void)
{

}

enum edcl_mode {
  edcl_mode_unknown,
  edcl_mode_read,
  edcl_mode_write,
  edcl_mode_block_read,
  edcl_mode_bootstrap,
  edcl_max=256};

typedef long size_t;

static void *memcpy(void *__restrict__ dst, const void * __restrict__ src, size_t N) {
  char * __restrict__ dst_ = (char * __restrict__ )dst;
  const char * __restrict__ src_ = (char * __restrict__ )src;
  for (size_t i = 0; i != N; ++i)
    dst_[i] = src_[i];
  return dst;
}

static void myputchar(const char c) {
#ifdef REAL_UART
      // wait until there is space in the fifo
      while( (*(volatile unsigned int*)(3<<20) & 0x400) != 0);
#endif
      // load FIFO
      *(volatile unsigned int*)(2<<20) = c;
}

static void myputs(const char *str)
{
  while (*str)
    {
      myputchar(*str++);
    }
}

static int read_code_data(int addr)
{
  return *(volatile unsigned char *)addr;
}

static size_t read_code_data8(int addr)
{
return read_code_data(addr) |
  (read_code_data(addr+1) << 8) |
  (read_code_data(addr+2) << 16) |
  (read_code_data(addr+3) << 24);
}

static void write_code_data32(int addr, size_t data)
{
  *(volatile size_t *)addr = data;
}

static size_t read_code_data32(int addr)
{
  return *(volatile size_t *)addr;
}

static unsigned int my_stat(int sel)
{
  volatile unsigned int * const my_stat_ = (volatile unsigned int*)(5<<20);
  unsigned int rslt = my_stat_[sel];
  return rslt;
}

void myputhex(unsigned n, unsigned width)
{
  if (width > 1) myputhex(n >> 4, width-1);
  n &= 15;
  if (n > 9) myputchar(n + 'A' - 10);
  else myputchar(n + '0');
}

void hello(void)
{
  int i = 0;
  int j = 0;
  enum edcl_mode mode;
  size_t addr, addr2, addr3, addr4, data, arg, setting, last;
  myputs("Hello, from bootstrap\r\n");
  addr = (8<<20);
  last = addr+(edcl_max<<4)+12;
  do {
    addr4 = read_code_data8(last);
  }
  while ((unsigned)addr4 != 0xDEADBEEF);
  myputs("start\r\n");
  do {
    int cnt = 0;
    int mask, ready = my_stat(0);
    int discard = 0;
    addr3 = addr+(i<<4);
    addr2 = read_code_data8(addr3+4);
    mode = read_code_data8(addr3);
    myputchar(mode+'0');
    if (mode) switch(mode)
	{
	case edcl_mode_bootstrap:
	  {
	    int i;
	    typedef void *fptr(void);
	    myputs("Bootstrapping from ethernet ...\r\n");
	    memcpy((void*)0x2000, (void*)(addr+0x2000), 0x10000-0x2000);
	    for (i = 0; i < 32; i+=4)
	      {
		myputhex(addr2+i, 8);
		myputchar(':');
		myputhex(*((uint32_t *)(addr2+i)), 8);		
		myputchar('\r');
		myputchar('\n');
	      }
	    myputs("Bye.\r\n");
	    (*(fptr *) addr2)();
	    break;
	  }
	case edcl_mode_block_read:
	  mask = read_code_data8(addr3+12);
	  ready = my_stat(0);
	  while (mask & ~ready)
	    {
	      write_code_data32(addr2, 0);
	      data = read_code_data32(addr2);
	      write_code_data32(addr3+16+(cnt++ << 2), data);
	      ready = my_stat(0);
	    }
	  mode = 0;
	  i = cnt;
	  break;
	case edcl_mode_read:
	  data = read_code_data32(addr2);
	  write_code_data32(addr3+12, data);
	  break;
	case edcl_mode_write:
	  data = read_code_data8(addr3+12);
	  write_code_data32(addr2, data);
	  break;
	default:
	  myputs("unknown mode\r\n");
	  return;
	}
      i++;
  } while (mode);
  write_code_data32(addr, i);
  write_code_data32(addr+4, 0);
  write_code_data32(last, 0);
}

static void poll_shm(void)
{
  size_t addr, addr4, last;
  addr = (8<<20);
  last = addr+(edcl_max<<4)+12;
  addr4 = read_code_data8(last);
  if ((unsigned)addr4 == 0xDEADBEEF) hello();
}

static void axi_write(size_t addr, int data, int strb)
{
  volatile unsigned int * const eth_base = (volatile unsigned int*)(14<<20);
  eth_base[addr>>2] = data;
}

static int axi_read(size_t addr)
{
  volatile unsigned int * const eth_base = (volatile unsigned int*)(14<<20);
  int rslt = eth_base[addr>>2];
  return rslt;
}

static void eth_test(void)
{
  int length = 0x14;
  volatile unsigned int * const framing_base = (volatile unsigned int*)(13<<20);
  framing_base[0x200] = 0x5E00FACE;
  framing_base[0x201] = 0x10000;
  framing_base[0x400] = 0xffffffff;
  framing_base[0x401] = 0xffffffff;
  framing_base[0x402] = 0xffffffff;
  framing_base[0x403] = 0x11111111;
  framing_base[0x404] = 0x22222222;
  framing_base[0x405] = 0x33333333;
#if 0  
  axi_write(XEL_RSR_OFFSET, XEL_RSR_RECV_IE_MASK, 0xf);
  axi_write(0x00000000,0xffffffff,0xf);
  axi_write(0x00000004,0xffffffff,0xf);
  axi_write(0x00000008,0xffffffff,0xf);
  axi_write(0x0000000c,0x11111111,0xf);
  axi_write(0x00000010,0x22222222,0xf);
  axi_write(0x00000014,0x33333333,0xf);
  axi_read(0x0000001c);
  axi_write(0x00000020,0x55555555,0xf);
  axi_write(XEL_GIER_OFFSET, XEL_GIER_GIE_MASK, 0xf);
  axi_write(XEL_RSR_OFFSET, XEL_RSR_RECV_IE_MASK, 0xf);
  axi_write(XEL_TPLR_OFFSET, length, 0xf);
  axi_write(XEL_TSR_OFFSET, XEL_TSR_XMIT_IE_MASK|XEL_TSR_XMIT_BUSY_MASK, 0xf);
#else
  framing_base[0x202] = length;
  axi_write(0x800, 0x5E00FACE, 0xf);
  axi_write(0x804, 0x10000, 0xf);
  axi_write(0x1000, 0xffffffff, 0xf);
  axi_write(0x1004, 0xffffffff, 0xf);
  axi_write(0x1008, 0xffffffff, 0xf);
  axi_write(0x100C, 0x11111111, 0xf);
  axi_write(0x1010, 0x22222222, 0xf);
  axi_write(0x1014, 0x33333333, 0xf);  
#endif  
  axi_write(0x808, length, 0xf);

#if 0  
  while (axi_read(0x000007fc) == (XEL_TSR_XMIT_IE_MASK|XEL_TSR_XMIT_BUSY_MASK));
  axi_read(XEL_RSR_OFFSET);
#else
  while (axi_read(0x808) < length);
#endif  
}

int main()
{
  volatile unsigned int * const dip_base = (volatile unsigned int*)(7<<20);
  if (dip_base[0] & 0x80)
    eth_test();
  myputs("Hello\n");
  for (;;) poll_shm();
}
