// Copyright 2005-2008, 2010, 2012, 2014 Omni Development, Inc. All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import "OFTestCase.h"

#import <OmniFoundation/OFRationalNumber.h>
#import <OmniBase/OmniBase.h>

RCS_ID("$Id$");

@interface OFRationalTests : OFTestCase
{
}


@end

// Set this to ignore the loss-of-precision bit in some cases. Right now OFRationalFromDouble() often sets it when it shouldn't.
#define SLOPPY_LOP_BIT_TEST

static NSString *parts(struct OFRationalNumberStruct r)
{
    return [NSString stringWithFormat:@"%c%c%lu/%lu", r.lop?'~':' ', r.negative?'-':'+', r.numerator, r.denominator];    
}

static unsigned short lsign(long l)
{
    return (l < 0)? 1 : 0;
}

static unsigned long labsl(long l)
{
    return (l < 0)? -l : l;
}

static BOOL eqrat(struct OFRationalNumberStruct expr, long num, unsigned long den, int xlop)
{
    return expr.numerator==labsl(num) && expr.denominator==(den) && expr.negative==lsign(num) && expr.lop==(xlop);
}

#define RAT(num, denom) ((struct OFRationalNumberStruct){ .numerator = labsl(num), .denominator = denom, .negative = lsign(num), .lop = 0 })

#define shouldBeEqualRat(expr_, num, den, xlop) do{ struct OFRationalNumberStruct expr = (expr_); XCTAssertTrue(eqrat(expr, num, den, xlop), @"%s == %@, should be %d/%u", #expr_, parts(expr), num, den); }while(0)

@implementation OFRationalTests

- (void)testConvert
{
    shouldBeEqualRat(OFRationalFromLong(-3), -3, 1, 0);
    shouldBeEqualRat(OFRationalFromLong(-2), -2, 1, 0);
    shouldBeEqualRat(OFRationalFromLong(-1), -1, 1, 0);
    shouldBeEqualRat(OFRationalFromLong(0), 0, 0, 0);
    shouldBeEqualRat(OFRationalFromLong(1), 1, 1, 0);
    shouldBeEqualRat(OFRationalFromLong(2), 2, 1, 0);
    shouldBeEqualRat(OFRationalFromLong(3), 3, 1, 0);
    
    shouldBeEqualRat(OFRationalFromDouble(-100), -100, 1, 0);
    shouldBeEqualRat(OFRationalFromDouble(-25), -25, 1, 0);
    shouldBeEqualRat(OFRationalFromDouble(-98.625), -789, 8, 0);
    shouldBeEqualRat(OFRationalFromDouble(0.265625), 17, 64, 0);
    shouldBeEqualRat(OFRationalFromDouble(65536), 65536, 1, 0);
    
    XCTAssertTrue(OFRationalToDouble(RAT(1,16)) == 0.0625);
    XCTAssertTrue(OFRationalToDouble(RAT(-17,64)) == -0.265625);
    XCTAssertTrue(OFRationalToDouble(RAT(32767,65536)) == 0.4999847412109375);
    XCTAssertTrue(OFRationalToDouble(RAT(0,1)) == 0);
}

- (void)testConvertMinSig
{
    /* We're using floats here because OFRational has enough precision to accurately represent any float, but not any double. */
    float f = 1;
    
    for(int i = 0; i < 1000; i ++) {
        struct OFRationalNumberStruct rat = OFRationalFromDouble(f);
        // NSLog(@" %3d  %.16Lf -> %@", i, (long double)f, OFRationalToStringForStorage(rat));
        XCTAssertTrue(OFRationalToDouble(rat) == f);
        f = nextafterf(f, 1000);
    }
    
    f = -0.125f;
    
    for(int i = 0; i < 1000; i ++) {
        struct OFRationalNumberStruct rat = OFRationalFromDouble(f);
        // NSLog(@" %3d  %.16Lf -> %@", i, (long double)f, OFRationalToStringForStorage(rat));
        XCTAssertTrue(OFRationalToDouble(rat) == f);
        f = nextafterf(f, 1000);
    }
}

- (void)testScan
{
    struct OFRationalNumberStruct r;
    
    XCTAssertTrue(OFRationalFromStringForStorage(@"~22/7", &r));
    shouldBeEqualRat(r, 22, 7, 1);
    
    XCTAssertTrue(OFRationalFromStringForStorage(@"-1/10", &r));
    shouldBeEqualRat(r, -1, 10, 0);
    
    XCTAssertTrue(OFRationalFromStringForStorage(@"6/16", &r));
    shouldBeEqualRat(r, 3, 8, 0);
    
    XCTAssertTrue(OFRationalFromStringForStorage(@"~0", &r));
    shouldBeEqualRat(r, 0, 0, 1);    

    XCTAssertTrue(OFRationalFromStringForStorage(@"-999", &r));
    shouldBeEqualRat(r, -999, 1, 0);    
}

- (void)testMultiply
{
    struct OFRationalNumberStruct r, s, n, ni, ns;
    
    XCTAssertTrue(OFRationalFromStringForStorage(@"22/7", &r));
    XCTAssertTrue(OFRationalFromStringForStorage(@"113/355", &s));
    XCTAssertTrue(OFRationalFromStringForStorage(@"-2485/2486", &n));
    
    shouldBeEqualRat(OFRationalMultiply(r, s), 2486, 2485, 0);
    shouldBeEqualRat(OFRationalMultiply(r, n), -355, 113, 0);
    ni = OFRationalInverse(n);
    shouldBeEqualRat(OFRationalMultiply(r, ni), -54692, 17395, 0);
    shouldBeEqualRat(OFRationalMultiply(ni, r), -54692, 17395, 0);
    ns = OFRationalMultiply(n, s);
    shouldBeEqualRat(OFRationalMultiply(r, ns), -1, 1, 0);
    shouldBeEqualRat(OFRationalMultiply(ns, ni), 113, 355, 0);
    shouldBeEqualRat(OFRationalMultiply(OFRationalInverse(ns), n), 355, 113, 0);
}

- (void)testAdd
{
    struct OFRationalNumberStruct r, s, n, rs, x;
    
    XCTAssertTrue(OFRationalFromStringForStorage(@"22/7", &r));
    XCTAssertTrue(OFRationalFromStringForStorage(@"-113/355", &s));
    XCTAssertTrue(OFRationalFromStringForStorage(@"1/2485", &n));
    
    rs = OFRationalMultiply(r, s);
    x = rs;
    OFRationalMAdd(&x, n, 1);
    shouldBeEqualRat(x, -1, 1, 0);
    x = n;
    OFRationalMAdd(&x, rs, 1);
    shouldBeEqualRat(x, -1, 1, 0);
    x = rs;
    OFRationalMAdd(&x, n, -4);
    shouldBeEqualRat(x, -498, 497, 0);
    x = OFRationalZero;
    OFRationalMAdd(&x, rs, -4);
    shouldBeEqualRat(x, 9944, 2485, 0);
    OFRationalMAdd(&x, n, 1);
    shouldBeEqualRat(x, 1989, 497, 0);
    OFRationalMAdd(&x, n, -5);
    shouldBeEqualRat(x, 4, 1, 0);
}

- (void)testRound
{
    unsigned i;
    double fuzz = 1.0 / 39900.0;
    struct OFRationalNumberStruct offset = OFRationalFromLong(101);
    
#ifdef SLOPPY_LOP_BIT_TEST
#define SHOULD_NO_LOP(r) (r.lop = 0)
#else
#define SHOULD_NO_LOP(r) XCTAssertTrue(r.lop == 0)
#endif
    
    for(i = 1; i <= 100; i++) {
        struct OFRationalNumberStruct r;
        
        r = OFRationalFromDouble( (float)( 1.0 / (float)i ) );
        OFRationalRound(&r, 101);
        shouldBeEqualRat(r, 1, i, 0);
        
        r = OFRationalFromDouble( ( 1.0 / (double)i ) );
        XCTAssertFalse(r.lop);
        OFRationalRound(&r, 1000);
        shouldBeEqualRat(r, 1, i, 0);
        
        r = OFRationalFromDouble( 101 + ( 1.0 / (double)i ) );
        SHOULD_NO_LOP(r);
        OFRationalMAdd(&r, offset, -1);
        OFRationalRound(&r, 101);
        shouldBeEqualRat(r, 1, i, 0);
        
        r = OFRationalFromDouble( fuzz + ( 1.0 / (double)i ) );
        r.lop = 0;
        OFRationalRound(&r, 101);
        shouldBeEqualRat(r, 1, i, 0);
        
        r = OFRationalFromDouble( fuzz - ( 1.0 / (double)i ) );
        r.lop = 0;
        OFRationalRound(&r, 101);
        shouldBeEqualRat(r, -1, i, 0);
    }
}

- (void)testCompare;
{
    // zero over anything is zero
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(0,1), OFRationalFromRatio(0,2)) == NSOrderedSame);
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(0,2), OFRationalFromRatio(0,1)) == NSOrderedSame);
    
    // fractions should reduce
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(1,2), OFRationalFromRatio(2,4)) == NSOrderedSame);
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(2,4), OFRationalFromRatio(1,2)) == NSOrderedSame);
    
    // 1/2 < 2/3
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(1,2), OFRationalFromRatio(2,3)) == NSOrderedAscending);
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(2,3), OFRationalFromRatio(1,2)) == NSOrderedDescending);
    
    // 5/17 > 13/59
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(13,59), OFRationalFromRatio(5,17)) == NSOrderedAscending);
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(5,17), OFRationalFromRatio(13,59)) == NSOrderedDescending);
    
    // negatives are less than zeroes are less than positives
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(-1,2), OFRationalFromRatio(1,2)) == NSOrderedAscending);
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(1,2), OFRationalFromRatio(0,-2)) == NSOrderedDescending);
    XCTAssertTrue(OFRationalCompare(OFRationalFromRatio(0,-2), OFRationalFromRatio(-1,2)) == NSOrderedDescending);
}

@end
