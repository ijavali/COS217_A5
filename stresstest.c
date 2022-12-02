#include <stdio.h>
#include <stdlib.h>

int main(void) 
{
   int i;
   int seed;
   char cur;

   
   seed = 217;
   srand(seed);

   for(i = 0; i < 1000; i++) 
   {
      cur = rand() % 0X7F;
      if (cur == 0x09 || cur == 0x0A || (cur >= 0x20 && cur <= 0x7E))
      {
        printf("%c", cur);
      }
   }
   
   return 0;
}