// Method -- j1(x):
// 1. For tiny x, we use j1(x) = x/2 - x^3/16 + x^5/384 - ...
// 2. Reduce x to |x| since j1(x)=-j1(-x),  and
//    for x in (0,2)
// 	j1(x) = x/2 + x*z*R0/S0,  where z = x*x;
//    (precision:  |j1/x - 1/2 - R0/S0 |<2**-61.51 )
//    for x in (2,inf)
// 		j1(x) = sqrt(2/(pi*x))*(p1(x)*cos(x1)-q1(x)*sin(x1))
// 		y1(x) = sqrt(2/(pi*x))*(p1(x)*sin(x1)+q1(x)*cos(x1))
// 	   where x1 = x-3*pi/4. It is better to compute sin(x1),cos(x1)
//    as follow:
// 	cos(x1) =  cos(x)cos(3pi/4)+sin(x)sin(3pi/4)
// 		=  1/sqrt(2) * (sin(x) - cos(x))
// 	sin(x1) =  sin(x)cos(3pi/4)-cos(x)sin(3pi/4)
// 		= -1/sqrt(2) * (sin(x) + cos(x))
// 	   (To avoid cancellation, use
// 	sin(x) +- cos(x) = -cos(2x)/(sin(x) -+ cos(x))
// 	    to compute the worse one.)

///| Compute Bessel function of the first kind of order one.
///
/// # Examples
///
/// ```moonbit
/// assert_eq(j1(0), 0)
/// assert_eq(j1(1), 0.4400505857449335)
/// assert_eq(j1(2), 0.5767248077568733)
/// assert_eq(j1(1.542), 0.5634545029920421)
/// ```
///
/// # Special Cases
///
/// 1. `j1(x)` is NaN if `x` is NaN.
/// 2. `j1(x)` is 0 if `x` is ±∞.
/// 3. `j1(x)` is NaN if `x` is less than 0.
///
/// # Accuracy
///
/// 4 ulp
pub fn bessel_j1(x : Double) -> Double {
  if isnan(x) {
    return @double.not_a_number
  }
  if isinf(x) {
    return 0.0
  }
  let huge = 1.0e300
  let invsqrtpi = 5.64189583547756279280e-01 // 0x3FE20DD7, 0x50429B6D
  let r00 = -6.25000000000000000000e-02 // 0xBFB00000, 0x00000000 
  let r01 = 1.40705666955189706048e-03 // 0x3F570D9F, 0x98472C61 
  let r02 = -1.59955631084035597520e-05 // 0xBEF0C5C6, 0xBA169668 
  let r03 = 4.96727999609584448412e-08 // 0x3E6AAAFA, 0x46CA0BD9 
  let s01 = 1.91537599538363460805e-02 // 0x3F939D0B, 0x12637E53 
  let s02 = 1.85946785588630915560e-04 // 0x3F285F56, 0xB9CDF664 
  let s03 = 1.17718464042623683263e-06 // 0x3EB3BFF8, 0x333F8498 
  let s04 = 5.04636257076217042715e-09 // 0x3E35AC88, 0xC97DFF2C 
  let s05 = 1.23542274426137913908e-11 // 0x3DAB2ACF, 0xCFB97ED8 
  let hx : Int = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  let y = fabs(x)
  if fabs(x) >= 2.0 {
    let s = sin(y)
    let c = cos(y)
    let mut ss = -s - c
    let mut cc = s - c
    if ix < 0x7fe00000 {
      let z = cos(y + y)
      if s * c > 0.0 {
        cc = z / ss
      } else {
        ss = z / cc
      }
    }
    let z = if ix > 0x48000000 {
      invsqrtpi * cc / sqrt(y)
    } else {
      let u = pone(y)
      let v = qone(y)
      invsqrtpi * (u * cc - v * ss) / sqrt(y)
    }
    if hx < 0 {
      return -z
    } else {
      return z
    }
  }
  if ix < 0x3e400000 {
    if huge + x > 1.0 {
      return 0.5 * x
    }
  }
  let z = x * x
  let r = z * (r00 + z * (r01 + z * (r02 + z * r03)))
  let s = 1.0 + z * (s01 + z * (s02 + z * (s03 + z * (s04 + z * s05))))
  let r = r * x
  x * 0.5 + r / s
}

///| `j1` is an alias of `bessel_j1`.
pub let j1 : (Double) -> Double = bessel_j1

// For x >= 8, the asymptotic expansions of pone is
// 1 + 15/128 s^2 - 4725/2^15 s^4 - ...,	where s = 1/x.
// We approximate pone by
// 	pone(x) = 1 + (R/S)
// where  R = pr0 + pr1*s^2 + pr2*s^4 + ... + pr5*s^10
// 	  S = 1 + ps0*s^2 + ... + ps4*s^10
// and
// | pone(x)-1-R/S | <= 2  ** ( -60.06)

///|
fn pone(x : Double) -> Double {
  fn pr_ps(i : Int) -> (Array[Double], Array[Double]) {
    let (pr, ps) = match i {
      2 => {
        let pr = [
          1.07710830106873743082e-07, // 0x3E7CE9D4, 0xF65544F4
           1.17176219462683348094e-01, // 0x3FBDFF42, 0xBE760D83
           2.36851496667608785174e+00, // 0x4002F2B7, 0xF98FAEC0
           1.22426109148261232917e+01, // 0x40287C37, 0x7F71A964
           1.76939711271687727390e+01, // 0x4031B1A8, 0x177F8EE2
           5.07352312588818499250e+00, // 0x40144B49, 0xA574C1FE
        ]
        let ps = [
          2.14364859363821409488e+01, // 0x40356FBD, 0x8AD5ECDC
           1.25290227168402751090e+02, // 0x405F5293, 0x14F92CD5
           2.32276469057162813669e+02, // 0x406D08D8, 0xD5A2DBD9
           1.17679373287147100768e+02, // 0x405D6B7A, 0xDA1884A9
           8.36463893371618283368e+00, // 0x4020BAB1, 0xF44E5192
        ]
        (pr, ps)
      }
      3 => {
        let pr = [
          3.02503916137373618024e-09, // 0x3E29FC21, 0xA7AD9EDD
           1.17186865567253592491e-01, // 0x3FBDFFF5, 0x5B21D17B
           3.93297750033315640650e+00, // 0x400F76BC, 0xE85EAD8A
           3.51194035591636932736e+01, // 0x40418F48, 0x9DA6D129
           9.10550110750781271918e+01, // 0x4056C385, 0x4D2C1837
           4.85590685197364919645e+01, // 0x4048478F, 0x8EA83EE5
        ]
        let ps = [
          3.47913095001251519989e+01, // 0x40416549, 0xA134069C
           3.36762458747825746741e+02, // 0x40750C33, 0x07F1A75F
           1.04687139975775130551e+03, // 0x40905B7C, 0x5037D523
           8.90811346398256432622e+02, // 0x408BD67D, 0xA32E31E9
           1.03787932439639277504e+02, // 0x4059F26D, 0x7C2EED53
        ]
        (pr, ps)
      }
      5 => {
        let pr = [
          1.31990519556243522749e-11, // 0x3DAD0667, 0xDAE1CA7D
           1.17187493190614097638e-01, // 0x3FBDFFFF, 0xE2C10043
           6.80275127868432871736e+00, // 0x401B3604, 0x6E6315E3
           1.08308182990189109773e+02, // 0x405B13B9, 0x452602ED
           5.17636139533199752805e+02, // 0x40802D16, 0xD052D649
           5.28715201363337541807e+02, // 0x408085B8, 0xBB7E0CB7
        ]
        let ps = [
          5.92805987221131331921e+01, // 0x404DA3EA, 0xA8AF633D
           9.91401418733614377743e+02, // 0x408EFB36, 0x1B066701
           5.35326695291487976647e+03, // 0x40B4E944, 0x5706B6FB
           7.84469031749551231769e+03, // 0x40BEA4B0, 0xB8A5BB15
           1.50404688810361062679e+03, // 0x40978030, 0x036F5E51
        ]
        (pr, ps)
      }
      8 => {
        let pr = [
          0.00000000000000000000e+00, // 0x00000000, 0x00000000
           1.17187499999988647970e-01, // 0x3FBDFFFF, 0xFFFFFCCE
           1.32394806593073575129e+01, // 0x402A7A9D, 0x357F7FCE
           4.12051854307378562225e+02, // 0x4079C0D4, 0x652EA590
           3.87474538913960532227e+03, // 0x40AE457D, 0xA3A532CC
           7.91447954031891731574e+03, // 0x40BEEA7A, 0xC32782DD
        ]
        let ps = [
          1.14207370375678408436e+02, // 0x405C8D45, 0x8E656CAC
           3.65093083420853463394e+03, // 0x40AC85DC, 0x964D274F
           3.69562060269033463555e+04, // 0x40E20B86, 0x97C5BB7F
           9.76027935934950801311e+04, // 0x40F7D42C, 0xB28F17BB
           3.08042720627888811578e+04, // 0x40DE1511, 0x697A0B2D
        ]
        (pr, ps)
      }
      _ => panic()
    }
    (pr, ps)
  }

  let ix = __hi(x) & 0x7fffffff
  let ix = ix.reinterpret_as_int()
  let (p, q) = if ix >= 0x40200000 {
    pr_ps(8)
  } else if ix >= 0x40122E8B {
    pr_ps(5)
  } else if ix >= 0x4006DB6D {
    pr_ps(3)
  } else if ix >= 0x40000000 {
    pr_ps(2)
  } else {
    panic()
  }
  let z = 1.0 / (x * x)
  let r = p[0] + z * (p[1] + z * (p[2] + z * (p[3] + z * (p[4] + z * p[5]))))
  let s = 1.0 + z * (q[0] + z * (q[1] + z * (q[2] + z * (q[3] + z * q[4]))))
  1.0 + r / s
}

// For x >= 8, the asymptotic expansions of qone is
// 3/8 s - 105/1024 s^3 - ..., where s = 1/x.
// We approximate pone by
// 	qone(x) = s*(0.375 + (R/S))
// where  R = qr1*s^2 + qr2*s^4 + ... + qr5*s^10
// 	  S = 1 + qs1*s^2 + ... + qs6*s^12
// and
// | qone(x)/s -0.375-R/S | <= 2  ** ( -61.13)
//

///|
fn qone(x : Double) -> Double {
  fn qr_qs(i : Int) -> (Array[Double], Array[Double]) {
    let (qr, qs) = match i {
      2 => {
        let qr = [
          -1.78381727510958865572e-07, // 0xBE87F126, 0x44C626D2 
           -1.02517042607985553460e-01, // 0xBFBA3E8E, 0x9148B010 
           -2.75220568278187460720e+00, // 0xC0060484, 0x69BB4EDA 
           -1.96636162643703720221e+01, // 0xC033A9E2, 0xC168907F 
           -4.23253133372830490089e+01, // 0xC04529A3, 0xDE104AAA 
           -2.13719211703704061733e+01, // 0xC0355F36, 0x39CF6E52 
        ]
        let qs = [
          2.95333629060523854548e+01, // 0x403D888A, 0x78AE64FF 
           2.52981549982190529136e+02, // 0x406F9F68, 0xDB821CBA 
           7.57502834868645436472e+02, // 0x4087AC05, 0xCE49A0F7 
           7.39393205320467245656e+02, // 0x40871B25, 0x48D4C029 
           1.55949003336666123687e+02, // 0x40637E5E, 0x3C3ED8D4 
           -4.95949898822628210127e+00, // 0xC013D686, 0xE71BE86B 
        ]
        (qr, qs)
      }
      3 => {
        let qr = [
          -5.07831226461766561369e-09, // 0xBE35CFA9, 0xD38FC84F 
           -1.02537829820837089745e-01, // 0xBFBA3FEB, 0x51AEED54 
           -4.61011581139473403113e+00, // 0xC01270C2, 0x3302D9FF 
           -5.78472216562783643212e+01, // 0xC04CEC71, 0xC25D16DA 
           -2.28244540737631695038e+02, // 0xC06C87D3, 0x4718D55F 
           -2.19210128478909325622e+02, // 0xC06B66B9, 0x5F5C1BF6 
        ]
        let qs = [
          4.76651550323729509273e+01, // 0x4047D523, 0xCCD367E4 
           6.73865112676699709482e+02, // 0x40850EEB, 0xC031EE3E 
           3.38015286679526343505e+03, // 0x40AA684E, 0x448E7C9A 
           5.54772909720722782367e+03, // 0x40B5ABBA, 0xA61D54A6 
           1.90311919338810798763e+03, // 0x409DBC7A, 0x0DD4DF4B 
           -1.35201191444307340817e+02, // 0xC060E670, 0x290A311F 
        ]
        (qr, qs)
      }
      5 => {
        let qr = [
          -2.08979931141764104297e-11, // 0xBDB6FA43, 0x1AA1A098 
           -1.02539050241375426231e-01, // 0xBFBA3FFF, 0xCB597FEF 
           -8.05644828123936029840e+00, // 0xC0201CE6, 0xCA03AD4B 
           -1.83669607474888380239e+02, // 0xC066F56D, 0x6CA7B9B0 
           -1.37319376065508163265e+03, // 0xC09574C6, 0x6931734F 
           -2.61244440453215656817e+03, // 0xC0A468E3, 0x88FDA79D 
        ]
        let qs = [
          8.12765501384335777857e+01, // 0x405451B2, 0xFF5A11B2 
           1.99179873460485964642e+03, // 0x409F1F31, 0xE77BF839 
           1.74684851924908907677e+04, // 0x40D10F1F, 0x0D64CE29 
           4.98514270910352279316e+04, // 0x40E8576D, 0xAABAD197 
           2.79480751638918118260e+04, // 0x40DB4B04, 0xCF7C364B 
           -4.71918354795128470869e+03, // 0xC0B26F2E, 0xFCFFA004 
        ]
        (qr, qs)
      }
      8 => {
        let qr = [
          0.00000000000000000000e+00, // 0x00000000, 0x00000000 
           -1.02539062499992714161e-01, // 0xBFBA3FFF, 0xFFFFFDF3 
           -1.62717534544589987888e+01, // 0xC0304591, 0xA26779F7 
           -7.59601722513950107896e+02, // 0xC087BCD0, 0x53E4B576 
           -1.18498066702429587167e+04, // 0xC0C724E7, 0x40F87415 
           -4.84385124285750353010e+04, // 0xC0E7A6D0, 0x65D09C6A 
        ]
        let qs = [
          1.61395369700722909556e+02, // 0x40642CA6, 0xDE5BCDE5 
           7.82538599923348465381e+03, // 0x40BE9162, 0xD0D88419 
           1.33875336287249578163e+05, // 0x4100579A, 0xB0B75E98 
           7.19657723683240939863e+05, // 0x4125F653, 0x72869C19 
           6.66601232617776375264e+05, // 0x412457D2, 0x7719AD5C 
           -2.94490264303834643215e+05, // 0xC111F969, 0x0EA5AA18 
        ]
        (qr, qs)
      }
      _ => panic()
    }
    (qr, qs)
  }

  let ix = __hi(x) & 0x7fffffff
  let ix = ix.reinterpret_as_int()
  let (p, q) = if ix >= 0x40200000 {
    qr_qs(8)
  } else if ix >= 0x40122E8B {
    qr_qs(5)
  } else if ix >= 0x4006DB6D {
    qr_qs(3)
  } else if ix >= 0x40000000 {
    qr_qs(2)
  } else {
    panic()
  }
  let z = 1.0 / (x * x)
  let r = p[0] + z * (p[1] + z * (p[2] + z * (p[3] + z * (p[4] + z * p[5]))))
  let s = 1.0 +
    z * (q[0] + z * (q[1] + z * (q[2] + z * (q[3] + z * (q[4] + z * q[5])))))
  (0.375 + r / s) / x
}

///|
test "j1" {
  fn assert_j1_ulp(input, expect) raise {
    assert_ulp(expect, j1(input), J1_MAX_ULP)
  }

  assert_j1_ulp(-0.8, -0.36884204609417)
  assert_j1_ulp(-0.7, -0.32899574154005895)
  assert_j1_ulp(-0.6, -0.28670098806391575)
  assert_j1_ulp(-0.5, -0.2422684576748739)
  assert_j1_ulp(-0.4, -0.19602657795531875)
  assert_j1_ulp(-0.3, -0.148318816273104)
  assert_j1_ulp(-0.2, -0.099500832639236)
  assert_j1_ulp(-0.1, -0.049937526036242)
  assert_j1_ulp(-0, -0)
  assert_j1_ulp(-3.141592653589793, -0.28461534317975284)
  assert_j1_ulp(-1.5707963267948966, -0.5668240889058739)
  assert_j1_ulp(-0.7853981633974483, -0.3631878383468673)
  assert_j1_ulp(0, 0)
  assert_j1_ulp(0.1, 0.049937526036242)
  assert_j1_ulp(0.2, 0.099500832639236)
  assert_j1_ulp(0.3, 0.148318816273104)
  assert_j1_ulp(0.4, 0.19602657795531875)
  assert_j1_ulp(0.5, 0.2422684576748739)
  assert_j1_ulp(0.6, 0.28670098806391575)
  assert_j1_ulp(0.7, 0.32899574154005895)
  assert_j1_ulp(0.8, 0.36884204609417)
  assert_j1_ulp(0.9, 0.4059495460788057)
  assert_j1_ulp(1, 0.4400505857449335)
  assert_j1_ulp(3.141592653589793, 0.28461534317975284)
  assert_j1_ulp(1.5707963267948966, 0.5668240889058739)
  assert_j1_ulp(0.7853981633974483, 0.3631878383468673)
  assert_j1_ulp(-1, -0.4400505857449335)
  assert_j1_ulp(-2, -0.5767248077568733)
  assert_j1_ulp(-3, -0.33905895852593637)
  assert_j1_ulp(-4, 0.06604332802354915)
  assert_j1_ulp(-5, 0.32757913759146523)
  assert_j1_ulp(-6, 0.27668385812756563)
  assert_j1_ulp(-7, 0.004682823482345837)
  assert_j1_ulp(-8, -0.2346363468539146)
  assert_j1_ulp(-9, -0.24531178657332528)
  assert_j1_ulp(1, 0.4400505857449335)
  assert_j1_ulp(2, 0.5767248077568733)
  assert_j1_ulp(3, 0.33905895852593637)
  assert_j1_ulp(4, -0.06604332802354915)
  assert_j1_ulp(5, -0.32757913759146523)
  assert_j1_ulp(6, -0.27668385812756563)
  assert_j1_ulp(7, -0.004682823482345837)
  assert_j1_ulp(8, 0.2346363468539146)
  assert_j1_ulp(9, 0.24531178657332528)
  assert_j1_ulp(10, 0.04347274616886144)
  assert_j1_ulp(100, -0.07714535201411217)
  assert_j1_ulp(1000, 0.004728311907089523)
  assert_j1_ulp(10000, 0.0036474507555295803)
  assert_j1_ulp(2.5, 0.49709410246427393)
  assert_j1_ulp(3.4, 0.17922585168150712)
  assert_j1_ulp(5.3, -0.3459608338011862)
  assert_j1_ulp(6.2, -0.23291656707322267)
  assert_j1_ulp(7.1, 0.025153274253910344)
  assert_j1_ulp(8.9, 0.2559023714439758)
  assert_j1_ulp(9.8, 0.09284009111281007)
  assert_j1_ulp(10.7, -0.12239942392717612)
  assert_j1_ulp(101.6, 0.02243294985022214)
  assert_j1_ulp(1.542, 0.5634545029920421)
  assert_j1_ulp(2.846, 0.3942184920070648)
  assert_j1_ulp(7.881, 0.21597108275134932)
  assert_j1_ulp(3.772, 0.024223060780135384)
  assert_j1_ulp(-1.542, -0.5634545029920421)
  assert_j1_ulp(-2.846, -0.3942184920070648)
  assert_j1_ulp(-7.881, -0.21597108275134932)
  assert_j1_ulp(-3.772, -0.024223060780135384)
  assert_j1_ulp(-1, -0.4400505857449335)
  assert_j1_ulp(0, 0)
  assert_j1_ulp(-0, -0)
  assert_j1_ulp(@double.not_a_number, @double.not_a_number)
  assert_j1_ulp(@double.infinity, 0)
  assert_j1_ulp(@double.neg_infinity, 0)
}
