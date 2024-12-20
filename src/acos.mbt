///| Compute arc cosine
/// # Introduction
///
/// Computes the principal value of the arc cosine of `x`.
///
/// # Special cases
///
/// 1. If `x` is NaN, a NaN is returned.
/// 2. If |x| > 1, a NaN is returned with the invalid signal raised.
///
/// # Accruacy
///
/// 1 ulp (unit in the last place).
// Method :                  
// acos(x)  = pi/2 - asin(x)
// acos(-x) = pi/2 + asin(x)
// For |x|<=0.5
// acos(x) = pi/2 - (x + x*x^2*R(x^2))	(see asin.c)
// For x>0.5
// 	acos(x) = pi/2 - (pi/2 - 2asin(sqrt((1-x)/2)))
// 	= 2asin(sqrt((1-x)/2))  
// 	= 2s + 2s*z*R(z) 	...z=(1-x)/2, s=sqrt(z)
// 	= 2f + (2c + 2s*z*R(z))
//     where f=hi part of s, and c = (z-f*f)/(s+f) is the correction term
//     for f so that f+c ~ sqrt(z).
// For x<-0.5
// acos(x) = pi - 2asin(sqrt((1-|x|)/2))
// 	= pi - 0.5*(s+s*z*R(z)), where z=(1-|x|)/2,s=sqrt(z)
pub fn acos(x: Double) -> Double {
  let one : Double = 1.0
  let pi : Double = 3.14159265358979311600
  let pio2_hi : Double = 1.57079632679489655800
  let pio2_lo : Double = 6.12323399573676603587e-17
  let pS0 : Double = 1.66666666666666657415e-01
  let pS1 : Double = -3.25565818622400915405e-01
  let pS2 : Double = 2.01212532134862925881e-01
  let pS3 : Double = -4.00555345006794114027e-02
  let pS4 : Double = 7.91534994289814532176e-04
  let pS5 : Double = 3.47933107596021167570e-05
  let qS1 : Double = -2.40339491173441421878e+00
  let qS2 : Double = 2.02094576023350569471e+00
  let qS3 : Double = -6.88283971605453293030e-01
  let qS4 : Double = 7.70381505559019352791e-02

  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  if ix >= 0x3ff00000 {
    // |x| >= 1
    if ((ix - 0x3ff00000) | __low(x).reinterpret_as_int()) == 0 {
      // |x|==1
      if hx > 0 {
        return 0.0
      } else {
        return pi + 2.0 * pio2_lo
      }
    }
    return (x - x) / (x - x)
  }
  if ix < 0x3fe00000 {
    // |x| < 0.5
    if ix <= 0x3c600000 {
      return pio2_hi + pio2_lo
    }
    let z = x * x
    let p = z * (pS0 + z * (pS1 + z * (pS2 + z * (pS3 + z * (pS4 + z * pS5)))))
    let q = one + z * (qS1 + z * (qS2 + z * (qS3 + z * qS4)))
    let r = p / q
    pio2_hi - (x - (pio2_lo - x * r))
  } else if hx < 0 {
    // x < -0.5
    let z = (one + x) * 0.5
    let p = z * (pS0 + z * (pS1 + z * (pS2 + z * (pS3 + z * (pS4 + z * pS5)))))
    let q = one + z * (qS1 + z * (qS2 + z * (qS3 + z * qS4)))
    let s = z.sqrt()
    let r = p / q
    let w = r * s - pio2_lo
    pi - 2.0 * (s + w)
  } else {
    // x > 0.5
    let z = (one - x) * 0.5
    let s = z.sqrt()
    let df = s
    let c = (z - df * df) / (s + df)
    let p = z * (pS0 + z * (pS1 + z * (pS2 + z * (pS3 + z * (pS4 + z * pS5)))))
    let q = one + z * (qS1 + z * (qS2 + z * (qS3 + z * qS4)))
    let r = p / q
    let w = r * s + c
    2.0 * (df + w)
  }
}

test "acos" {
  fn assert_acos_ulp!(input, expect) {
    assert_ulp!(expect, acos(input), ACOS_MAX_ULP);
  }
  assert_acos_ulp!(-0.8, 2.498091544796509)
  assert_acos_ulp!(-0.7, 2.3461938234056494)
  assert_acos_ulp!(-0.6, 2.214297435588181)
  assert_acos_ulp!(-0.5, 2.0943951023931957)
  assert_acos_ulp!(-0.4, 1.9823131728623846)
  assert_acos_ulp!(-0.3, 1.8754889808102941)
  assert_acos_ulp!(-0.2, 1.7721542475852274)
  assert_acos_ulp!(-0.1, 1.6709637479564565)
  assert_acos_ulp!(-0, 1.5707963267948966)
  assert_acos_ulp!(-3.141592653589793, double_nan)
  assert_acos_ulp!(-1.5707963267948966, double_nan)
  assert_acos_ulp!(-0.7853981633974483, 2.4741354375614093)
  assert_acos_ulp!(0, 1.5707963267948966)
  assert_acos_ulp!(0.1, 1.4706289056333368)
  assert_acos_ulp!(0.2, 1.369438406004566)
  assert_acos_ulp!(0.3, 1.2661036727794992)
  assert_acos_ulp!(0.4, 1.1592794807274085)
  assert_acos_ulp!(0.5, 1.0471975511965979)
  assert_acos_ulp!(0.6, 0.9272952180016123)
  assert_acos_ulp!(0.7, 0.7953988301841436)
  assert_acos_ulp!(0.8, 0.6435011087932843)
  assert_acos_ulp!(0.9, 0.45102681179626236)
  assert_acos_ulp!(1, 0)
  assert_acos_ulp!(3.141592653589793, double_nan)
  assert_acos_ulp!(1.5707963267948966, double_nan)
  assert_acos_ulp!(0.7853981633974483, 0.6674572160283838)
  assert_acos_ulp!(double_nan, double_nan)
  assert_acos_ulp!(double_pos_inf, double_nan)
  assert_acos_ulp!(double_neg_inf, double_nan)
}
