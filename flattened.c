/*--------------------------------------------------------------------*/
/* bigintadd.c                                                        */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include "bigint.h"
#include "bigintprivate.h"
#include <string.h>
#include <assert.h>

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

/* Return the larger of lLength1 and lLength2. */

static long BigInt_larger(long lLength1, long lLength2)
{
   long lLarger;
   if (lLength1 <= lLength2) goto else1;
      lLarger = lLength1;
      goto endifLarger;
   else1:
      lLarger = lLength2;
   endifLarger:
   return lLarger;
}

/*--------------------------------------------------------------------*/

/* Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should be
   distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if an
   overflow occurred, and 1 (TRUE) otherwise. */

int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
{
   unsigned long ulCarry;
   unsigned long ulSum;
   long lIndex;
   long lSumLength;

   assert(oAddend1 != NULL);
   assert(oAddend2 != NULL);
   assert(oSum != NULL);
   assert(oSum != oAddend1);
   assert(oSum != oAddend2);

   /* Determine the larger length. */
   lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);

   /* Clear oSum's array if necessary. */
   if (oSum->lLength <= lSumLength) goto endif1;
      memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

   /* Perform the addition. */
   endif1:
   ulCarry = 0;
   lIndex = 0;

   loop: 
      if (lIndex >= lSumLength) goto loopEnd;
      ulSum = ulCarry;
      ulSum += oAddend1->aulDigits[lIndex];
      ulCarry = 0;

      if (ulSum >= oAddend1->aulDigits[lIndex]) goto endif2;
         ulCarry = 1;
      endif2:
      ulSum += oAddend2->aulDigits[lIndex];
      if (ulSum >= oAddend2->aulDigits[lIndex]) goto endif3;
         ulCarry = 1;
      endif3:
      oSum->aulDigits[lIndex] = ulSum;
      lIndex++;
      goto loop;
   loopEnd:
   if (ulCarry != 1) goto endif4;
      if (lSumLength != MAX_DIGITS) goto endif5;
         return FALSE;
      endif5:
      oSum->aulDigits[lSumLength] = 1;
      lSumLength++;
   endif4:
   oSum->lLength = lSumLength;
   return TRUE;

}