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

# Constants:
.equ TRUE, 1
.equ FALSE, 0
.equ SIZEOFULONG, 8
.equ MAX_DIGITS, 32768
.equ BIGINT_LARGER_BYTECOUNT, 32
.equ BIGINT_ADD_BYTECOUNT, 64

# Offsets for BigInt_add
# Parameter stack offsets:
.equ OADDEND1_OFFSET, 8
.equ OADDEND2_OFFSET, 16
.equ OSUM_OFFSET, 24
# Local variable stack offsets:
.equ ULCARRY_OFFSET, 32
.equ ULSUM_OFFSET, 40
.equ LINDEX_OFFSET, 48
.equ LSUMLENGTH_OFFSET, 56
# Field stack offsets:
.equ LLENGTH_OFFSET, 0
.equ AULDIGITS_OFFSET, 8


#--------------------------------------------------------------
# Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
# distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
# overflow occurred, and 1 (TRUE) otherwise.
# int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
#--------------------------------------------------------------
  .global BigInt_add
# Registers for parameters
oAddend1 .req x19
oAddend2 .req x20
oSum .req x21
# Registers for local variables
ulCarry .req x22
ulSum .req x23
lIndex .req x24
lSumLength .req x25

BigInt_add:
    # Prolog
    sub sp, sp, BIGINT_ADD_BYTECOUNT
    str x30, [sp]

    str x19, [sp, OADDEND1_OFFSET]
    str x20, [sp, OADDEND2_OFFSET]
    str x21, [sp, OSUM_OFFSET]
    str x22, [sp, ULCARRY_OFFSET]
    str x23, [sp, ULSUM_OFFSET]
    str x24, [sp, LINDEX_OFFSET]
    str x25, [sp, LSUMLENGTH_OFFSET]

    # unsigned long ulCarry;
    # unsigned long ulSum;
    # long lIndex;
    # long lSumLength;

    mov oAddend1, x0
    mov oAddend2, x1
    mov oSum, x2

    # lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
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
    add x0, oSum, AULDIGITS_OFFSET
    mov x1, SIZEOFULONG
    mov x2, MAX_DIGITS
    mul x2, x2, x1
    mov x1, 0
    bl memset

    #endif1: 
    endif1:

    #ulCarry = 0;
    mov ulCarry, 0

    #lIndex = 0;
    mov lIndex, 0

    #loop: 
    #if (lIndex >= lSumLength) goto loopEnd;
    cmp lIndex, lSumLength
    bge loopEnd
    loop:
        #ulSum = ulCarry;
        mov ulSum, ulCarry

        #ulCarry = 0;
        mov ulCarry, 0

        #ulSum += oAddend1->aulDigits[lIndex];
        add x0, oAddend1, AULDIGITS_OFFSET
        ldr x0, [x0, lIndex, lsl 3]
        add ulSum, ulSum, x0

        #if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
        cmp ulSum, x0
        bhs endif2

        #ulCarry = 1;
        mov ulCarry, 1

        #endif2:
        endif2:
            #ulSum += oAddend2->aulDigits[lIndex];
            add x0, oAddend2, AULDIGITS_OFFSET
            ldr x0, [x0, lIndex, lsl 3]
            add ulSum, ulSum, x0

            #if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3;
            cmp ulSum, x0
            bhs endif3

            #ulCarry = 1;
            mov ulCarry, 1

        #endif3:
        endif3:
            #oSum->aulDigits[lIndex] = ulSum;
            add x0, oSum, AULDIGITS_OFFSET
            lsl x1, lIndex, 3
            str ulSum, [x0, x1]

            #lIndex++;
            add lIndex, lIndex, 1

        #goto loop;
        #if (lIndex < lSumLength) goto loop;
        cmp lIndex, lSumLength
        blt loop

    #loopEnd:
    loopEnd:

    #if (ulCarry != 1) goto endif4;
    cmp ulCarry, 1
    bne endif4

    #if (lSumLength != MAX_DIGITS) goto endif5;
    cmp lSumLength, MAX_DIGITS
    bne endif5

    # Epilog and return FALSE;
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
    add x0, oSum, AULDIGITS_OFFSET
    lsl x1, lSumLength, 3
    add x0, x0, x1
    mov x1, 1
    str x1, [x0] 

    #lSumLength++;
    add lSumLength, lSumLength, 1

    #endif4:
    endif4:

    #oSum->lLength = lSumLength;
    str lSumLength, [oSum]

    # Epilog and return TRUE;
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

    .size   BigInt_add, (. - BigInt_add)
