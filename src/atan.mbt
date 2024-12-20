// /* atan(x)
//  * Method
//  *   1. Reduce x to positive by atan(x) = -atan(-x).
//  *   2. According to the integer k=4t+0.25 chopped, t=x, the argument
//  *      is further reduced to one of the following intervals and the
//  *      arctangent of t is evaluated by the corresponding formula:
//  *
//  *      [0,7/16]      atan(x) = t-t^3*(a1+t^2*(a2+...(a10+t^2*a11)...)
//  *      [7/16,11/16]  atan(x) = atan(1/2) + atan( (t-0.5)/(1+t/2) )
//  *      [11/16.19/16] atan(x) = atan( 1 ) + atan( (t-1)/(1+t) )
//  *      [19/16,39/16] atan(x) = atan(3/2) + atan( (t-1.5)/(1+1.5t) )
//  *      [39/16,INF]   atan(x) = atan(INF) + atan( -1/t )
//  *
//  * Constants:
//  * The hexadecimal values are the intended ones for the following 
//  * constants. The decimal values may be used, provided that the 
//  * compiler will convert from decimal to binary accurately enough 
//  * to produce the hexadecimal values shown.
//  */
//
// #include "fdlibm.h"
//
// #ifdef __STDC__
// static const double atanhi[] = {
// #else
// static double atanhi[] = {
// #endif
//   4.63647609000806093515e-01, /* atan(0.5)hi 0x3FDDAC67, 0x0561BB4F */
//   7.85398163397448278999e-01, /* atan(1.0)hi 0x3FE921FB, 0x54442D18 */
//   9.82793723247329054082e-01, /* atan(1.5)hi 0x3FEF730B, 0xD281F69B */
//   1.57079632679489655800e+00, /* atan(inf)hi 0x3FF921FB, 0x54442D18 */
// };
//
// #ifdef __STDC__
// static const double atanlo[] = {
// #else
// static double atanlo[] = {
// #endif
//   2.26987774529616870924e-17, /* atan(0.5)lo 0x3C7A2B7F, 0x222F65E2 */
//   3.06161699786838301793e-17, /* atan(1.0)lo 0x3C81A626, 0x33145C07 */
//   1.39033110312309984516e-17, /* atan(1.5)lo 0x3C700788, 0x7AF0CBBD */
//   6.12323399573676603587e-17, /* atan(inf)lo 0x3C91A626, 0x33145C07 */
// };
//
// #ifdef __STDC__
// static const double aT[] = {
// #else
// static double aT[] = {
// #endif
//   3.33333333333329318027e-01, /* 0x3FD55555, 0x5555550D */
//  -1.99999999998764832476e-01, /* 0xBFC99999, 0x9998EBC4 */
//   1.42857142725034663711e-01, /* 0x3FC24924, 0x920083FF */
//  -1.11111104054623557880e-01, /* 0xBFBC71C6, 0xFE231671 */
//   9.09088713343650656196e-02, /* 0x3FB745CD, 0xC54C206E */
//  -7.69187620504482999495e-02, /* 0xBFB3B0F2, 0xAF749A6D */
//   6.66107313738753120669e-02, /* 0x3FB10D66, 0xA0D03D51 */
//  -5.83357013379057348645e-02, /* 0xBFADDE2D, 0x52DEFD9A */
//   4.97687799461593236017e-02, /* 0x3FA97B4B, 0x24760DEB */
//  -3.65315727442169155270e-02, /* 0xBFA2B444, 0x2C6A6C2F */
//   1.62858201153657823623e-02, /* 0x3F90AD3A, 0xE322DA11 */
// };
//
// #ifdef __STDC__
// 	static const double 
// #else
// 	static double 
// #endif
// one   = 1.0,
// huge   = 1.0e300;
//
// #ifdef __STDC__
// 	double atan(double x)
// #else
// 	double atan(x)
// 	double x;
// #endif
// {
// 	double w,s1,s2,z;
// 	int ix,hx,id;
//
// 	hx = __HI(x);
// 	ix = hx&0x7fffffff;
// 	if(ix>=0x44100000) {	/* if |x| >= 2^66 */
// 	    if(ix>0x7ff00000||
// 		(ix==0x7ff00000&&(__LO(x)!=0)))
// 		return x+x;		/* NaN */
// 	    if(hx>0) return  atanhi[3]+atanlo[3];
// 	    else     return -atanhi[3]-atanlo[3];
// 	} if (ix < 0x3fdc0000) {	/* |x| < 0.4375 */
// 	    if (ix < 0x3e200000) {	/* |x| < 2^-29 */
// 		if(huge+x>one) return x;	/* raise inexact */
// 	    }
// 	    id = -1;
// 	} else {
// 	x = fabs(x);
// 	if (ix < 0x3ff30000) {		/* |x| < 1.1875 */
// 	    if (ix < 0x3fe60000) {	/* 7/16 <=|x|<11/16 */
// 		id = 0; x = (2.0*x-one)/(2.0+x); 
// 	    } else {			/* 11/16<=|x|< 19/16 */
// 		id = 1; x  = (x-one)/(x+one); 
// 	    }
// 	} else {
// 	    if (ix < 0x40038000) {	/* |x| < 2.4375 */
// 		id = 2; x  = (x-1.5)/(one+1.5*x);
// 	    } else {			/* 2.4375 <= |x| < 2^66 */
// 		id = 3; x  = -1.0/x;
// 	    }
// 	}}
//     /* end of argument reduction */
// 	z = x*x;
// 	w = z*z;
//     /* break sum from i=0 to 10 aT[i]z**(i+1) into odd and even poly */
// 	s1 = z*(aT[0]+w*(aT[2]+w*(aT[4]+w*(aT[6]+w*(aT[8]+w*aT[10])))));
// 	s2 = w*(aT[1]+w*(aT[3]+w*(aT[5]+w*(aT[7]+w*aT[9]))));
// 	if (id<0) return x - x*(s1+s2);
// 	else {
// 	    z = atanhi[id] - ((x*(s1+s2) - atanlo[id]) - x);
// 	    return (hx<0)? -z:z;
// 	}
// }

fn xatan(x : Double) -> Double {
  let z = x * x
  x *
  (
    z *
    (
      (((atan_p[0] * z + atan_p[1]) * z + atan_p[2]) * z + atan_p[3]) * z +
      atan_p[4]
    ) /
    (
      ((((z + atan_q[0]) * z + atan_q[1]) * z + atan_q[2]) * z + atan_q[3]) * z +
      atan_q[4]
    )
  ) +
  x
}

let atan_p = [
  -8.750608600031904122785e-01, -1.615753718733365076637e+01, -7.500855792314704667340e+01,
  -1.228866684490136173410e+02, -6.485021904942025371773e+01,
]

let atan_q = [
  2.485846490142306297962e+01, 1.650270098316988542046e+02, 4.328810604912902668951e+02,
  4.853903996359136964868e+02, 1.945506571482613964425e+02,
]

let morebits = 6.123233995736765886130e-17

let tan3pio8 = 2.41421356237309504880

fn satan(x : Double) -> Double {
  if x <= 0.66 {
    xatan(x)
  } else if x > tan3pio8 {
    PI / 2.0 - xatan(1.0 / x) + morebits
  } else {
    PI / 4.0 + xatan((x - 1.0) / (x + 1.0)) + 0.5 * morebits
  }
}

///| Compute arctangent of `x`
pub fn atan(x : Double) -> Double {
  if isnan(x) || x == 0.0 {
    x
  } else if x > 0.0 {
    satan(x)
  } else {
    -satan(-x)
  }
}

test "atan" {
  fn assert_atan_ulp!(input, expect) {
    assert_ulp!(expect, atan(input), ATAN_MAX_ULP);
  }
  assert_atan_ulp!(-1, -0.7853981633974483)
  assert_atan_ulp!(-2, -1.1071487177940904)
  assert_atan_ulp!(-3, -1.2490457723982544)
  assert_atan_ulp!(-4, -1.3258176636680326)
  assert_atan_ulp!(-5, -1.373400766945016)
  assert_atan_ulp!(-6, -1.4056476493802699)
  assert_atan_ulp!(-7, -1.4288992721907328)
  assert_atan_ulp!(-8, -1.446441332248135)
  assert_atan_ulp!(-9, -1.460139105621001)
  assert_atan_ulp!(1, 0.7853981633974483)
  assert_atan_ulp!(2, 1.1071487177940904)
  assert_atan_ulp!(3, 1.2490457723982544)
  assert_atan_ulp!(4, 1.3258176636680326)
  assert_atan_ulp!(5, 1.373400766945016)
  assert_atan_ulp!(6, 1.4056476493802699)
  assert_atan_ulp!(7, 1.4288992721907328)
  assert_atan_ulp!(8, 1.446441332248135)
  assert_atan_ulp!(9, 1.460139105621001)
  assert_atan_ulp!(10, 1.4711276743037347)
  assert_atan_ulp!(100, 1.5607966601082315)
  assert_atan_ulp!(1000, 1.5697963271282298)
  assert_atan_ulp!(10000, 1.5706963267952299)
  assert_atan_ulp!(2.5, 1.1902899496825317)
  assert_atan_ulp!(3.4, 1.2847448850775784)
  assert_atan_ulp!(5.3, 1.3843094251276797)
  assert_atan_ulp!(6.2, 1.4108832036366774)
  assert_atan_ulp!(7.1, 1.4308716562207788)
  assert_atan_ulp!(8.9, 1.4589060606232205)
  assert_atan_ulp!(9.8, 1.4691074750318196)
  assert_atan_ulp!(10.7, 1.4776090650260174)
  assert_atan_ulp!(101.6, 1.560954124923385)
  assert_atan_ulp!(1.542, 0.9954703758916351)
  assert_atan_ulp!(2.846, 1.2329012326696813)
  assert_atan_ulp!(7.881, 1.4445833528722425)
  assert_atan_ulp!(3.772, 1.3116465586544106)
  assert_atan_ulp!(-1.542, -0.9954703758916351)
  assert_atan_ulp!(-2.846, -1.2329012326696813)
  assert_atan_ulp!(-7.881, -1.4445833528722425)
  assert_atan_ulp!(-3.772, -1.3116465586544106)
  assert_atan_ulp!(-1, -0.7853981633974483)
  assert_atan_ulp!(0, 0)
  assert_atan_ulp!(-0, -0)
  assert_atan_ulp!(double_nan, double_nan)
  assert_atan_ulp!(double_pos_inf, 1.5707963267948966)
  assert_atan_ulp!(double_neg_inf, -1.5707963267948966)
}
