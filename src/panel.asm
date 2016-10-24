 	PAGE	64,132
	TITLE	PANEL - device driver to control Model 95 info panel
	NAME	PANEL
	.286
;
; Description:
;	OS/2 device driver for controlling the information panel on a
;	PS/2 Model 95.
;	Takes no arguments.
;
; OS/2 versions supported:
;	2.x
;	3.x (Warp)
;
; Version:
;	1.0
;
; Date:
;	11th July 1996
;
; Author:
;	R D Eager
;
; History:
;	1.0	Initial version
;
; Copyright and License
;
; This Software and its documentation are Copyright, 1996 by the Author:
;			Bob Eager
;			45 Fleetwood Avenue
;			Herne Bay
;			United Kingdom
;			CT6 8QW
;
;			rde@ukc.ac.uk    (USENET)
;			100016,2770      (CompuServe)
;
; License is granted to User to duplicate and disseminate this software
; product, and to use on one computer running OS/2, PROVIDED user agrees to
; 1) hold Author free of any and all liability for any consequences of use
; of the Software, 2) copy the PANEL.DOC file and retain it with any copy
; of PANEL.SYS copied to any medium, and 3) not charge any other person or
; organization for such copies.
;
	.XLIST
	INCLUDE	DEVHLP.INC
	INCLUDE	DEVSYM.INC
	.LIST
;
; Constants
;
STDOUT		EQU	1		; Standard output handle
;
PPORT		EQU	108H		; Panel starting port number
PSIZE		EQU	8		; Number of characters on panel
;
TAB		EQU	09H		; Tab character
CR		EQU	0DH		; Carriage return
LF		EQU	0AH		; Linefeed
;
; External references
;
	EXTRN	DosWrite:FAR
;
	SUBTTL	Data areas
	PAGE+
;
DGROUP	GROUP	_DATA
;
_DATA	SEGMENT	WORD PUBLIC 'DATA'
;
; Device driver header
;
HEADER	DD	-1			; Link to next device driver
	DW	1000100010000000B	; Device attributes:
;		|   | |||_______________;  function level 001
;		|   |___________________;  device open/close supported
;		|__ ____________________;  character device
	DW	OFFSET STRATEGY		; Strategy entry point
	DW	0			; IDC entry point - not used
	DB	'PANEL$  '		; Device name
	DB	8 DUP (0)		; Reserved
;
; Command function jump table
;
FUNTAB	DW	INIT			; 00H - Initialisation
	DW	BADCMD			; 01H - Media check
	DW	BADCMD			; 02H - Build BPB
	DW	BADCMD			; 03H - Reserved
	DW	INPUT			; 04H - Input
	DW	NDINPUT			; 05H - Non destructive input
	DW	FLSTAT			; 06H - Input status
	DW	FLSTAT			; 07H - Input flush
	DW	OUTPUT			; 08H - Output
	DW	BADCMD			; 09H - Output with verify
	DW	FLSTAT			; 0AH - Output status
	DW	FLSTAT			; 0BH - Output flush
	DW	BADCMD			; 0CH - Reserved
	DW	OPCLOSE			; 0DH - Open device
	DW	OPCLOSE			; 0EH - Close device
;
MAXCMD	EQU	($ - FUNTAB - 1) SHR 1	; Highest legal command code
;
	DW	BADCMD			; Pseudo function - command out of range
;
DevHlp	DD	?			; Entry point to DevHlp
;
	SUBTTL	Initialisation data
	PAGE+
;
; The following data are used only during initialisation, and are then
; discarded.
;
DINIT	EQU	THIS WORD
;
WLEN	DW	?			; Receives DosWrite length
MES1	DB	'PANEL driver - invalid argument',CR,LF,0
;
	DB	'*** Copyright (C) R D Eager  1996 ***'
;
_DATA	ENDS
;
	SUBTTL	Main code
	PAGE+
;
_TEXT	SEGMENT	WORD PUBLIC 'CODE'
;
	ASSUME	CS:_TEXT,DS:DGROUP,ES:NOTHING
;
; Strategy entry point
;
; Inputs:
;	ES:BX	- points to the request packet
;
; Outputs:
;	ES:BX.PktStatus
;		- status
;
STRATEGY	PROC	FAR
;
	MOV	AL,ES:[BX].PktCmd	; get function code
	CMP	AL,MAXCMD		; check range
	JLE	CMDOK			; j if OK
	MOV	AL,MAXCMD+1		; pseudo code for error
;
CMDOK:	ROL	AL,1			; form word offset
	CBW				; convert for index
	MOV	SI,AX
	CALL	[SI+FUNTAB]		; call requested function
;
; Function exit code - sets up status and exits
; At this point, AX contains the required status.
; We assume that ES:BX still point to the request header.
;
EXIT:	OR	AX,AX			; check return code
	JZ	NOERR			; j if no error
	CMP	AH,02H			; just busy?
	JE	NOERR			; OK too
;
ERR:	OR	AH,80H			; set error bit
;
NOERR:	OR	AH,01H			; set done bit
	MOV	ES:[BX].PktStatus,AX	; store status in request packet
	RET				; return to system
;
STRATEGY	ENDP
;
; Bad command handler; simply sets status and returns.
;
BADCMD	PROC	NEAR
;
	MOV	AX,0003H		; unknown command
	RET				; return to outer level
;
BADCMD	ENDP
;
	SUBTTL	Open or close device
	PAGE+
;
; Device open and close code. Always successful, and does nothing.
; Monitor opens and closes are, however, failed.
;
; Inputs:
;	ES:BX	- points to the request packet
;
; Outputs:
;	AX	- status
;
OPCLOSE	PROC	NEAR
;
	XOR	AX,AX			; assume success
	TEST	ES:[BX].PktStatus,08H	; monitor open or close?
	JZ	OPC10			; j if not
	MOV	AL,12H			; monitors not supported
;
OPC10:	RET				; return with status in AX
;
OPCLOSE	ENDP
;
	SUBTTL	Do input
	PAGE+
;
; Perform input. Always returns end of file, as the device cannot be read
; from.
;
; Inputs:
;	ES:BX	- points to the request packet
;
; Outputs:
;	AX	- status
;
INPUT	PROC	NEAR
;
	XOR	AX,AX			; always successful
	MOV	ES:[BX].IOcount,AX	; nothing transferred
;
	RET				; return with status in AX
;
INPUT	ENDP
;
	SUBTTL	Do output
	PAGE+
;
; Perform output of N bytes.
;	N < PSIZE	- update first N characters on panel
;	N = PSIZE	- update all PSIZE characters on panel
;	N > PSIZE	- update PSIZE characters; discard rest of output
;
; Inputs:
;	ES:BX	- points to the request packet
;
; Outputs:
;	AX	- status
;
OUTPUT	PROC	NEAR
;
	MOV	CX,ES:[BX].IOcount	; get output count
	CMP	CX,PSIZE		; too much?
	JLE	OUT10			; j if not
	MOV	CX,PSIZE		; else maximise at PSIZE
;
; Call DevHlp to convert buffer address
;
OUT10:	PUSH	DS			; save registers
	PUSH	SI
	PUSH	BX
	MOV	AX,WORD PTR ES:[BX].IOpData+2
					; high word of transfer address
	MOV	BX,WORD PTR ES:[BX].IOpData
					; low word of transfer address
	MOV	DX,DevHlp_PhysToVirt	; DL=function required
					; DH=0 => result in DS:SI
	CALL	DevHlp			; convert it
	POP	BX			; recover register
	JNC	OUT20			; j if OK
	MOV	ES:[BX].IOcount,0	; length of transfer
	MOV	AX,000CH		; general failure
	JMP	SHORT OUT40		; and return
;
; Now do the output. Leave the I/O count, so that excess bytes don't cause
; apparent failure.
;
OUT20:	OR	CX,CX			; check for zero transfer
	JZ	OUT40			; j if nothing to do
	MOV	DX,PPORT+PSIZE-1	; starting port (goes backwards)
;
OUT30:	LODSB				; get next byte
	OUT	DX,AL			; send it
	DEC	DX			; to next port
	LOOPNZ	OUT30			; repeat as required
	XOR	AX,AX			; success
;
OUT40:	POP	SI			; recover registers
	POP	DS
	RET				; return with status in AX
;
OUTPUT	ENDP
;
	SUBTTL	Do non-destructive input
	PAGE+
;
; Perform non-destructive input. Since there is never any input, always
; returns with busy status.
;
; Inputs:
;	ES:BX	- points to the request packet
;
; Outputs:
;	AX	- status
;
NDINPUT	PROC	NEAR
;
	MOV	AX,0200H		; busy
;
	RET				; return with status in AX
;
NDINPUT	ENDP
;
	SUBTTL	I/O status and flush
	PAGE+
;
; Return input or output status, and flush input or output.
; Since there is never any input, is never busy for input.
; Since output happens at once, is never busy for output.
; Since there is never any input to flush, just returns success and not busy.
; There is no output queue, so we just return success, and not busy.
;
; Inputs:
;	ES:BX	- points to the request packet
;
; Outputs:
;	AX	- status
;
FLSTAT	PROC	NEAR
;
	XOR	AX,AX			; success, not busy
;
	RET				; return with status in AX
;
FLSTAT	ENDP
;
	SUBTTL	Initialisation code
	PAGE+
;
; Initialisation code. All of this code is present only during initialisation;
; none of the driver data is used after that time either.
;
; ES:BX points to the request packet.
; Status is returned in AX.
;
	ASSUME	CS:_TEXT,DS:DGROUP,ES:NOTHING
;
INIT	PROC	NEAR
;
; Process the INIT arguments
;
	PUSH	DS			; save data segment for later
;
	MOV	AX,WORD PTR ES:[BX].InitDevHlp
					; offset of DevHlp entry point
	MOV	WORD PTR DevHlp,AX	; save it
	MOV	AX,WORD PTR ES:[BX].InitDevHlp+2
					; segment of DevHlp entry point
	MOV	WORD PTR DevHlp+2,AX	; save it
	MOV	SI,WORD PTR ES:[BX].InitParms
					; offset of INIT arguments
	MOV	DS,WORD PTR ES:[BX].InitParms+2
					; segment of INIT arguments
;
	ASSUME	CS:_TEXT,DS:NOTHING,ES:NOTHING
;
	CLD				; autoincrement
;
INIT10:	LODSB				; skip leading whitespace
	CMP	AL,' '
	JE	INIT10
	CMP	AL,TAB
	JE	INIT10
	DEC	SI			; back to first non-space
;
INIT20:	LODSB				; skip filename
	CMP	AL,' '
	JE	SHORT INIT30		; found next separator
	CMP	AL,TAB
	JE	SHORT INIT30		; found next separator
	CMP	AL,0			; found terminator?
	JE	SHORT INIT35		; j if so
	JMP	INIT20			; else keep looking
;
INIT30:	LODSB				; skip separating whitespace
	CMP	AL,' '
	JE	INIT30
	CMP	AL,TAB
	JE	INIT30
;
INIT35:	POP	DS			; recover data segment
	CMP	AL,0			; found terminator?
	JNE	INIT50			; j if not - error
;
INIT40:	MOV	WORD PTR ES:[BX].InitEcode,OFFSET _TEXT:INIT
					; truncate code segment
	MOV	WORD PTR ES:[BX].InitEdata,OFFSET _DATA:DINIT
					; truncate data segment
	XOR	AX,AX			; success status
	RET
;
; Invalid argument (any at all) detected
;
INIT50:	MOV	AX,OFFSET MES1		; error message
	CALL	DOSOUT			; display it
	MOV	WORD PTR ES:[BX].InitEcode,0
					; lose code segment
	MOV	WORD PTR ES:[BX].InitEdata,0
					; lose data segment
	MOV	AX,810CH		; error/done/general failure
	RET
;
INIT	ENDP
;
	SUBTTL	Output message
	PAGE+
;
; Routine to output a string to the screen.
;
; Inputs:
;	AX	- offset of zero terminated message
;
; Outputs:
;	AX	- not preserved
;
DOSOUT	PROC	NEAR
;
	PUSH	DI			; save DI
	PUSH	CX			; save CX
	PUSH	ES			; save ES
	PUSH	AX			; save message offset
	PUSH	DS			; copy DS...
	POP	ES			; ...to ES
	MOV	DI,AX			; ES:DI point to message
	XOR	AL,AL			; set AL=0 for scan value
	MOV	CX,100			; just a large value
	REPNZ	SCASB			; scan for zero byte
	POP	AX			; recover message offset
	POP	ES			; recover ES
	POP	CX			; recover CX
	SUB	DI,AX			; get size to DI
	DEC	DI			; adjust
	PUSH	STDOUT			; standard output handle
	PUSH	DS			; segment of message
	PUSH	AX			; offset of message
	PUSH	DI			; length of message
	PUSH	DS			; segment for length written
	PUSH	OFFSET DGROUP:WLEN	; offset for length written
	CALL	DosWrite		; write message
	POP	DI			; recover DI
;
	RET
;
DOSOUT	ENDP
;
_TEXT	ENDS
;
	END
