/*
 * File: test2.c
 *
 * Test program 2 for PANEL device driver
 *
 * Uses standard I/O.
 *
 * Bob Eager   July 1996
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define	DEVICE		"PANEL$"


int main (int argc, char *argv[])
{	FILE *fp;
	int rc;
	char *p;

	if(argc > 2) {
		fprintf(stderr, "Too many arguments\n");
		exit(EXIT_FAILURE);
	}

	if(argc == 1) {
		p = "";
	} else {
		p = argv[1];
	}

	fp = fopen(DEVICE, "w");

	if(fp == (FILE *) NULL) {
		fprintf(stderr, "Device open failed, err = %d\n", errno);
		exit(EXIT_FAILURE);
	}

	rc = fwrite(p, strlen(p), 1, fp);

	if(rc == 0) {
		fprintf(stderr, "Write failed, rc = %d\n", rc);
		exit(EXIT_FAILURE);
	}
	fprintf(stderr, "Write succeeded, bytes written = %d\n", rc);

	(void) fclose(fp);

	return(EXIT_SUCCESS);
}

/*
 * End of file: test.c
 *
 */

