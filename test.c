/*
 * File: test.c
 *
 * Test program for PANEL device driver
 *
 * Bob Eager   July 1996
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define	INCL_DOSFILEMGR
#include <os2.h>

#define	DEVICE		"PANEL$"


int main (int argc, char *argv[])
{	int length;
	HFILE handle;
	ULONG action;
	ULONG actual;
	APIRET rc;
	char *p;

	if(argc > 2) {
		fprintf(stderr, "Too many arguments\n");
		exit(EXIT_FAILURE);
	}

	if(argc == 1) {
		p = "";
		length = 0;
	} else {
		p = argv[1];
		length = strlen(p);
	}

	rc = DosOpen(
		DEVICE,				/* device name */
		&handle,			/* handle returned here */
		&action,			/* open action returned here */
		0,				/* new logical size */
		0,				/* file attributes */
		OPEN_ACTION_OPEN_IF_EXISTS,	/* open flags */
		OPEN_ACCESS_READWRITE |
		OPEN_SHARE_DENYNONE,		/* open mode */
		NULL);				/* extended attributes */

	if(rc != 0) {
		fprintf(stderr, "DosOpen failed, rc = %d\n", rc);
		exit(EXIT_FAILURE);
	}

	rc = DosWrite(
		handle,				/* file handle */
		p,				/* buffer */
		length,				/* byte count */
		&actual);			/* actual bytes written */

	if(rc != 0) {
		fprintf(stderr, "DosWrite failed, rc = %d\n", rc);
		exit(EXIT_FAILURE);
	}
	fprintf(stderr, "DosWrite succeeded, bytes written = %ld\n", actual);

	rc = DosClose(handle);

	return(EXIT_SUCCESS);
}

/*
 * End of file: test.c
 *
 */

