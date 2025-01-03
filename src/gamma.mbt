///| Compute Gamma function
pub fn gamma(x : Double) -> Double {
  if isinf(x) || isnan(x) {
    return x
  }

  if x == 0.0 {
    return double_pos_inf
  }

  let pi  =  3.14159265358979311600e+00 // 0x400921FB 0x54442D18
  let a0  =  7.72156649015328655494e-02 // 0x3FB3C467 0xE37DB0C8
  let a1  =  3.22467033424113591611e-01 // 0x3FD4A34C 0xC4A60FAD
  let a2  =  6.73523010531292681824e-02 // 0x3FB13E00 0x1A5562A7
  let a3  =  2.05808084325167332806e-02 // 0x3F951322 0xAC92547B
  let a4  =  7.38555086081402883957e-03 // 0x3F7E404F 0xB68FEFE8
  let a5  =  2.89051383673415629091e-03 // 0x3F67ADD8 0xCCB7926B
  let a6  =  1.19270763183362067845e-03 // 0x3F538A94 0x116F3F5D
  let a7  =  5.10069792153511336608e-04 // 0x3F40B6C6 0x89B99C00
  let a8  =  2.20862790713908385557e-04 // 0x3F2CF2EC 0xED10E54D
  let a9  =  1.08011567247583939954e-04 // 0x3F1C5088 0x987DFB07
  let a10 =  2.52144565451257326939e-05 // 0x3EFA7074 0x428CFA52
  let a11 =  4.48640949618915160150e-05 // 0x3F07858E 0x90A45837
  let tc  =  1.46163214496836224576e+00 // 0x3FF762D8 0x6356BE3F
  let tf  = -1.21486290535849611461e-01 // 0xBFBF19B9 0xBCC38A42
  // tt = -(tail of tf)
  let tt  = -3.63867699703950536541e-18 // 0xBC50C7CA 0xA48A971F
  let t0  =  4.83836122723810047042e-01 // 0x3FDEF72B 0xC8EE38A2
  let t1  = -1.47587722994593911752e-01 // 0xBFC2E427 0x8DC6C509
  let t2  =  6.46249402391333854778e-02 // 0x3FB08B42 0x94D5419B
  let t3  = -3.27885410759859649565e-02 // 0xBFA0C9A8 0xDF35B713
  let t4  =  1.79706750811820387126e-02 // 0x3F9266E7 0x970AF9EC
  let t5  = -1.03142241298341437450e-02 // 0xBF851F9F 0xBA91EC6A
  let t6  =  6.10053870246291332635e-03 // 0x3F78FCE0 0xE370E344
  let t7  = -3.68452016781138256760e-03 // 0xBF6E2EFF 0xB3E914D7
  let t8  =  2.25964780900612472250e-03 // 0x3F6282D3 0x2E15C915
  let t9  = -1.40346469989232843813e-03 // 0xBF56FE8E 0xBF2D1AF1
  let t10 =  8.81081882437654011382e-04 // 0x3F4CDF0C 0xEF61A8E9
  let t11 = -5.38595305356740546715e-04 // 0xBF41A610 0x9C73E0EC
  let t12 =  3.15632070903625950361e-04 // 0x3F34AF6D 0x6C0EBBF7
  let t13 = -3.12754168375120860518e-04 // 0xBF347F24 0xECC38C38
  let t14 =  3.35529192635519073543e-04 // 0x3F35FD3E 0xE8C2D3F4
  let u0  = -7.72156649015328655494e-02 // 0xBFB3C467 0xE37DB0C8
  let u1  =  6.32827064025093366517e-01 // 0x3FE4401E 0x8B005DFF
  let u2  =  1.45492250137234768737e+00 // 0x3FF7475C 0xD119BD6F
  let u3  =  9.77717527963372745603e-01 // 0x3FEF4976 0x44EA8450
  let u4  =  2.28963728064692451092e-01 // 0x3FCD4EAE 0xF6010924
  let u5  =  1.33810918536787660377e-02 // 0x3F8B678B 0xBF2BAB09
  let v1  =  2.45597793713041134822e+00 // 0x4003A5D7 0xC2BD619C
  let v2  =  2.12848976379893395361e+00 // 0x40010725 0xA42B18F5
  let v3  =  7.69285150456672783825e-01 // 0x3FE89DFB 0xE45050AF
  let v4  =  1.04222645593369134254e-01 // 0x3FBAAE55 0xD6537C88
  let v5  =  3.21709242282423911810e-03 // 0x3F6A5ABB 0x57D0CF61
  let s0  = -7.72156649015328655494e-02 // 0xBFB3C467 0xE37DB0C8
  let s1  =  2.14982415960608852501e-01 // 0x3FCB848B 0x36E20878
  let s2  =  3.25778796408930981787e-01 // 0x3FD4D98F 0x4F139F59
  let s3  =  1.46350472652464452805e-01 // 0x3FC2BB9C 0xBEE5F2F7
  let s4  =  2.66422703033638609560e-02 // 0x3F9B481C 0x7E939961
  let s5  =  1.84028451407337715652e-03 // 0x3F5E26B6 0x7368F239
  let s6  =  3.19475326584100867617e-05 // 0x3F00BFEC 0xDD17E945
  let r1  =  1.39200533467621045958e+00 // 0x3FF645A7 0x62C4AB74
  let r2  =  7.21935547567138069525e-01 // 0x3FE71A18 0x93D3DCDC
  let r3  =  1.71933865632803078993e-01 // 0x3FC601ED 0xCCFBDF27
  let r4  =  1.86459191715652901344e-02 // 0x3F9317EA 0x742ED475
  let r5  =  7.77942496381893596434e-04 // 0x3F497DDA 0xCA41A95B
  let r6  =  7.32668430744625636189e-06 // 0x3EDEBAF7 0xA5B38140
  let w0  =  4.18938533204672725052e-01 // 0x3FDACFE3 0x90C97D69
  let w1  =  8.33333333333329678849e-02 // 0x3FB55555 0x5555553B
  let w2  = -2.77777777728775536470e-03 // 0xBF66C16C 0x16B02E5C
  let w3  =  7.93650558643019558500e-04 // 0x3F4A019F 0x98CF38B6
  let w4  = -5.95187557450339963135e-04 // 0xBF4380CB 0x8C0FE741
  let w5  =  8.36339918996282139126e-04 // 0x3F4B67BA 0x4CDAD5D1
  let w6  = -1.63092934096575273989e-03 // 0xBF5AB89D 0x0B9E43E4 

  let mut x = x
  let hx = __hi(x).reinterpret_as_int()
  let ix = hx & 0x7fffffff
  let mut t = 0.0
  let mut nadj = 0.0
  let mut r = 0.0
  let mut y = 0.0
  let mut i = 0
  let mut z = 0.0
  let mut p1 = 0.0
  let mut p2 = 0.0
  let mut p3 = 0.0
  let mut p = 0.0
  let mut q = 0.0
  let mut w = 0.0

  if ix < 0x3b900000 {
    if hx < 0 {
      return -log(-x)
    } else {
      return -log(x)
    }
  }
  if hx < 0 {
    if ix >= 0x43300000 {
      return double_pos_inf
    }
    t = sinpi(x)
    if t == 0.0 {
      return double_pos_inf
    }
    nadj = log(pi / fabs(t * x))
    x = -x
  }

  if fabs(x) == 1.0 || fabs(x) == 2.0 {
    r = 0.0
  } else if fabs(x) < 2.0 {
    if ix <= 0x3feccccc {
      r = -log(x)
      if ix >= 0x3FE76944 {
        y = 1.0 - x
        i = 0
      } else if ix >= 0x3FCDA661 {
        y = x - (tc - 1.0)
        i = 1
      } else {
        y = x
        i = 2
      }
    } else {
      r = 0.0
      if ix >= 0x3FFBB4C3 {
        y = 2.0 - x
        i = 0
      } else if ix >= 0x3FF3B4C4 {
        y = x - tc
        i = 1
      } else {
        y = x - 1.0
        i = 2
      }
    }
    
    match i {
      0 => {
        z = y * y
        p1 = a0 + z * (a2 + z * (a4 + z * (a6 + z * (a8 + z * a10))))
        p2 = z * (a1 + z * (a3 + z * (a5 + z * (a7 + z * (a9 + z * a11)))))
        p = y * p1 + p2
        r += (p - 0.5 * y)
      }
      1 => {
        z = y * y
        w = z * y
        p1 = t0 + w * (t3 + w * (t6 + w * (t9 + w * t12)))
        p2 = t1 + w * (t4 + w * (t7 + w * (t10 + w * t13)))
        p3 = t2 + w * (t5 + w * (t8 + w * (t11 + w * t14)))
        p = z * p1 - (tt - w * (p2 + y * p3))
        r += (tf + p)
      }
      2 => {
        p1 = y * (u0 + y * (u1 + y * (u2 + y * (u3 + y * (u4 + y * u5)))))
        p2 = 1.0 + y * (v1 + y * (v2 + y * (v3 + y * (v4 + y * v5))))
        r += (-0.5 * y + p1 / p2)
      }
      _ => {panic()}
    }
  } else if fabs(x) < 8.0 {
    i = x.to_int()
    t = 0.0
    y = x - i.to_double()
    p = y * (s0 + y * (s1 + y * (s2 + y * (s3 + y * (s4 + y * (s5 + y * s6))))))
    q = 1.0 + y * (r1 + y * (r2 + y * (r3 + y * (r4 + y * (r5 + y * r6)))))
    r = 0.5 * y + p / q
    z = 1.0
    match i {
      7 => z *= (y + 6.0)
      6 => z *= (y + 5.0)
      5 => z *= (y + 4.0)
      4 => z *= (y + 3.0)
      3 => z *= (y + 2.0)
      _ => {panic()}
    }
    r += log(z)
  } else if ix < 0x43900000 {
    t = log(x)
    z = 1.0 / x
    y = z * z
    w = w0 + z * (w1 + y * (w2 + y * (w3 + y * (w4 + y * (w5 + y * w6)))))
    r = (x - 0.5) * (t - 1.0) + w
  } else {
    r = x * (log(x) - 1.0)
  }

  if hx < 0 {
    r = nadj - r
  }

  r
}
