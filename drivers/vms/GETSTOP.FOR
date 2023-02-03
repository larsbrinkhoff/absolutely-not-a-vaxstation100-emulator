	subroutine GETSTOP ( CONTROLLER )
	implicit integer*4 (A-Y)
	byte CONTROLLER

	type 100
100	format ('$Stop WHICH ACP?  Enter the letter > ')
	accept 200, CONTROLLER
200	format (A1)
	return
	end
