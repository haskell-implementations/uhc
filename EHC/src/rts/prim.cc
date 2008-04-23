%%[8
#include "rts.h"

/* Make sure these numbers are the same as generated by Grin/ToSilly.cag */

#define CFalse  1
#define CTrue   2
#define Ccolon  3
#define Csubbus 4
#define CEQ     5
#define CGT     6
#define CLT     7
#define Ccomma0 8

#define CEHC_Prelude_AppendBinaryMode     9
#define CEHC_Prelude_AppendMode          10
#define CEHC_Prelude_ReadBinaryMode      11
#define CEHC_Prelude_ReadMode            12
#define CEHC_Prelude_ReadWriteBinaryMode 13
#define CEHC_Prelude_ReadWriteMode       14
#define CEHC_Prelude_WriteBinaryMode     15
#define CEHC_Prelude_WriteMode           16

%%]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% System related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Integer related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8

PRIM GrWord packedStringToInteger(GrWord s)
{
	GrWord res;
    res = heapalloc(1);
    ((Pointer)res)[0] = atoi( (char*)s );
    return res;
}


PRIM GrWord primIntToInteger(GrWord n)
{
	GrWord res;
    res = heapalloc(1);
    ((Pointer)res)[0] = n;
    return res;
}

PRIM GrWord primIntegerToInt(GrWord p)
{
	GrWord res;
    res = ((Pointer)p)[0];
    return res;
}

PRIM GrWord primCmpInteger(GrWord x, GrWord y)
{   if (((Pointer)x)[0] > ((Pointer)y)[0])
        return CGT;
    if (((Pointer)x)[0] == ((Pointer)y)[0])
        return CEQ;
    return CLT;
}

PRIM GrWord primEqInteger(GrWord x, GrWord y)
{
    if (((Pointer)x)[0] == ((Pointer)y)[0])
        return CTrue;
    return CFalse;
}



%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Int related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8


PRIM GrWord primNegInt(GrWord x)
{
	return -x;	
}

PRIM GrWord primAddInt(GrWord x, GrWord y)
{   
	//printf("add %d %d\n", x, y );
	return x+y;
}

PRIM GrWord primSubInt(GrWord x, GrWord y)
{   
	//printf("sub %d %d\n", x, y );
	return x-y;
}

PRIM GrWord primMulInt(GrWord x, GrWord y)
{   
	//printf("mul %d %d\n", x, y );
	return x*y;
}

/* This should be the Quot function */
PRIM GrWord primDivInt(GrWord x, GrWord y)
{   
	//printf("div %d %d\n", x, y );
	return x/y;
}

/* This should be the Rem function */
PRIM GrWord primModInt(GrWord x, GrWord y)
{   
	//printf("mod %d %d\n", x, y );
	return x%y;
}

PRIM GrWord primRemInt(GrWord x, GrWord y)
{   
	return x%y;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Ord Int related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8

/* The Boolean functions below only return the constructor */


PRIM GrWord primGtInt(GrWord x, GrWord y)
{   if (x>y)
    { //  printf ("%d is groter dan %d\n", x, y );
        return CTrue;
    }
    //printf ("%d is niet groter dan %d\n", x, y );
    return CFalse;
}

PRIM GrWord primLtInt(GrWord x, GrWord y)
{   if (x<y)
        return CTrue;
    return CFalse;
}
%%]

%%[8
PRIM GrWord primCmpInt(GrWord x, GrWord y)
{   if (x>y)
        return CGT;
    if (x==y)
        return CEQ;
    return CLT;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Eq Int related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
PRIM GrWord primEqInt(GrWord x, GrWord y)
{
	 //printf("eq %d %d\n", x, y );
	
    if (x==y)
        return CTrue;
    return CFalse;
}
%%]

%%[8
PRIM GrWord primNeInt(GrWord x, GrWord y)
{
	 //printf("neq %d %d\n", x, y );
	
    if (x!=y)
        return CTrue;
    return CFalse;
}
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Misc primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
PRIM GrWord primUnsafeId(GrWord x)
{   return x ;
}

PRIM void primPatternMatchFailure()
{
    printf("Pattern match failure\n");
    exit(1);
}

PRIM GrWord primOrd(GrWord x)
{
	return x;	
}

PRIM GrWord primChr(GrWord x)
{
	return x;	
}

PRIM GrWord primOdd(GrWord x)
{
    if (x&1)
        return CTrue;
    return CFalse;
}


PRIM GrWord primPackedStringNull(GrWord s)
{
	if (*  ((char*)s) )	
    	return CFalse;	
    return CTrue;
}

PRIM GrWord primPackedStringTail(GrWord s)
{
	return  (GrWord)(((char*)s)+1);
}

PRIM GrWord primPackedStringHead(GrWord s)
{
	return (GrWord)(*((char*)s));
}


PRIM GrWord primError(GrWord s)
{
	GrWord c;
	char x;

	printf("\nError function called from Haskell with message: ");
	fflush(stdout);
	
	while (  ((GrWord*)s)[0] == Ccolon )
	{
		c = ((GrWord*)s)[1];	
		x = ((GrWord*)c)[1];
		putc(x,stdout);
		s = ((GrWord*)s)[2];	
	}
	putc('\n', stdout);
	fflush(stdout);
	
	exit(1);
	return 0;	
}


PRIM GrWord primMinInt()
{
	return 0x10000000;
}
PRIM GrWord primMaxInt()
{
	return 0x0FFFFFFF;
}


%%]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% char related primitives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[99
PRIM GrWord primCharIsUpper( GrWord x )
{
	if ( x >= 'A' && x <= 'Z' )
		return CTrue;
  	return CFalse;
}

PRIM GrWord primCharIsLower( GrWord x )
{
	if ( x >= 'a' && x <= 'z' )
		return CTrue;
  	return CFalse;
}

%%]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exiting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[96

PRIM GrWord primExitWith(GrWord n)
{
	exit(n);
  	return 0;
}

%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% IO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[98

PRIM GrWord primStdin()
{
  	return (GrWord)stdin;
}

PRIM GrWord primStdout()
{
  	return (GrWord)stdout;
}

PRIM GrWord primStderr()
{
  	return (GrWord)stderr;
}

PRIM GrWord primHFileno(GrWord chan)
{
	return fileno((FILE*)chan);
}


PRIM GrWord primOpenFile(GrWord str, GrWord mode)
{
	char filename[1024];
	char *d, *modestring;
	GrWord c;
	char x;
	FILE *f;

	d = filename;
	while (  ((GrWord*)str)[0] == Ccolon )
	{
		c = ((GrWord*)str)[1];	
		x = ((GrWord*)c)[1];
		*d++ = x;
		str = ((GrWord*)str)[2];	
	}
	*d = 0;

	
	switch(mode - CEHC_Prelude_AppendBinaryMode)
	{
	case 0: modestring = "ab"; break;
	case 1: modestring = "a"; break;
	case 2: modestring = "rb"; break;
	case 3: modestring = "r"; break;
	case 4: modestring = "r+b"; break;
	case 5: modestring = "r+"; break;
	case 6: modestring = "wb"; break;
	case 7: modestring = "w"; break;
	default:  printf("primOpenFile: illegal mode %d\n", mode); fflush(stdout);
	          return 0;	
}

	//printf("try to open [%s] with mode [%s]\n", filename, modestring );  fflush(stdout);
	f = fopen(filename, modestring);
	return (GrWord) f;	
}

PRIM GrWord primHClose(GrWord chan)
{
	fclose( (FILE*)chan );
	return Ccomma0;	
}

PRIM GrWord primHFlush(GrWord chan)
{
	fflush( (FILE*)chan );
	return Ccomma0;	
}

PRIM GrWord primHGetChar(GrWord h)
{
	int c;
	c = getc( (FILE*)h );
	//printf ("character read: %c\n", c );
	return c;
}

PRIM GrWord primHPutChar(GrWord h, GrWord c)
{
	putc(c, (FILE*)h );
	return Ccomma0;
}

PRIM GrWord primHIsEOF(GrWord h)
{
	int c;
	c = getc( (FILE*)h );
	if (c==EOF)
		return CTrue;
	
	ungetc( c, (FILE*)h );
	return CFalse;
}



%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% System
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[99
PRIM GrWord primGetArgC()
{
	return (GrWord) rtsArgC ;
}

PRIM GrWord primGetArgVAt( GrWord argc )
{
	return (GrWord) rtsArgV[ argc ] ;
}

%%]

