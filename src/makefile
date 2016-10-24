#
# Makefile for PANEL device driver
#
# R D Eager   July 1996
#
# Uses MASM 5.1
#
MFLAGS		= /n /p /t /w2
#
panel.sys:	panel.obj panel.def panel.lnk
		link /batch @panel.lnk
#
panel.lnk:	makefile
		echo panel      > panel.lnk
		echo panel.sys >> panel.lnk
		echo panel/map >> panel.lnk
		echo os2286    >> panel.lnk
		echo panel.def >> panel.lnk
#
panel.obj:	panel.asm
		masm $(MFLAGS) panel,panel,panel;
#
# End of makefile for PANEL device driver
#
