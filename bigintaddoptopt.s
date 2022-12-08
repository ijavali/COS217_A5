//----------------------------------------------------------------------
// bigintadd.s
// Author: Jack Zhang and Ishaan Javali
//----------------------------------------------------------------------

        .section .rodata

//----------------------------------------------------------------------

        .section .data

//----------------------------------------------------------------------

        .section .bss
        
//----------------------------------------------------------------------

        .section .text

.equ OADDEND1_OFFSET, 8
.equ OADDEND2_OFFSET, 16
.equ OSUM_OFFSET, 24
.equ ULCARRY_OFFSET, 32
.equ ULSUM_OFFSET, 40
.equ LINDEX_OFFSET, 48
.equ LSUMLENGTH_OFFSET, 56
.equ SIZEOFULONG, 8
.equ LLENGTH_OFFSET, 0
.equ AULDIGITS_OFFSET, 8
.equ BIGINT_ADD_BYTECOUNT, 64
.equ TRUE, 1
.equ FALSE, 0
.equ MAX_DIGITS, 32768


  .global BigInt_add
oAddend1 .req x19
oAddend2 .req x20
oSum .req x21
ulCarry .req x22
ulSum .req x23
lIndex .req x24
lSumLength .req x25

BigInt_add:
    sub sp, sp, BIGINT_ADD_BYTECOUNT
    str x30, [sp]

    str x19, [sp, OADDEND1_OFFSET]
    str x20, [sp, OADDEND2_OFFSET]
    str x21, [sp, OSUM_OFFSET]
    str x22, [sp, ULCARRY_OFFSET]
    str x23, [sp, ULSUM_OFFSET]
    str x24, [sp, LINDEX_OFFSET]
    str x25, [sp, LSUMLENGTH_OFFSET]

    mov oAddend1, x0
    mov oAddend2, x1
    mov oSum, x2

    #lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr x0, [oAddend1]
    ldr x1, [oAddend2]
    cmp x0, x1
    ble else1
        mov lSumLength, x0
        b endifLarger
    else1:
        mov lSumLength, x1
    endifLarger:

    #if (oSum->lLength <= lSumLength) goto endif1;
    ldr x0, [oSum]
    cmp x0, lSumLength
    ble endif1

    #memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    mov x0, oSum
    add x0, x0, AULDIGITS_OFFSET
    mov x1, SIZEOFULONG
    mov x2, MAX_DIGITS
    mul x2, x2, x1
    mov x1, 0
    bl memset

    #endif1: 
    endif1:

    #ulCarry = 0;
      # mov ulCarry, 0
    clc

    #lIndex = 0;
    mov lIndex, 0

    #loop: 
    #if (lIndex >= lSumLength) goto loopEnd;
    cmp lIndex, lSumLength
    bge loopEnd
    loop:

        # ulSum = 0
        mov ulSum, 0
        mov x0, oAddend1
        mov x1, lIndex
        lsl x1, x1, 3
        add x0, x0, AULDIGITS_OFFSET
        add x0, x0, x1
        ldr x0, [x0]

        # ulSum = ulSum + aulDigits[lIndex] + C
        adcs ulSum, ulSum, x0

        # ulCarry = 0 not needed because cmp replaces c anyways
        # if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2
        # we flip the result of cmp.
        cmp ulSum, x0
        mov x0, 0
        adds x0, x0, x0
        mov x1, 1
        sub x0, x1, x0 # now x0 contains flipped C
        cmp x0, 1 # now c contains x0 contents

        #ulCarry = 1;
        # mov ulCarry, 1

        #endif2:
        endif2:
            #ulSum += oAddend2->aulDigits[lIndex];
            mov x0, oAddend2
            mov x1, lIndex
            lsl x1, x1, 3
            add x0, x0, AULDIGITS_OFFSET
            add x0, x0, x1
            ldr x0, [x0]
            add ulSum, ulSum, x0

            mov x0, 0 
            adds x0, x0, x0  # stores C into x0
            cmp x0, 1
            bhs endif6 
                # if original c / ulCarry = 0, then flip c after doing cmp
                cmp ulSum, x0
                mov x0, 0
                adds x0, x0, x0
                mov x1, 1
                sub x0, x1, x0 # now x0 contains flipped C
                cmp x0, 1 # now c contains x0 contents
                b endif3
            endif6:
                # if original c / ulCarry >= 1 (hence c = 1)
                # we want to keep c at 1.

        #endif3:
        endif3:
            #oSum->aulDigits[lIndex] = ulSum;
            mov x0, oSum
            add x0, x0, AULDIGITS_OFFSET
            mov x1, lIndex
            lsl x1, x1, 3
            add x0, x0, x1
            str ulSum, [x0]

            #lIndex++;
            add lIndex, lIndex, 1

        #goto loop;
        #if (lIndex < lSumLength) goto loop;
        cmp lIndex, lSumLength
        blt loop

    #loopEnd:
    loopEnd:

    #if (ulCarry == 0) goto endif4;
    mov x0, 0
    adds x0, x0, x0
    cmp x0, 0
    beq endif4

    #if (lSumLength != MAX_DIGITS) goto endif5;
    mov x0, MAX_DIGITS
    cmp lSumLength, x0
    bne endif5

    #return FALSE;
    mov w0, FALSE
    ldr x30, [sp]
    ldr x19, [sp, OADDEND1_OFFSET]
    ldr x20, [sp, OADDEND2_OFFSET]
    ldr x21, [sp, OSUM_OFFSET]
    ldr x22, [sp, ULCARRY_OFFSET]
    ldr x23, [sp, ULSUM_OFFSET]
    ldr x24, [sp, LINDEX_OFFSET]
    ldr x25, [sp, LSUMLENGTH_OFFSET]
    add sp, sp, BIGINT_ADD_BYTECOUNT
    ret

    #endif5:
    endif5:

    #oSum->aulDigits[lSumLength] = 1;
    mov x0, oSum
    add x0, x0, AULDIGITS_OFFSET
    mov x1, lSumLength
    lsl x1, x1, 3
    add x0, x0, x1
    mov x1, 1
    str x1, [x0]

    #lSumLength++;
    add lSumLength, lSumLength, 1

    #endif4:
    endif4:

    #oSum->lLength = lSumLength;
    str lSumLength, [oSum]

    #return TRUE;
    mov w0, TRUE
    ldr x30, [sp]
    ldr x19, [sp, OADDEND1_OFFSET]
    ldr x20, [sp, OADDEND2_OFFSET]
    ldr x21, [sp, OSUM_OFFSET]
    ldr x22, [sp, ULCARRY_OFFSET]
    ldr x23, [sp, ULSUM_OFFSET]
    ldr x24, [sp, LINDEX_OFFSET]
    ldr x25, [sp, LSUMLENGTH_OFFSET]
    add sp, sp, BIGINT_ADD_BYTECOUNT
    ret
