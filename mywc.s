# TODO: make enum
.equ EOF, -1
.equ FALSE, 0
.equ TRUE, 1

# Must be a multiple of 16
.equ MAIN_STACK_BYTECOUNT, 16

  .section .rodata
format:   
   .string "%7ld %7ld %7ld\n"

# This is for the global variables
  .section .data
lLineCount: .quad 0
lWordCount: .quad 0
lCharCount: .quad 0
iInWord: .word FALSE

  .section .bss
iChar: .skip 4 

  .section .text
  .global main
main:
   sub sp, sp, MAIN_STACK_BYTECOUNT
   str x30, [sp]

#   adr x0, lLineCount
#   ldr x1, [x0]
#   adr x0, lWordCount
#   ldr x2, [x0]
#   adr x0, lCharCount
#   ldr x3, [x0]
#   adr x0, iChar
#   ldr x4, [x0]
#   adr x0, iInWord
#   ldr x5, [x0]


   loop1:
      # loop1:
      # if((iChar = getchar()) == EOF) goto endloop1;
      bl getchar 
      # ldrsw x0, [x2]
      #adr x0, iChar
      adr x1, iChar
      ldrsw x0, [x1]
      # str x0, [x1]
      
      cmp x0, EOF
      beq endloop1

      # lCharCount ++;
      adr x0, lCharCount
      ldr x1, [x0]
      add x0, x1, 1 

         # if(! isspace(iChar)) goto else1;
            adr x0, iChar
            ldr x0, [x0]
            bl isspace
            cmp x0, TRUE
            bne else1

            # if(!iInWord) goto endif1;
            # lWordCount++;
            # iInWord = FALSE;
            # goto endif1;
            adr x0, iInWord
            ldr x0, [x0]
            cmp x0, TRUE
            bne endif1
            adr x0, lWordCount
            ldr x1, [x0]
            add x0, x1, 1
            adr x0, iInWord
            mov x0, FALSE
            b endif1
      # else1:
      # if(iInWord) goto endif1;
      # iInWord = TRUE;
      else1:
         adr x0, iInWord
         ldr x0, [x0]
         cmp x0, TRUE
         beq endif1
         adr x0, iInWord
         mov x0, TRUE

      # endif1:
      # if(iChar != '\n') goto loop1;
      # lLineCount++;
      endif1:
         adr x0, iChar
         ldr x0, [x0]
         cmp x0, '\n'
         bne loop1
         adr x0, lLineCount
         ldr x1, [x0]
         add x0, x1, 1
         b loop1

   # endloop1:
   # if (!iInWord) goto endif2;
   # lWordCount++;
   endloop1:
      adr x0, iInWord
      ldr x0, [x0]
      cmp x0, TRUE
      bne endif2
      adr x0, lWordCount
      ldr x1, [x0]
      add x0, x1, 1
      
      endif2:
         # TODO: printf 
         adr x0, format
         bl printf
   
   mov w0, 0
   ldr x30, [sp]
   add sp, sp, MAIN_STACK_BYTECOUNT
ret
