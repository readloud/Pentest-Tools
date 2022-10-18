
#define RRQ 1
#define WRQ 2
#define DAT 3
#define ACK 4
#define ERR 5


#define MAXDATA 512	/* max size of data */
#define PKTSIZE 516	/* max size of TFTP packet */

#define MAXFSIZE 128








struct packet
{
	UINT opcode;
	union {
		char *fname;
		UINT blkno;
		UINT errcode;
	} mid;
	char *stuff;
};

