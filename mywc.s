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
   # loop1:
   loop1:
      # if((iChar = getchar()) == EOF) goto endloop1;
      bl getchar 
      adr x1, iChar
      str w0, [x1]
      
      
      cmp w0, EOF
      beq endloop1

      # lCharCount ++;
      adr x0, lCharCount
      ldr x1, [x0]
      add x1, x1, 1 
      str x1, [x0]

         # if(! isspace(iChar)) goto else1;
            adr x1, iChar
            ldr w0, [x1]
            bl isspace
            cmp w0, TRUE
            bne else1

            # if(!iInWord) goto endif1;
            adr x1, iInWord
            ldr w0, [x1]
            cmp w0, TRUE
            bne endif1
            # lWordCount++;
            adr x0, lWordCount
            ldr x1, [x0]
            add x1, x1, 1
            str x1, [x0]
            # iInWord = FALSE;
            adr x0, iInWord
            mov w1, FALSE
            str w1, [x0]
            # goto endif1;
            b endif1
      # else1:
      else1:
         # if(iInWord) goto endif1;
         adr x1, iInWord
         ldr w0, [x1]
         cmp w0, TRUE
         beq endif1
         # iInWord = TRUE;
         adr x0, iInWord
         mov w1, TRUE
         str w1, [x0]

      # endif1:
      endif1:
         # if(iChar != '\n') goto loop1;
         adr x1, iChar
         ldr w0, [x1]
         cmp w0, '\n'
         bne loop1
         # lLineCount++;
         adr x0, lLineCount
         ldr x1, [x0]
         add x1, x1, 1
         str x1, [x0]
         b loop1

   # endloop1:
   endloop1:
   # if (!iInWord) goto endif2;
      adr x1, iInWord
      ldr w0, [x1]
      cmp w0, TRUE
      bne endif2
      # lWordCount++;
      adr x0, lWordCount
      ldr x1, [x0]
      add x1, x1, 1
      str x1, [x0]
      
      #endif2:
      endif2:
         #printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
         adr x0, format
         adr x1, lLineCount
         ldr x1, [x1]
         adr x2, lWordCount
         ldr x2, [x2]
         adr x3, lCharCount
         ldr x3, [x3]
         bl printf
   
   #return 0;
   mov w0, 0
   ldr x30, [sp]
   add sp, sp, MAIN_STACK_BYTECOUNT
ret
