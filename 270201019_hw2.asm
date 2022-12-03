##############################################################
#Dynamic array
##############################################################
#   4 Bytes - Capacity
#	4 Bytes - Size
#   4 Bytes - Address of the Elements
##############################################################

##############################################################
#Song
##############################################################
#   4 Bytes - Address of the Name (name itself is 64 bytes)
#   4 Bytes - Duration
##############################################################


.data
space: .asciiz " "
newLine: .asciiz "\n"
tab: .asciiz "\t"
menu: .asciiz "\n● To add a song to the list-> \t\t enter 1\n● To delete a song from the list-> \t enter 2\n● To list all the songs-> \t\t enter 3\n● To exit-> \t\t\t enter 4\n"
menuWarn: .asciiz "Please enter a valid input!\n"
name: .asciiz "Enter the name of the song: "
duration: .asciiz "Enter the duration: "
name2: .asciiz "Song name: "
duration2: .asciiz "Song duration: "
emptyList: .asciiz "List is empty!\n"
noSong: .asciiz "\nSong not found!\n"
songAdded: .asciiz "\nSong added.\n"
songDeleted: .asciiz "\nSong deleted.\n"

copmStr: .space 64

sReg: .word 3, 7, 1, 2, 9, 4, 6, 5
songListAddress: .word 0 #the address of the song list stored here!

.text 
main:

	jal initDynamicArray
	sw $v0, songListAddress
	
	la $t0, sReg
	lw $s0, 0($t0)
	lw $s1, 4($t0)
	lw $s2, 8($t0)
	lw $s3, 12($t0)
	lw $s4, 16($t0)
	lw $s5, 20($t0)
	lw $s6, 24($t0)
	lw $s7, 28($t0)

menuStart:
	la $a0, menu    
    li $v0, 4
    syscall

	li $v0,  5
    syscall
	li $t0, 1
	beq $v0, $t0, addSong
	li $t0, 2
	beq $v0, $t0, deleteSong
	li $t0, 3
	beq $v0, $t0, listSongs
	li $t0, 4
	beq $v0, $t0, terminate
	
	la $a0, menuWarn    
    li $v0, 4
    syscall
	b menuStart
	
addSong:
	jal createSong
	lw $a0, songListAddress
	move $a1, $v0
	jal putElement
    syscall
	b menuStart
	
deleteSong:
	lw $a0, songListAddress
	jal findSong
	lw $a0, songListAddress
	move $a1, $v0
	jal removeElement
	b menuStart
	
listSongs:
	lw $a0, songListAddress
	jal listElements
	b menuStart
	
terminate:
	la $a0, newLine		
	li $v0, 4
	syscall
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	move $a0, $s1
	syscall
	move $a0, $s2
	syscall
	move $a0, $s3
	syscall
	move $a0, $s4
	syscall
	move $a0, $s5
	syscall
	move $a0, $s6
	syscall
	move $a0, $s7
	syscall
	
	li $v0, 10
	syscall


initDynamicArray:
	
	#Write your instructions here!
	li $v0, 9 # dynamic memory alloc.
	li $a0, 12 # of 12 bytes
	syscall
	li $t0, 2 # capacity
	sw $t0, 0($v0) # store the capacity
	li $t0, 0 # size
	sw $t0, 4($v0) # store the size
	move $t0, $v0 # store the dynamic array to t0 temporarily
	li $v0, 9
	li $a0, 8 # this will be address of elements, 2 bytes for capacity of 2
	syscall
    sw $zero, 0($v0)
    sw $zero, 4($v0)
	sw $v0, 8($t0)
	move $v0, $t0 # save dynamic array to v0 again.
	jr $ra

putElement:
	
	#Write your instructions here!
	lw $t0, 4($a0)		# size of dynamic array
	sll $t1, $t0, 2		# t1 = t0 * 4 (byte)
    lw $t2, 8($a0)      # base address of address array
    add $t1, $t2, $t1   # the location which song address will be inserted.
    sw $a1, 0($t1)      # element is inserted.
    addi $t0, $t0, 1	# size++
    sw $t0, 4($a0)		# store new size
    lw $t1, 0($a0)      # capacity of dynamic array

    bne $t0, $t1, exitPutElement   # if size != capacity, return
    sll $t3, $t1, 1     # t3 = capacity * 2 (new capacity)
	sw $t3, 0($a0)
    move $t9, $a0       # store dynamic array into t9 temporarily
    li $v0, 9           # creation of new address array
	sll $t5, $t3, 2
    move $a0, $t5       # of size of 2 * old_capacity
    syscall             # new address array is stored at $v0
    move $a0, $t9       # restore dynamic array
    li $t4, 0           # loopCopyElements counter
    loopCopyElements:
        beq $t4, $t1, loopFillZeros    # if counter != old_capacity, fill newly added elements with zeroes
        sll $t5, $t4, 2     # t5 = 4*counter (byte addressing)
        add $t5, $t2, $t5   # t5 += base address of address array (location of element which will be copied to newly created address array)
        lw $t6, 0($t5)      # element stored in t6
        sub $t5, $t5, $t2   # t5 is again 4 * counter
        add $t5, $t5, $v0   # t5 += base address of newly created address aray
        sw $t6, 0($t5)      # element t6 stored in new array
		sub $t5, $t5, $v0
        addi $t4, $t4, 1
        b loopCopyElements
    loopFillZeros: # at this point, t4 will be old_capacity, so we can continue using t4 as counter
        beq $t4, $t3, ePutElement # if counter != new_capacity, fill rest of new address array with zeros.
        sll $t5, $t4, 2
        add $t5, $t5, $v0
        sw $zero, 0($t5)    # zero stored into newly created address array
        addi $t4, $t4, 1
        b loopFillZeros
    ePutElement:
        sw $v0, 8($a0)
    exitPutElement:
		la $a0, songAdded    
    	li $v0, 4
	    jr $ra

removeElement:
	
	#Write your instructions here!
	li $t0, -1			# -1 for not found
	beq $a1, $t0, notFound

	lw $t0, 4($a0)		# t0 = size of dynamic array
	addi $t0, $t0, -1 	# t0-- (size--)
	# sw $t0, 4($a0)
	bne $a1, $t0, shift	# if song_index != size-1, removal is not from end, so shift is required

	lw $t1, 8($a0)		# t1 is address array
	sll $t2, $a1, 2		# t2 = 4 * index_of_song (byte)
	add $t2, $t2, $t1	# t2 += t1 (location of the song)
	sw $zero, 0($t2)
	sw $zero, 4($t2)

	b capCheck
	shift:
		move $t1, $a1 		# curent index
		lw $t4, 8($a0)		# t4 is address array
		loopShift:
			beq $t1, $t0, capCheck
			sll $t2, $t1, 2		# t2 = 4 * currIndex (byte)
			add $t2, $t2, $t4	# t2 = location of the song to be replaced by next song
			addi $t3, $t2, 4	# t3 = t2 + 4 (next element)
			lw $t5, 0($t3)
			sw $t5, 0($t2)
			lw $t5, 4($t3)
			sw $t5, 4($t2)
			addi $t1, $t1, 1
			b loopShift
	capCheck:
		lw $t1, 0($a0)	# t1 = capacity of dynamic array
		srl $t2, $t1, 1	# t2 = t1/2 (integer division)
		bge $t0, $t2, exitRemove
		li $t4, 1
		beq $t0, $t4, exitRemove
		beq $t0, $zero, exitRemove
		sw $t2, 0($a0)	# capacity of the dynamic array reduced into half
		lw $t4, 8($a0)	# t4 is address array

		move $t9, $a0 	# t9 is dynamic array temporarily
		li $v0, 9
		sll $t3, $t2, 2	# for bytes
		move $a0, $t3
		syscall
		move $a0, $t9	# restore dynamic array

		li $t3, 0		# counter
		loopResize:
			beq $t3, $t0, exitLoopResize
			sll $t5, $t3, 2		# t5 = 4 * counter (byte)
			add $t5, $t4, $t5	# t5 += base of address array
			lw $t6, 0($t5)		# element stored in t6
			sub $t5, $t5, $t4
			add $t5, $t5, $v0
			sw $t6, 0($t5)		# element t6 stored in new array
			sub $t5, $t5, $v0
			addi $t3, $t3, 1
			b loopResize
		exitLoopResize:
			sll $t5, $t3, 2
			add $t5, $t5, $v0
			sw $zero, 0($t5)
			sw $v0, 8($a0)
			b exitRemove
	notFound:
		la $a0, noSong
		li $v0, 4
		syscall
		jr $ra
	exitRemove:
	sw $t0, 4($a0)
	la $a0, songDeleted    
    li $v0, 4
    syscall
	jr $ra

listElements:
	
	#Write your instructions here!
	addi $sp, $sp, -4	# a function call will be made,
	sw $ra, 0($sp)		# so we need te preserve $ra

	move $t0, $a0 	# t0 is dynamic array now
	lw $t1, 4($t0) 	# t1 is size of dynamic array
	lw $t2, 0($t0)	# t2 is capacity of dynamic array
	lw $t3, 8($t0)	# t3 is first element of address array
	li $t4, 0		# counter
	printLoop:
		beq $t4, $t1, exitListElements
		sll $t5, $t4, 2	# t5 = 4 * t4 (byte)
		add $t5, $t5, $t3	# t5 is address of current element to be printed
		lw $a0, 0($t5)
		jal printElement
		addi $t4, $t4, 1
		b printLoop
	exitListElements:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	jr $ra

compareString:
	
	#Write your instructions here!
	li $t5, 0	# counter
	compLoop:
		beq $t5, $a2, exitCmp
		add $t6, $t5, $a0
		add $t7, $t5, $a1
		lb $t6, 0($t6)
		lb $t7, 0($t7)
		sub $t8, $t6, $t7

		li $v0, 1
		bne $t8, $zero, notEqual
		addi $t5, $t5, 1
		b compLoop
	notEqual:
		li $v0, 0
		jr $ra
	exitCmp:
		li $v0, 1
		jr $ra
	
printElement:
	
	#Write your instructions here!
	addi $sp $sp, -4
	sw $ra, 0($sp)
	jal printSong
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

createSong:
	
	#Write your instructions here!
	la $a0, name # print text
	li $v0, 4
	syscall
	li $v0, 9
	li $a0, 64
	syscall
	move $t2, $v0

	move $a0, $t2
	li $a1, 63 # max num of characters
	li $v0, 8
	syscall
	la $a0, duration # print text
	li $v0, 4
	syscall

	li $v0, 5
	syscall
	move $t1, $v0 # t1 = duration of song

	li $v0, 9 # allocate 8 bytes of space
	li $a0, 8 
	syscall
	sw $t2, 0($v0)
	sw $t1, 4($v0)
	jr $ra

findSong:
	
	#Write your instructions here!
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	move $t0, $a0	# dynamic array is at t0 
	la $a0, name 	# print text
	li $v0, 4
	syscall
	la $a0, copmStr
	li $a1, 63
	li $v0, 8
	syscall
	la $a0, copmStr
	li $t1, 0 		# counter
	lw $t2, 8($t0)	# t2 is the base of the address array
	lw $t3, 4($t0)	# t3 is the size of the dynamic array
	li $v0, -1		# v0 as -1 (-1 for no element)
	li $a2, 10
	findSongLoop:
		beq $t1, $t3, exitFindSongLoop
		sll $t4, $t1, 2		# t4 is the 4 * counter (byte)
		add $t4, $t4, $t2 	# t4 += t2, location of song to be checked
		lw $a1, 0($t4)		# a1 = address of the song to be checked
		lw $a1, 0($a1)
		jal compareString
		li $t4, 1			# t4 = 1 for checking
		beq $v0, $t4, songFound
		addi $t1, $t1, 1
		b findSongLoop
	songFound:
		move $v0, $t1
		move $a0, $t0
		b exitFound
	exitFindSongLoop:
		li $v0, -1
	exitFound:		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		move $a0, $t0
		jr $ra

printSong:
	
	#Write your instructions here!
	lw $t8, 0($a0)
	lw $t9, 4($a0) # duration
	
	li $v0, 4
	la $a0, name2
	syscall
	move $a0, $t8
	syscall

	la $a0, duration2
	syscall

	li $v0, 1
	move $a0, $t9
	syscall
	la $a0, newLine
	li $v0, 4
	syscall
	jr $ra

additionalSubroutines:



