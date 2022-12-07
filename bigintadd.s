.equ FALSE, 0
.equ TRUE, 1
.equ OADDEND1, 48
.equ ULCARRY, 24

# Must be a multiple of 32
.equ BIGINT_LARGER_BYTECOUNT, 32

BigInt_larger:
    sub sp, sp, BIGINT_LARGER_BYTECOUNT
    str x30, [sp] 



