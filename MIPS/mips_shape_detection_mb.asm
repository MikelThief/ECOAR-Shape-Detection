##############################
#                            #
#     ECOAR MIPS PROJECT     #
#            A2              #
#                            #
#        Michal Bator        #
#    ECOAR Winter sem 2017   #
##############################

# Macro for scanning the BMP for black pixels loop body
.macro scanForBlackPixel
	lb 	$t0, ($t3)
	beqz	$t0, blackPixelFound
	add	$t3, $t3, 3	
.end_macro


.data
.include "MAF.asm"
NameOfFile:	.space	128

buffer:		.space 	2 				# for proper header alignment in data section
header: 		.space 	54				# the bmp file header size
width:		.word	320				# header+18
height:		.word	240				# header+22
.text
main:

		xor		$t0, $t0, $t0		# clearing temp registers
		xor		$t1, $t1, $t1
		xor		$t2, $t2, $t2
		xor		$t3, $t3, $t3
		xor		$t4, $t4, $t4
		xor		$t5, $t5, $t5
		xor		$t6, $t6, $t6
		xor		$t7, $t7, $t7
		xor		$s0, $s0, $s0
		xor		$s1, $s1, $s1
		xor		$s2, $s2, $s2
		xor		$s3, $s3, $s3


	# begin the program, print prompt
	println_instant_str("*********************************************")
	println_instant_str("*      ECOAR PROJECT A2 - Michal Bator      *")
	println_instant_str("*********************************************")
	print_instant_str("Enter the file name: ")

	read_str(NameOfFile, 128)

	# open input file for reading
	println_instant_str("Opening file for reading...")
	li	$v0, 13					# syscall-13 open file
	la	$a0, NameOfFile				# load filename address
	li 	$a1, 0					# 0 flag for reading the file
	li	$a2, 0					# mode 0
	syscall
	
							# $v0 contains the file descriptor
	bltz	$v0, fileError				# if $v0==-1, there exsists a descriptor error or file is inaccessible and an exception is raised

	move	$s0, $v0					# save the file descriptor from $v0 for closing the file

	# read the header data
	println_instant_str("Reading header data...")
	li	$v0, 14					# Read from file
	move	$a0, $s0					# load the file descriptor
	la	$a1, header				# load header address to store
	li	$a2, 54					# Read first 54 bytes of the file
	syscall

	check_if_BMP(bitmapError)
	
	
	# check if BMP has proper resolution
	println_instant_str("Checking resolution...")
	lw	$t0, width				# width (320) == $t0
	lw 	$s1, header+18				# read the file width from the header information (offset of 18) - need to read only 2 bytes
	bne	$t0, $s1, resolutionError			# if not equal we raise an exception
	
	lw	$t0, height				# height (240) == $t0
	lw	$s2, header+22				# read the file height from the header information (offset of 22) - need to read only 2 bytes
	bne	$t0, $s2, resolutionError			# if not equal raise an exception

	# check if BMP has proper structure
	println_instant_str("Checking structure...")
	check_24b_BMP(formatError, header)
	
	println_instant_str("Loading PixelArray to heap...")	
	lw	$s3, header+34				# store structure pointer to data-size section
	
	# read image data into array - allocationg heap memory
	li	$v0, 9					
	move	$a0, $s3				
	syscall						
	move	$s4, $v0				

	li	$v0, 14					# syscall-14, read from file
	move	$a0, $s0					# load the file descriptor
	move	$a1, $s4					# load base address of array
	move	$a2, $s3					# load size of data section
	syscall

	# close the file
	println_instant_str("Closing file...")
closeFile:
	li	$v0, 16					# Close file
	move	$a0, $s0				
	syscall
	
######################################################################################
#                                  MAIN PROGRAM                                      #
######################################################################################


SetUp:
	move	$t3, $s4					# load base address of the image
	li	$t4, 0					# Pointer to first column of black frame
	li	$t6, 0					# Pointer to last column of black frame
	move	$t5, $s1					# width offset
	mul	$t5, $t5, 3				# multiply to get the number of BGR 'three's in a row
	
	println_instant_str("Scanning for black pixel...")
	for($t9, 1, 76320, scanForBlackPixel)			# scanning whole image for black pixel. Exit loop if found. 76320 is enough iteration to be sure that there is no shape.		
	j noShape						# no shape detected if loop finishes by itself
	
blackPixelFound:
	println_instant_str("Black pixel found...")
	move	$t4,$t3 		# beginning of black frame stored in $t4
	
	println_instant_str("Finding end of the black frame...")
findWidthOfFrame:
	lb 	$t0, ($t3)
	bnez 	$t0, pre
	add	$t3, $t3, 3
	j	findWidthOfFrame
	
pre:	# ($t4;$t6) - beginning and end of black frame against registers in ordered pair
	add	$t4,$t4,$t5
	sub	$t3, $t3, 3		
	move	$t6,$t3
	add	$t6,$t6,$t5
	move	$t3,$t4		#next row in black frame
loopBlackRow:
	lb 	$t0, ($t3)		
	beq	$t3,$t6, switchNextRow
	bnez	$t0, whitePixelFound
	add	$t3, $t3, 3
	j	loopBlackRow
switchNextRow:
	println_instant_str("Switching to next row.")
	add	$t6,$t6,$t5
	add	$t4,$t4,$t5
	move	$t3,$t4
	j	loopBlackRow
whitePixelFound:
	sub	$t3,$t3,3		# make pixel pointer come back to last black pixel in a row
	
	println_instant_str("Distinguishing shape...")
checkShape:
	lb 	$t0, ($t3)
	bnez	$t0, shape2
	add	$t3,$t3,3
	lb 	$t0, ($t3)	
	beqz	$t0, shape1
	
	sub	$t3,$t3,3
	add	$t3,$t3,$t5
	j	checkShape

shape1:
	println_instant_str("")
	println_instant_str("Shape 1 detected.")
	j end
shape2:
	println_instant_str("")
	println_instant_str("Shape 2 detected.")
	j end
noShape:
	println_instant_str("")
	println_instant_str("No shape detected.")
	j end

######################################################################################
#                                        END                                         #
######################################################################################		


	# end the program
end:
	j main  		# by uncommenting this line we may turn on infinite reloading after recognition.
	#exit

	# print I/O file error message
fileError:
	raise_exception("Descriptor does not indicate BMP or the file is inaccessible. Restarting.....")
	
	# print BMP wrong format error message
formatError:
	raise_exception("Given BMP is not 24 bit depth one without compression. Restarting.....")

	# print BMP wrong structure error message
bitmapError:
	raise_exception("Structure does not match BMP file. Restarting.....")

	# print BMP wrong resolution error message
resolutionError:
	raise_exception("Given BMP has wrong resolution. It should be 320x240. Restarting.....")
	
.include "MAF_extra.asm"
