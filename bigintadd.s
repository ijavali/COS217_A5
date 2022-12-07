.equ FALSE, 0
.equ TRUE, 1
.equ OADDEND1, 48
.equ ULCARRY, 24

# Must be a multiple of 32
.equ BIGINT_LARGER_BYTECOUNT, 32
.equ LLENGTH1_OFFSET, 8
.equ LLENGTH2_OFFSET, 16
.equ LLARGER_OFFSET, 24

# static long BigInt_larger(long lLength1, long lLength2)
BigInt_larger:
    sub sp, sp, BIGINT_LARGER_BYTECOUNT
    str x30, [sp]
    str x0, [sp, LLENGTH1_OFFSET]
    str x1, [sp, LLENGTH2_OFFSET]
    # TODO: cmp x0, x1
    # long lLarger;
    # if (lLength1 > lLength2)
    cmp [sp, LLENGTH1_OFFSET], [sp, LLENGTH2_OFFSET]
    ble else1
        # lLarger = lLength1;
        str x0, [sp, LLARGER_OFFSET]
    # else
    else1:
        # lLarger = lLength2;
        str x1, [sp, LLARGER_OFFSET]
    
    # question: https://www.cs.princeton.edu/courses/archive/fall22/cos217/precepts/16assemlang/assemlang.pdf
    # ^^^ says 2nd parameter is addr. which is sp + LLARGER_OFFSET
    # [sp, LLARGER_OFFSET] is technically a value (the contents at that memory address)
    # Is the PDF just not comprehensive in the permissible parameters?
    # return lLarger;
    ldr x0, [sp, LLARGER_OFFSET]
    ldr x30, [sp]
    add sp, sp, MAIN_STACK_BYTECOUNT
    ret