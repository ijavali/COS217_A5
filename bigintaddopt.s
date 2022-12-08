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

    # why don't we use x0, x1, x2?
    # did the programmers say that we will define this to be a good convention
    # for everyone to follow
    # also what does it mean by memory? how is this any better/different from what we 
    # were doing before where we were using the registers to load and stuff.
    str x19, [sp, LLENGTH1_OFFSET]
    str x20, [sp, LLENGTH2_OFFSET]
    str x21, [sp, OSUM_OFFSET]

    mov x19, x0
    mov x20, x1

    # if (lLength1 <= lLength2) goto else1;
    cmp x19, x20
    ble else1
        # lLarger = lLength1;
        mov x21, x19
        b endifLarger
    # else
    else1:
        # lLarger = lLength2;
        mov x21, x20
    
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

    str x19, [sp, OADDEND1_OFFSET]
    str x20, [sp, OADDEND2_OFFSET]
    str x21, [sp, OSUM_OFFSET]
    str x22, [sp, ULCARRY_OFFSET]
    str x23, [sp, ULSUM_OFFSET]
    str x24, [sp, LINDEX_OFFSET]
    str x25, [sp, LSUMLENGTH_OFFSET]

    mov x19, x0
    mov x20, x1
    mov x21, x2

    #lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    mov x0, x19
    ldr x0, [x0]
    mov x1, x20
    ldr x1, [x1]
    bl BigInt_larger
    mov x25, x0

    #if (oSum->lLength <= lSumLength) goto endif1;
    mov x0, x21
    ldr x0, [x0]
    cmp x0, x25
    ble endif1

    #memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    mov x0, x21
    add x0, x0, AULDIGITS_OFFSET
    mov x1, 0
    mov x2, MAX_DIGITS
    mov x3, SIZEOFULONG
    mul x2, x2, x3
    bl memset

    #endif1: 
    endif1:

    #ulCarry = 0;
    mov x22, 0

    #lIndex = 0;
    mov x24, 0

    #loop: 
    loop:

        #if (lIndex >= lSumLength) goto loopEnd;
        cmp x24, x25
        bge loopEnd

        #ulSum = ulCarry;
        mov x23, x22

        #ulCarry = 0;
        mov x22, 0

        #ulSum += oAddend1->aulDigits[lIndex];
        mov x0, x19
        mov x1, x24
        lsl x1, x1, 3
        add x0, x0, AULDIGITS_OFFSET
        add x0, x0, x1
        ldr x0, [x0]
        add x23, x23, x0

        #if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
        cmp x23, x0
        bhs endif2

        #ulCarry = 1;
        mov x22, 1

        #endif2:
        endif2:
            #ulSum += oAddend2->aulDigits[lIndex];
            mov x0, x20
            mov x1, x24
            lsl x1, x1, 3
            add x0, x0, AULDIGITS_OFFSET
            add x0, x0, x1
            ldr x0, [x0]
            add x23, x23, x0

            #if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3;
            cmp x23, x0
            bhs endif3

            #ulCarry = 1;
            mov x22, 1

        #endif3:
        endif3:
            #oSum->aulDigits[lIndex] = ulSum;
            mov x0, x21
            add x0, x0, AULDIGITS_OFFSET
            mov x1, x24
            lsl x1, x1, 3
            add x0, x0, x1
            str x23, [x0]

            #lIndex++;
            add x24, x24, 1

        #goto loop;
        b loop

    #loopEnd:
    loopEnd:

    #if (ulCarry != 1) goto endif4;
    mov x0, 1
    cmp x22, x0
    bne endif4

    #if (lSumLength != MAX_DIGITS) goto endif5;
    mov x0, MAX_DIGITS
    cmp x25, x0
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
    mov x0, x21
    add x0, x0, AULDIGITS_OFFSET
    mov x1, x25
    lsl x1, x1, 3
    add x0, x0, x1
    mov x1, 1
    str x1, [x0]

    #lSumLength++;
    add x25, x25, 1

    #endif4:
    endif4:

    #oSum->lLength = lSumLength;
    mov x21, x25

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