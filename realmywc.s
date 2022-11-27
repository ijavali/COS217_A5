# Status:
# do the TODOs
# I think we have to do stuff with registers and addresses
# like add lWordCount, lWordCount, 1 probably isn't correct
# . it probably has to be like add x1, x1, 1 or something

# TODO: make enum

# This is for the global variables
  .section .data
lLineCount: .quad 0
lWordCount: .quad 0
lCharCount: .quad 0
iChar: .skip 4 
iInWord: .word TODO (how to use enum value FALSE)

  .section .text
  .global .main
main:
   loop1:
      # TODO if((iChar = getchar()) == EOF) goto endloop1;
      add lCharCount, lCharCount, 1 

         # TODO if(! isspace(iChar)) goto else1;
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
         ret
