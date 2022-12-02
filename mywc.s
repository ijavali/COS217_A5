# Status:
# do the TODOs
# I think we have to do stuff with registers and addresses
# like add lWordCount, lWordCount, 1 probably isn't correct
# . it probably has to be like add x1, x1, 1 or something

# TODO: make enum
.equ EOF, -1
.equ FALSE, 0
.equ TRUE, 1

// Must be a multiple of 16
.equ MAIN_STACK_BYTECOUNT, 16

  .section .rodata
format:   
   .string "%7ld %7ld %7ld\n"

# This is for the global variables
  .section .data
lLineCount: .quad 0
lWordCount: .quad 0
lCharCount: .quad 0
iChar: .skip 4 
iInWord: .word FALSE"

  .section .text
  .global .main
main:
   sub sp, sp, MAIN_STACK_BYTECOUNT
   str x30, [sp]

   adr x0, lLineCount
   ldr x1, [x0]
   adr x0, lWordCount
   ldr x2, [x0]
   adr x0, lCharCount
   ldr x3, [x0]
   adr x0, iChar
   ldr w4, [x0]
   adr x0, iInWord
   ldr w5, [x0]


   loop1:
      # loop1:
      # if((iChar = getchar()) == EOF) goto endloop1;
      bl getchar 
      ldr w1, [w0]
      #adr x0, iChar
      str w1, [w4]
      
      cmp w4 EOF
      beq endloop1

      # lCharCount ++;
      add x3, x3, 1 

         # if(! isspace(iChar)) goto else1;
            ldr x0, [w4]
            bl isspace
            cmp x0, TRUE
            bne else1

            # if(!iInWord) goto endif1;
            # lWordCount++;
            # iInWord = FALSE;
            # goto endif1;
            cmp w5, TRUE
            bne endif1
            add x2, x2, 1
            mov w5, FALSE
            b endif1
      # else1:
      # if(iInWord) goto endif1;
      # iInWord = TRUE;
      else1:
         cmp w5, TRUE
         beq endif1
         mov w5, TRUE

      # endif1:
      # if(iChar == '\n') iLineCount++;
      # goto loop1;
      endif1:
         cmp w4, '\n'
         bne loop1
         add x1, x1, 1
         b loop1

   # endloop1:
   # if (!iInWord) goto endif2;
   # lWordCount++;
   endloop1:
      cmp w5, TRUE
      bne endif2
      add x2, x2, 1
      
      endif2:
         # TODO: printf 
         adr x0, format
         bl printf
   
   mov w0, 0
   ldr x30, [sp]
   add sp, sp, MAIN_STACK_BYTECOUNT
   ret