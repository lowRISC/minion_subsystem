/*
 *  Utility functions to create, read, write, and print Motorola S-Record binary records.
 *
 *  Written by Vanya A. Sergeev <vsergeev@gmail.com>
 *  Version 1.0.5 - February 2011
 *
 */

#include <stdio.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include "minion_lib.h"
#ifdef __x86_64__
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <termios.h>

int fd, first = 1;

static struct termios oldt;

void normal(void)
{
  tcgetattr(fd, &oldt);
  oldt.c_lflag |= (ICANON|ECHO);
  oldt.c_iflag |= (ICRNL);
  tcsetattr(fd, 0, &oldt);
  close(fd);
  first = 1;
}

void cbreak(void)
{
  int rslt;
  first = 0;
  fd = open("/dev/tty", O_RDWR);
  rslt = tcgetattr(fd, &oldt);
  if (rslt) perror("tcgetattr");
  oldt.c_lflag &= ~ (ICANON|ECHO);
  oldt.c_iflag &= ~ (ICRNL);
  rslt = tcsetattr(fd, 0, &oldt);
  if (rslt) perror("tcsetattr");
  atexit(normal);
}

void uart_sendchar(char ch)
{
  if (first) cbreak();
  if (0) puts("putchar()");
  putchar(ch);
}

int uart_getchar(void)
{
  int ch;
  if (first) cbreak();
  if (0) puts("getchar()");
  ch = getchar();
  return (ch < 0) ? 4 : ch;
}

unsigned char codeseg[1<<16];
unsigned char dataseg[1<<16];

void write_code_data(int addr, int len, const uint8_t *data)
{
  int i;
  if (addr & 0x100000)
    for (i = 0; i < len; i++) dataseg[(addr&0xFFFFF)+i] = data[i];
  else
    for (i = 0; i < len; i++) codeseg[addr+i] = data[i];
}

int read_code_data(int addr)
{
  if (addr & 0x100000)
    return dataseg[addr];
  else
    return codeseg[addr];
}

void entry(int addr)
{
  unsigned i;
  (void)addr;
  int last_i = 0;
  int last_d = 0;
  for (i = 0; i < sizeof codeseg; i++) if (codeseg[i]) last_i = i;
  for (i = 0; i < sizeof dataseg; i++) if (dataseg[i]) last_d = i;
  myputs("Last code = ");
  myputhex(last_i, 8);
  myputs(", last data = ");
  myputhex(last_d, 8);
}

#else
//#define SD_LIB
#include "minion_lib.h"

void write_code_data(int addr, int len, const uint8_t *data)
{
  int i;
  for (i = 0; i < len; i++) *(unsigned char *)(addr+i) = data[i];
}

void write_code_data32(int addr, size_t data)
{
  *(size_t *)addr = data;
}

int read_code_data(int addr)
{
  return *(unsigned char *)addr;
}

void entry(int addr)
{
  typedef void *fptr(void);
  (*(fptr *) addr)();
}

#endif

int echo;

void myputchar(char ch)
{
   uart_sendchar(ch);
}

int mygetchar(void)
{
  int ch = uart_getchar();
  if (echo) uart_sendchar(ch);
  return ch;
}

void my_write_chan(int chan, int data)
{
  (void)chan;
  (void)data;
}

void myputs(const char *str)
{
  while (*str)
    {
      myputchar(*str++);
    }
}

void myputn(unsigned n)
{
  if (n > 9) myputn(n / 10);
  myputchar(n%10 + '0');
}

void myputhex(unsigned n, unsigned width)
{
  if (width > 1) myputhex(n >> 4, width-1);
  n &= 15;
  if (n > 9) myputchar(n + 'A' - 10);
  else myputchar(n + '0');
}

const char *scan(const char *start, size_t *data, int base)
{
  *data = 0;
  while (*start)
    {
      if (*start >= '0' && *start <= '9') *data = *data * base + *start++ - '0';
      else if (*start >= 'A' && *start <= 'F') *data = *data * base + *start++ - 'A' + 10;
      else if (*start >= 'a' && *start <= 'f') *data = *data * base + *start++ - 'a' + 10;
      else if (*start == ' ') ++start;
      else return start+1;
    }
  return start;
}

size_t mystrtol(const char *nptr, char **endptr, int base)
{
  size_t data;  
  const char *last = scan(nptr, &data, base);
  if (endptr) *endptr = (char *)last;
  return data;
}

/* General definition of the S-Record specification */
enum _SRecordDefinitions {
	/* 768 should be plenty of space to read in an S-Record */
	SRECORD_RECORD_BUFF_SIZE = 768,
	/* Offsets and lengths of various fields in an S-Record record */
	SRECORD_TYPE_OFFSET = 1,
	SRECORD_TYPE_LEN = 1,
	SRECORD_COUNT_OFFSET = 2,
	SRECORD_COUNT_LEN = 2,
	SRECORD_ADDRESS_OFFSET = 4,
	SRECORD_CHECKSUM_LEN = 2,
	/* Maximum ascii hex length of the S-Record data field */
	SRECORD_MAX_DATA_LEN = 64,
	/* Maximum ascii hex length of the S-Record address field */
	SRECORD_MAX_ADDRESS_LEN = 8,
	/* Ascii hex length of a single byte */
	SRECORD_ASCII_HEX_BYTE_LEN = 2,
	/* Start code offset and value */
	SRECORD_START_CODE_OFFSET = 0,
	SRECORD_START_CODE = 'S',
};

/**
 * All possible error codes the Motorola S-Record utility functions may return.
 */
enum SRecordErrors {
	SRECORD_OK = 0, 			/**< Error code for success or no error. */
	SRECORD_ERROR_FILE = -1, 		/**< Error code for error while reading from or writing to a file. You may check errno for the exact error if this error code is encountered. */
	SRECORD_ERROR_EOF = -2, 		/**< Error code for encountering end-of-file when reading from a file. */
	SRECORD_ERROR_INVALID_RECORD = -3, 	/**< Error code for error if an invalid record was read. */
	SRECORD_ERROR_INVALID_ARGUMENTS = -4, 	/**< Error code for error from invalid arguments passed to function. */
	SRECORD_ERROR_NEWLINE = -5, 		/**< Error code for encountering a newline with no record when reading from a file. */
};

/**
 * Motorola S-Record Types S0-S9
 */
enum SRecordTypes {
	SRECORD_TYPE_S0 = 0, /**< Header record, although there is an official format it is often made proprietary by third-parties. 16-bit address normally set to 0x0000 and header information is stored in the data field. This record is unnecessary and commonly not used. */
	SRECORD_TYPE_S1, /**< Data record with 16-bit address */
	SRECORD_TYPE_S2, /**< Data record with 24-bit address */
	SRECORD_TYPE_S3, /**< Data record with 32-bit address */
	SRECORD_TYPE_S4, /**< Extension by LSI Logic, Inc. See their specification for more details. */
	SRECORD_TYPE_S5, /**< 16-bit address field that contains the number of S1, S2, and S3 (all data) records transmitted. No data field. */
	SRECORD_TYPE_S6, /**< 24-bit address field that contains the number of S1, S2, and S3 (all data) records transmitted. No data field. */
	SRECORD_TYPE_S7, /**< Termination record for S3 data records. 32-bit address field contains address of the entry point after the S-Record file has been processed. No data field. */
	SRECORD_TYPE_S8, /**< Termination record for S2 data records. 24-bit address field contains address of the entry point after the S-Record file has been processed. No data field. */
	SRECORD_TYPE_S9, /**< Termination record for S1 data records. 16-bit address field contains address of the entry point after the S-Record file has been processed. No data field. */
};

/**
 * Structure to hold the fields of a Motorola S-Record record.
 */
typedef struct {
	uint32_t address; 			/**< The address field. This can be 16, 24, or 32 bits depending on the record type. */
	uint8_t data[SRECORD_MAX_DATA_LEN/2]; 	/**< The 8-bit array data field, which has a maximum size of 32 bytes. */
	int dataLen; 				/**< The number of bytes of data stored in this record. */
	int type; 				/**< The Motorola S-Record type of this record (S0-S9). */
	uint8_t checksum; 			/**< The checksum of this record. */
} SRecord;

/**
 * Sets all of the record fields of a Motorola S-Record structure.
 * \param type The Motorola S-Record type (integer value of 0 through 9).
 * \param address The 32-bit address of the data. The actual size of the address (16-,24-, or 32-bits) when written to a file depends on the S-Record type.
 * \param data A pointer to the 8-bit array of data.
 * \param dataLen The size of the 8-bit data array.
 * \param srec A pointer to the target Motorola S-Record structure where these fields will be set.
 * \return SRECORD_OK on success, otherwise one of the SRECORD_ERROR_ error codes.
 * \retval SRECORD_OK on success.
 * \retval SRECORD_ERROR_INVALID_ARGUMENTS if the record pointer is NULL, or if the length of the 8-bit data array is out of range (less than zero or greater than the maximum data length allowed by record specifications, see SRecord.data).
*/
int New_SRecord(int type, uint32_t address, const uint8_t *data, int dataLen, SRecord *srec);

/**
 * Prints the contents of a Motorola S-Record structure to stdout.
 * The record dump consists of the type, address, entire data array, and checksum fields of the record.
 * \param srec A pointer to the Motorola S-Record structure.
 * \return Always returns SRECORD_OK (success).
 * \retval SRECORD_OK on success.
*/
void Print_SRecord(const SRecord *srec);

/**
 * Calculates the checksum of a Motorola S-Record SRecord structure.
 * See the Motorola S-Record specifications for more details on the checksum calculation.
 * \param srec A pointer to the Motorola S-Record structure.
 * \return The 8-bit checksum.
*/
uint8_t Checksum_SRecord(const SRecord *srec);

/* Lengths of the ASCII hex encoded address fields of different SRecord types */
static int SRecord_Address_Lengths[] = {
	4, // S0
	4, // S1
	6, // S2
	8, // S3
	8, // S4
	4, // S5
	6, // S6
	8, // S7
	6, // S8
	4, // S9
};

/* Initializes a new SRecord structure that the paramater srec points to with the passed
 * S-Record type, up to 32-bit integer address, 8-bit data array, and size of 8-bit data array. */
int New_SRecord(int type, uint32_t address, const uint8_t *data, int dataLen, SRecord *srec) {
	/* Data length size check, assertion of srec pointer */
	if (dataLen < 0 || dataLen > SRECORD_MAX_DATA_LEN/2 || srec == (void*)0)
		return SRECORD_ERROR_INVALID_ARGUMENTS;

	srec->type = type;
	srec->address = address;
	memcpy(srec->data, data, dataLen);
	srec->dataLen = dataLen;
	srec->checksum = Checksum_SRecord(srec);

	return SRECORD_OK;
}


/* Utility function to read an S-Record from a file */
int Read_SRecord(char recordBuff[], SRecord *srec) {
	/* A temporary buffer to hold ASCII hex encoded data, set to the maximum length we would ever need */
	char hexBuff[SRECORD_MAX_ADDRESS_LEN+1];
	int asciiAddressLen, asciiDataLen, dataOffset, fieldDataCount, i;

	/* Size check for type and count fields */
	if (strlen(recordBuff) < SRECORD_TYPE_LEN + SRECORD_COUNT_LEN)
		return SRECORD_ERROR_INVALID_RECORD;

	/* Check for the S-Record start code at the beginning of every record */
	if (recordBuff[SRECORD_START_CODE_OFFSET] != SRECORD_START_CODE)
		return SRECORD_ERROR_INVALID_RECORD;

	/* Copy the ASCII hex encoding of the type field into hexBuff, convert it into a usable integer */
	strncpy(hexBuff, recordBuff+SRECORD_TYPE_OFFSET, SRECORD_TYPE_LEN);
	hexBuff[SRECORD_TYPE_LEN] = 0;
	srec->type = mystrtol(hexBuff, (char **)0, 16);

	/* Copy the ASCII hex encoding of the count field into hexBuff, convert it to a usable integer */
	strncpy(hexBuff, recordBuff+SRECORD_COUNT_OFFSET, SRECORD_COUNT_LEN);
	hexBuff[SRECORD_COUNT_LEN] = 0;
	fieldDataCount = mystrtol(hexBuff, (char **)0, 16);

	/* Check that our S-Record type is valid */
	if (srec->type < SRECORD_TYPE_S0 || srec->type > SRECORD_TYPE_S9)
		return SRECORD_ERROR_INVALID_RECORD;
	/* Get the ASCII hex address length of this particular S-Record type */
	asciiAddressLen = SRecord_Address_Lengths[srec->type];

	/* Size check for address field */
	if (strlen(recordBuff) < (unsigned int)(SRECORD_ADDRESS_OFFSET+asciiAddressLen))
		return SRECORD_ERROR_INVALID_RECORD;

	/* Copy the ASCII hex encoding of the count field into hexBuff, convert it to a usable integer */
	strncpy(hexBuff, recordBuff+SRECORD_ADDRESS_OFFSET, asciiAddressLen);
	hexBuff[asciiAddressLen] = 0;
	srec->address = mystrtol(hexBuff, (char **)0, 16);

	/* Compute the ASCII hex data length by subtracting the remaining field lengths from the S-Record
	 * count field (times 2 to account for the number of characters used in ASCII hex encoding) */
	asciiDataLen = (fieldDataCount*2) - asciiAddressLen - SRECORD_CHECKSUM_LEN;
	/* Bailout if we get an invalid data length */
	if (asciiDataLen < 0 || asciiDataLen > SRECORD_MAX_DATA_LEN)
		return SRECORD_ERROR_INVALID_RECORD;

	/* Size check for final data field and checksum field */
	if (strlen(recordBuff) < (unsigned int)(SRECORD_ADDRESS_OFFSET+asciiAddressLen+asciiDataLen+SRECORD_CHECKSUM_LEN))
		return SRECORD_ERROR_INVALID_RECORD;

	dataOffset = SRECORD_ADDRESS_OFFSET+asciiAddressLen;

	/* Loop through each ASCII hex byte of the data field, pull it out into hexBuff,
	 * convert it and store the result in the data buffer of the S-Record */
	for (i = 0; i < asciiDataLen/2; i++) {
		/* Times two i because every byte is represented by two ASCII hex characters */
		strncpy(hexBuff, recordBuff+dataOffset+2*i, SRECORD_ASCII_HEX_BYTE_LEN);
		hexBuff[SRECORD_ASCII_HEX_BYTE_LEN] = 0;
		srec->data[i] = mystrtol(hexBuff, (char **)0, 16);
	}
	/* Real data len is divided by two because every byte is represented by two ASCII hex characters */
	srec->dataLen = asciiDataLen/2;

	/* Copy out the checksum ASCII hex encoded byte, and convert it back to a usable integer */
	strncpy(hexBuff, recordBuff+dataOffset+asciiDataLen, SRECORD_CHECKSUM_LEN);
	hexBuff[SRECORD_CHECKSUM_LEN] = 0;
	srec->checksum = mystrtol(hexBuff, (char **)0, 16);

	if (srec->checksum != Checksum_SRecord(srec))
		return SRECORD_ERROR_INVALID_RECORD;

	return SRECORD_OK;
}

/* Utility function to print the information stored in an S-Record */
void Convert_SRecord(const SRecord *srec) {
	switch(srec->type)
	  {
	  case SRECORD_TYPE_S7:
	  case SRECORD_TYPE_S8:
	  case SRECORD_TYPE_S9:
	    myputs("entry = ");
	    myputhex(srec->address, 8);
	    myputs("\r\n");
	    entry(srec->address);
	    break;
	  case SRECORD_TYPE_S1:
	  case SRECORD_TYPE_S2:
	  case SRECORD_TYPE_S3:
	    write_code_data(srec->address, srec->dataLen, srec->data);
	    break;
	  }
}

/* Utility function to calculate the checksum of an S-Record */
uint8_t Checksum_SRecord(const SRecord *srec) {
	uint8_t checksum;
	int fieldDataCount, i;

	/* Compute the record count, address and checksum lengths are halved because record count
	 * is the number of bytes left in the record, not the length of the ASCII hex representation */
	fieldDataCount = SRecord_Address_Lengths[srec->type]/2 + srec->dataLen + SRECORD_CHECKSUM_LEN/2;

	/* Add the count, address, and data fields together */
	checksum = fieldDataCount;
	/* Add each byte of the address individually */
	checksum += (uint8_t)(srec->address & 0x000000FF);
	checksum += (uint8_t)((srec->address & 0x0000FF00) >> 8);
	checksum += (uint8_t)((srec->address & 0x00FF0000) >> 16);
	checksum += (uint8_t)((srec->address & 0xFF000000) >> 24);
	for (i = 0; i < srec->dataLen; i++)
		checksum += srec->data[i];

	/* One's complement the checksum */
	checksum = ~checksum;

	return checksum;
}

char ucmd[100];

void mygets(char *cmd)
{
  int ch;
  char *chp = cmd;
  ch = mygetchar();
  while (ch != '\r')
    {
      if (ch != '\n') *chp++ = ch;
      if (ch == '\004') return;
      ch = mygetchar();
    }
  *chp = 0;
  /*
  myputs("\n**** ");
  myputs(cmd);
  myputs(" ****\n");
  */
}

#ifdef SD_LIB_STANDALONE
unsigned sd_transaction_v(int sdcmd, unsigned arg, unsigned setting)
{
  int i;
  unsigned resp[8];
  myputchar('\r');
  myputchar('\n');
  sd_transaction(sdcmd, arg, setting, resp);
  myputhex(resp[7], 4);
  myputchar(':');
  myputhex(resp[6], 8);
  myputchar('-');
  myputchar('>');
  for (i = 4; i--; )
    {
      myputhex(resp[i], 8);
      myputchar(',');
    }
  myputhex(resp[5], 8);
  myputchar(',');
  myputhex(resp[4], 8);
  return resp[0] & 0xFFFF0000U;
}
#endif

int main()
{
  int i, rca, busy;
  SRecord srec;
#ifdef SD_LIB_STANDALONE
  spi_init();
#endif
  myputs("Hello\n");
  do {
    size_t addr, addr2, data, sdcmd, arg, setting;
    const char *nxt;
    myputchar('\n');
    mygets(ucmd);
    switch(*ucmd)
      {
      case 4:
	break;
      case 'e':
	echo = !echo;
	myputchar('\n');
	myputchar('e');
	myputchar(' ');
	myputhex(echo, 1);
	break;
      case 'B':
	myputchar('\n');
	myputs("Boostrapping ...");
	memcpy((void*)0x8000, (void*)0x808000, 0x8000);
	entry(0x8000);
	break;
#ifdef SD_LIB
      case 'i':
	nxt = scan(ucmd+1, &addr, 16);
	myputchar('\n');
	myputchar('i');
	myputchar(' ');
	sd_transaction_v(0,0x00000000,0x0);
	sd_transaction_v(8,0x000001AA,0x1);
	do {
	sd_transaction_v(55,0x00000000,0x1);
	busy = sd_transaction_v(41,0x40300000,0x1);
	} while (0x80000000U & ~busy);
	sd_transaction_v(2,0x00000000,0x3);
	rca = sd_transaction_v(3,0x00000000,0x1);
	myputchar('\r');
	myputchar('\n');
	myputchar('c');
	myputhex(rca, 8);
	sd_transaction_v(9,rca,0x3);
	sd_transaction_v(13,rca,0x1);
	sd_transaction_v(7,rca,0x1);
	sd_transaction_v(55,rca,0x1);
	sd_transaction_v(51,0x00000000,0x1);
	sd_transaction_v(55,rca,0x1);
	sd_transaction_v(13,0x00000000,0x1);
	for (i = 0; i < 16; i=(i+1)|1)
	  {
	    sd_transaction_v(16,0x00000200,0x1);
	    sd_transaction_v(17,i,0x1);
	    sd_transaction_v(16,0x00000200,0x1);
	  }
	sd_transaction_v(16,0x00000200,0x1);
	sd_transaction_v(18,0x00000040,0x1);
	sd_transaction_v(12,0x00000000,0x1);
	break;
#endif
      case 'o':
	nxt = scan(ucmd+1, &addr, 16);
	myputchar('\n');
	myputchar('o');
	myputchar(' ');
	myputhex(addr, 8);
	nxt = scan(nxt, &data, 16);
	myputchar(',');
	myputhex(data, 2);
	my_write_chan(addr, data);
	break;
      case 'r':
	nxt = scan(ucmd+1, &addr, 16);
	myputchar('\n');
	myputchar('r');
	myputchar(' ');
	myputhex(addr, 8);
	myputchar(',');
	data = read_code_data(addr);
	myputhex(data, 2);
	break;
      case 'R':
	nxt = scan(ucmd+1, &addr, 16);
	addr &= ~3;
	nxt = scan(nxt, &addr2, 16);
	while (addr <= addr2)
	  {
	    myputchar('\n');
	    myputchar('R');
	    myputchar(' ');
	    myputhex(addr, 8);
	    myputchar(':');
	    data = read_code_data(addr) | (read_code_data(addr+1) << 8) | (read_code_data(addr+2) << 16) | (read_code_data(addr+3) << 24);
	    myputhex(data, 8);
	    addr += 4;
	  }
	break;
      case 'w':
	nxt = scan(ucmd+1, &addr, 16);
	myputchar('\n');
	myputchar('w');
	myputchar(' ');
	myputhex(addr, 8);
	nxt = scan(nxt, &data, 16);
	myputchar(',');
	myputhex(data, 2);
	write_code_data(addr, 1, (uint8_t *)&data);
	break;
      case 'W':
	nxt = scan(ucmd+1, &addr, 16);
	myputchar('\n');
	myputchar('W');
	myputchar(' ');
	myputhex(addr, 8);
	nxt = scan(nxt, &data, 16);
	myputchar(',');
	myputhex(data, 8);
	write_code_data32(addr, data);
	break;
#ifdef SD_LIB
      case 's':
	nxt = scan(ucmd+1, &sdcmd, 16);
	myputchar('\n');
	myputchar('s');
	myputchar(' ');
	myputhex(sdcmd,2);
	nxt = scan(nxt, &arg, 16);
	myputchar(',');
	myputhex(arg, 8);
	nxt = scan(nxt, &setting, 16);
	myputchar(',');
	myputhex(setting, 1);
	myputchar('\r');
        myputchar('\n');
	sd_transaction_v(sdcmd, arg, setting);
	break;
#endif
      case 'S':
	switch (Read_SRecord(ucmd, &srec))
	  {
	  case SRECORD_OK: Convert_SRecord(&srec); break;
	  case SRECORD_ERROR_INVALID_RECORD: myputchar('?'); break;
	  }
	break;
      default: myputs("\nunknown command");
      }
	
  } while (*ucmd != 4);
  return 0;
}

void abort()
{
  myputs("abort");
  for(;;);
}
