/*
 * Copyright (c) 1993-1995 Argonaut Technologies Limited. All rights reserved.
 *
 * $Id: persp.c 1.8 1995/08/31 16:47:37 sam Exp $
 * $Locker:  $
 *
 * Perspective texture mapper
 */
#include <math.h>
#include <stdlib.h>

#define FIX 1

#include "zb.h"
#include "shortcut.h"

#define swap(type,a,b) { type _; _ = a; a = b; b = _; }

#define high8(a) (*((unsigned char *)&a+3))

extern void BR_ASM_CALL ScanLinePIZ2TIP256(void);
extern void BR_ASM_CALL ScanLinePIZ2TIP64(void);
extern void BR_ASM_CALL ScanLinePIZ2TP256(void);
extern void BR_ASM_CALL ScanLinePIZ2TP64(void);
extern void BR_ASM_CALL ScanLinePIZ2TP1024(void);

BR_ASM_CALL_EXTRA(ScanLinePIZ2TIP256)
BR_ASM_CALL_EXTRA(ScanLinePIZ2TIP64)
BR_ASM_CALL_EXTRA(ScanLinePIZ2TP1024)
BR_ASM_CALL_EXTRA(ScanLinePIZ2TP256)
BR_ASM_CALL_EXTRA(ScanLinePIZ2TP64)

extern int BR_ASM_CALL SafeFixedMac2Div(int,int,int,int,int);
BR_ASM_CALL_EXTRA(SafeFixedMac2Div)


extern int cutoff = 4;

int PerspCheat = 1;

TexturedScanLine BR_ASM_DATA tsl;
BR_ASM_DATA_EXTRA(tsl)

#ifdef __WATCOMC__

extern int sar16(int);

extern int inch(int);
extern int incl(int);
extern int dech(int);
extern int decl(int);

#pragma aux sar16 = "sar eax,16" parm [eax]

#pragma aux inch = "inc ah" parm [eax]
#pragma aux incl = "inc al" parm [eax]
#pragma aux dech = "dec ah" parm [eax]
#pragma aux decl = "dec al" parm [eax]

#else

#define sar16 _sar16

#endif

#define FNAME TriangleRenderPIZ2TIP256
#define SIZE 256
#define LIGHT 1
#include "innerp.inc.c"
#undef LIGHT
#undef SIZE
#undef FNAME

#define FNAME TriangleRenderPIZ2TP256
#define SIZE 256
#define LIGHT 0
#include "innerp.inc.c"
#undef LIGHT
#undef SIZE
#undef FNAME

#define FNAME TriangleRenderPIZ2TIP64
#define SIZE 64
#define LIGHT 1
#include "innerp.inc.c"
#undef LIGHT
#undef SIZE
#undef FNAME

#define FNAME TriangleRenderPIZ2TP64
#define SIZE 64
#define LIGHT 0
#include "innerp.inc.c"
#undef LIGHT
#undef SIZE
#undef FNAME

#define FNAME TriangleRenderPIZ2TP1024
#define SIZE 1024
#define LIGHT 0
#include "innerp.inc.c"
#undef LIGHT
#undef SIZE
#undef FNAME
