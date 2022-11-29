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

# This is for the global variables
  .section .data
lLineCount: .quad 0
lWordCount: .quad 0
lCharCount: .quad 0
iChar: .skip 4 
iInWord: .word FALSE

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
      # TODO if((iChar = getchar()) == EOF) goto endloop1;
      bl getchar 
      str w1, [w0]
      adr x0, iChar
      str w1, [x0]
      

      cmp iChar EOF
      beq endloop1

      add lCharCount, lCharCount, 1 

         # TODO if(! isspace(iChar)) goto else1;
            # TODO call isspace and store the value
            cmp ___ 1
            bne else1

            cmp iInWord 1
            bne endif1
            add lWordCount, lWordCount, 1
            b endif1
      else1:
         cmp iInWord 1
         beq endif1
         # TODO: set inWord to TRUE
      endif1:
         cmp iChar '\n'
         bne loop1
         add iLineCount, iLineCount, 1
         bne loop1

   endloop1:
      cmp iInWord 1
      bne endif2
      add lWordCount, lWordCount, 1
      
      endif2:
         # TODO: printf 
   
   mov w0, 0
   ldr x30, [sp]
   add sp, sp, MAIN_STACK_BYTECOUNT
   ret
