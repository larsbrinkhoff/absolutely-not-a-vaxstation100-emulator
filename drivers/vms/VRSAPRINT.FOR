	PROGRAM VRSAPRINT
C
C This program will read in the VSTAPRINT bitmap file and generate a
C hardcopy output on a Versatec 121 Electrostatic Plotter.
C
C Variable declarations:
C
	INTEGER*4 IUNIT		!Needed for Versatec common, not used
	INTEGER*4 LUNIT		!Logical unit number for error messages
	INTEGER*4 LREC		!Needed for Versatec common, not used
	INTEGER*4 IOTYPE	!Code number for type of output: 1 = plot
C
C This common block needed for versatec routines
C
	COMMON /IOCOM/ IUNIT, LUNIT, LREC, IOTYPE
C
	INTEGER*4 IBUF(128)	!First record of VSTAPRINT, contains
				! XDIM and YDIM
	BYTE BITMAP(512)	!Each consecutive record, 512 bytes long
	BYTE IPLOT(896)		!Buffer for output, make it large
	BYTE TEMP		!Temporary byte for swapping bytes
	INTEGER*4 XDIM		!Width of output in pixels
	INTEGER*4 YDIM		!Height of output in pixels
	INTEGER*4 XDIMBYTES	!Number of bytes/scan line - word aligned
	INTEGER*4 TOTAL_NUM_BITS	!Number of pixels in output
	INTEGER*4 NUM_BITS_ON		!Number of white pixels in output
	INTEGER*4 NBYTES	!Number of bytes per scan line, always 264
C
	DATA NBYTES/264/
C
	IOTYPE = 1		! Plot
C
	LUNIT = 6		! Terminal
C
	CALL ATTACH		! Attach the output device, Versatec routine
C
C At this point, we open the file, read in all the bitmap, total up all the
C pixels that are black and all the pixels in the entire output for comparison
C later on.  THIS WILL REVERSE VIDEO THE IMAGE IF THERE ARE MORE BLACK PIXELS
C THAN WHITE PIXEL.  Comment this section in as well as some expressions in the
C follow section if that is what you want to do.
C
C	Open the file and read it into Bitmap
C
C	OPEN (UNIT=37,FILE='SYS$INPUT',STATUS='OLD',FORM='UNFORMATTED')
C	READ (37) IBUF
C	XDIM = IBUF(22)			! Length of each scan line
C	XDIMBYTES = ((XDIM + 15) / 16) * 2	! Ditto in bytes, word aligned
C	YDIM = IBUF(23)			! Vertical dimension of bitmap
C	TOTAL_NUM_BITS = XDIM * YDIM	!Total number of pixels
C	NUM_BITS_ON = 0			!Initialize number of bits on counter
C
C Read in the rest of the image
C
C	READ (37) BITMAP
C	BITMAP_CTR = 1		! Keeps track of where we are in a record
C
C	DO I = 1, YDIM				! Loop for each scan line
C		DO J = 1, XDIMBYTES		! Loop for bytes in scan line
C
C Check to see if we need the last byte or not
C
C		  IF (J * 8 .GT. XDIM + 8) GOTO 100
C
C Here we check to see if we should force clear the remainder of a byte
C to eliminate spurious output on the plotter
C
C		  IF (J * 8 .GT. XDIM) THEN
C
C BYTCLR is a macro routine:  BYTCLR(N,M) where
C				N = actual byte
C				M = number of right hand bits to clear
C
C		    CALL BYTCLR(BITMAP(BITMAP_CTR),(J * 8) - XDIM)
C		  ENDIF
C
C Test our bytes and total pixels that are black
C BYTADD is a macro routine:  BYTADD(N,M) where
C				N = actual byte
C				M = black pixel counter (increases)
C
C		  CALL BYTADD(BITMAP(BITMAP_CTR),NUM_BITS_ON)
C
C100		  BITMAP_CTR = BITMAP_CTR + 1	! Increment our counter
C		  IF (BITMAP_CTR .GT. 512) THEN !If > 512, get next record
C		    READ (37) BITMAP
C		    BITMAP_CTR = 1
C		  ENDIF
C		END DO
C	END DO
C	CLOSE (UNIT=37)
C
C This is the section where the actual output is done.  There are some IF
C statements here which are commented out but can be commented in to reverse
C video the output.
C
C Open out file
C
	OPEN (UNIT=37,FILE='SYS$INPUT',STATUS='OLD',FORM='UNFORMATTED')
C
C Read in first record
C
	READ (37) IBUF
	XDIM = IBUF(22)			! Length of each scan line
	XDIMBYTES = ((XDIM + 15) / 16) * 2	! Ditto in bytes, word aligned
	YDIM = IBUF(23)			! Vertical dimension of bitmap
C
C Start reading in bitmap
C
	READ (37) BITMAP
	BITMAP_CTR = 1			!Initialize our byte counter
C
	DO I = 1, YDIM				! Loop for each scan line
		DO J = 1, XDIMBYTES		! number of bytes/scan line
C
C Check to see if we need the last byte or not
C
		  IF (J * 8 .GT. XDIM + 8) GOTO 200
C
C Check to see if we have more black pixels than white
C
C		  IF(NUM_BITS_ON .GT. TOTAL_NUM_BITS / 2) THEN
C if we do, reverse video the byte and swap the order of the bits in each byte
C
C BYTSWAP and BYTSWAPR are macro routines that take an input byte, swap
C the order of the bits in each byte (unsure why), and then replicate the
C new byte out to word length (double the pixels) as the Versatec has high
C resolution (twice as much as Vaxstation.
C
C BYTSWAPR reverse videos the byte.
C
C		    CALL BYTSWAPR(BITMAP(BITMAP_CTR),IPLOT((J*2)-1))
C		  ELSE
		    CALL BYTSWAP(BITMAP(BITMAP_CTR),IPLOT((J*2)-1))
C		  ENDIF
C
C Here we check to see if we should force clear the remainder of a byte
C to eliminate spurious output on the plotter
C
		  IF (J * 8 .GT. XDIM) THEN
C
C BYTCLR is a macro routine:  BYTCLRW(N,M) where
C				N = actual byte
C				M = number of right hand bits to clear
C
		     CALL BYTCLRW(IPLOT((J*2)-1),((J * 8) - XDIM) * 2)
		  ENDIF
C
C somehow our byte pair order is swapped so we switch it back
C
		  TEMP = IPLOT((J*2)-1)
		  IPLOT((J*2)-1) = IPLOT(J*2)
		  IPLOT(J*2)=TEMP
C
200		  BITMAP_CTR = BITMAP_CTR + 1	!Increment our byte counter
		  IF (BITMAP_CTR .GT. 512) THEN !if end of record, get new one
		    READ (37) BITMAP
		    BITMAP_CTR = 1
		  ENDIF
		END DO
C
C These are the output routines for the Versatec plotter.  In order to
C use these, you must have Versatecs object file SYS$SHARE:OUTPUT.OBJ
C We call OWAIT to synchronize our output.
C
		CALL OUTPUT(IPLOT,NBYTES)
		CALL OWAIT
		CALL OUTPUT(IPLOT,NBYTES)	!Call it again since we're
						!doubling the output
		CALL OWAIT
	END DO
	CLOSE (UNIT=37)
	CALL OUTPUT(4,0)		!Form feed the Versatec
C
	CALL DETACH			!Detach our Versatec
C
	STOP
	END
