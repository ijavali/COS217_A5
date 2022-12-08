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
.equ BIGINT_LARGER_BYTECOUNT, 32
.equ LLENGTH1_OFFSET, 8
.equ LLENGTH2_OFFSET, 16
.equ LLARGER_OFFSET, 24

.global BigInt_larger
# static long BigInt_larger(long lLength1, long lLength2)
BigInt_larger:
    sub sp, sp, BIGINT_LARGER_BYTECOUNT
    str x30, [sp]
    str x19, [sp, LLENGTH1_OFFSET]
    str x20, [sp, LLENGTH2_OFFSET]
    str x21, [sp, OSUM_OFFSET]

    # if (lLength1 <= lLength2) goto else1;
    cmp x19, x20
    ble else1
        # lLarger = lLength1;
        mov x21 x19
        b endifLarger
    # else
    else1:
        # lLarger = lLength2;
        mov x21 x20
    
    endifLarger:
    mov x0, x21
    ldr x30, [sp]
    ldr x19, [sp, LLENGTH1_OFFSET]
    ldr x20, [sp, LLENGTH2_OFFSET]
    ldr x21, [sp, OSUM_OFFSET]
    add sp, sp, BIGINT_LARGER_BYTECOUNT
    # return lLarger;
    ret

.global BigInt_add
BigInt_add:
    sub sp, sp, BIGINT_ADD_BYTECOUNT
    str x30, [sp]
    str x0, [sp, OADDEND1_OFFSET]
    str x1, [sp, OADDEND2_OFFSET]
    str x2, [sp, OSUM_OFFSET]

    #lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr x0, [sp, OADDEND1_OFFSET]
    ldr x0, [x0]
    ldr x1, [sp, OADDEND2_OFFSET]
    ldr x1, [x1]
    bl BigInt_larger
    str x0, [sp, LSUMLENGTH_OFFSET]

    #if (oSum->lLength <= lSumLength) goto endif1;
    ldr x0, [sp, OSUM_OFFSET]
    add x0, x0, LLENGTH_OFFSET
    ldr x0, [x0]
    ldr x1, [sp, LSUMLENGTH_OFFSET]
    cmp x0, x1
    ble endif1

    #memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr x0, [sp, OSUM_OFFSET]
    add x0, x0, AULDIGITS_OFFSET
    mov x1, 0
    mov x2, MAX_DIGITS
    mov x3, SIZEOFULONG
    mul x2, x2, x3
    bl memset

    #endif1: 
    endif1:

    #ulCarry = 0;
    mov x0, 0
    str x0, [sp, ULCARRY_OFFSET]

    #lIndex = 0;
    mov x0, 0
    str x0, [sp, LINDEX_OFFSET]

    #loop: 
    loop:

        #if (lIndex >= lSumLength) goto loopEnd;
        ldr x0, [sp, LINDEX_OFFSET]
        ldr x1, [sp, LSUMLENGTH_OFFSET]
        cmp x0, x1
        bge loopEnd

        #ulSum = ulCarry;
        ldr x0, [sp, ULCARRY_OFFSET]
        str x0, [sp, ULSUM_OFFSET]

        #ulCarry = 0;
        mov x0, 0
        str x0, [sp, ULCARRY_OFFSET]

        #ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, [sp, OADDEND1_OFFSET]
        add x0, x0, AULDIGITS_OFFSET
        ldr x1, [sp, LINDEX_OFFSET]
        ldr x0, [x0, x1, lsl 3]
        ldr x1, [sp, ULSUM_OFFSET]
        add x1, x1, x0
        str x1, [sp, ULSUM_OFFSET]

        #if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
        ldr x0, [sp, OADDEND1_OFFSET]
        add x0, x0, AULDIGITS_OFFSET
        ldr x1, [sp, LINDEX_OFFSET]
        ldr x0, [x0, x1, lsl 3]
        ldr x1, [sp, ULSUM_OFFSET]
        cmp x1, x0
        bhs endif2

        #ulCarry = 1;
        mov x0, 1
        str x0, [sp, ULCARRY_OFFSET]
        #endif2:
        endif2:
            #ulSum += oAddend2->aulDigits[lIndex];
            ldr x0, [sp, OADDEND2_OFFSET]
            add x0, x0, AULDIGITS_OFFSET
            ldr x1, [sp, LINDEX_OFFSET]
            ldr x0, [x0, x1, lsl 3]
            ldr x1, [sp, ULSUM_OFFSET]
            add x1, x1, x0
            str x1, [sp, ULSUM_OFFSET]
            #if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3;
            bhs x1, x0
            bge endif3

            #ulCarry = 1;
            mov x0, 1
            str x0, [sp, ULCARRY_OFFSET]

        #endif3:
        endif3:
            #oSum->aulDigits[lIndex] = ulSum;
            ldr x0, [sp, OSUM_OFFSET]
            add x0, x0, AULDIGITS_OFFSET
            ldr x1, [sp, LINDEX_OFFSET]
            lsl x1, x1, 3
            add x0, x0, x1
            ldr x1, [sp, ULSUM_OFFSET]
            str x1, [x0]


            #lIndex++;
            ldr x0, [sp, LINDEX_OFFSET]
            mov x1, 1
            add x0, x0, x1
            str x0, [sp, LINDEX_OFFSET]

        #goto loop;
        b loop

    #loopEnd:
    loopEnd:

    #if (ulCarry != 1) goto endif4;
    ldr x0, [sp, ULCARRY_OFFSET]
    mov x1, 1
    cmp x0, x1
    bne endif4

    #if (lSumLength != MAX_DIGITS) goto endif5;
    ldr x0, [sp, LSUMLENGTH_OFFSET]
    mov x1, MAX_DIGITS
    cmp x0, x1
    bne endif5

    #return FALSE;
    mov w0, FALSE
    ldr x30, [sp]
    add sp, sp, BIGINT_ADD_BYTECOUNT
    ret

    #endif5:
    endif5:

    #oSum->aulDigits[lSumLength] = 1;

    ldr x0, [sp, OSUM_OFFSET]
    add x0, x0, AULDIGITS_OFFSET
    ldr x1, [sp, LSUMLENGTH_OFFSET]
    lsl x1, x1, 3
    add x0, x0, x1
    mov x1, 1
    str x1, [x0]

    #lSumLength++;
    ldr x0, [sp, LSUMLENGTH_OFFSET]
    add x0, x0, 1
    str x0, [sp, LSUMLENGTH_OFFSET]

    #endif4:
    endif4:

    #oSum->lLength = lSumLength;
    ldr x0, [sp, OSUM_OFFSET]
    add x0, x0, LLENGTH_OFFSET
    ldr x1, [sp, LSUMLENGTH_OFFSET]
    str x1, [x0]

    #return TRUE;
    mov w0, TRUE
    ldr x30, [sp]
    add sp, sp, BIGINT_ADD_BYTECOUNT
    ret