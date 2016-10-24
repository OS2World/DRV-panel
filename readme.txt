PANEL - an OS/2 device driver for the Model 95 information panel
================================================================

PANEL is a small OS/2 device driver that gives access to the small
(eight character) information panel on the front of the PS/2 Model 95
series of systems (and possibly others). 

To install the driver, simply place the file PANEL.SYS in a convenient
directory, then add the line:

	DEVICE=d:\path\PANEL.SYS

to CONFIG.SYS, substituting for d:\path\ as appropriate.  Then reboot. 

To use the driver, simply write up to eight characters to the device
PANEL$.  If more are written, the excess are quietly ignored but appear
to have been written.  This makes it easier to use (say) the COPY
command to write eight characters; the terminating CR-LF sequence is
conveniently ignored.  If fewer than 8 characters are written, the
remaining characters on the panel are not altered. 

Two sample test programs are included; both take a single parameter
which is the string to be written to the panel.  Or you can use the COPY
command:

	COPY CON PANEL$
	abcdefgh
	^Z

Note that, if you are using the IBM2SCSI.ADD driver, the last panel
character position will be unreliable unless you remove the /LED option
from the corresponding line in CONFIG.SYS, because the drivers will both
be writing to that position. 

Bob Eager

rde@tavi.co.uk

May 1999

