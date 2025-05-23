///| Computes the scaled complementary error function erfcx(x) = exp(x^2) * erfc(x).
pub fn erfcx(x : Double) -> Double {
  let pinf = 0x7ff0_0000_0000_0000UL.reinterpret_as_double()
  let a = fabs(x)
  let p = a + 2.0
  let r = 1.0 / p
  let q = fma(-4.0, r, 1.0)
  let t = fma(q + 1.0, -2.0, a)
  let e = fma(-a, q, t)
  let q = fma(r, e, q)
  let mut p = 5.92619181e-5

  // Approximate (1+2*a)*exp(a*a)*erfc(a) as p(q)+1 for q in [-1,1]
  p = fma(p, q, 1.61231728e-4)
  p = fma(p, q, -3.46499495e-4)
  p = fma(p, q, -1.39683776e-3)
  p = fma(p, q, 1.20587996e-3)
  p = fma(p, q, 8.69013276e-3)
  p = fma(p, q, -8.01389851e-3)
  p = fma(p, q, -5.42122647e-2)
  p = fma(p, q, 1.64048553e-1)
  p = fma(p, q, -1.66031078e-1)
  p = fma(p, q, -9.27637145e-2)
  p = fma(p, q, 2.76978403e-1)

  // Divide (1+p) by (1+2*a) ==> exp(a*a)*erfc(a)
  let d = fma(0.25, a, 0.125)
  let r = 1.0 / d
  let q = fma(p, r, r)
  let e = fma(fma(-a, q, 4.0), 0.25, fma(-0.125, q, p))
  let mut r = 0.125 * fma(e, r, q)
  if a == pinf {
    r = 0.0
  }

  // Handle negative arguments: erfcx(x) = 2*exp(x*x) - erfcx(|x|)
  if x < 0.0 {
    let s = x * x
    let d = fma(x, x, -s)
    let e = exp(s)
    r = e - r
    r = fma(e, d + d, r)
    r = r + e
    if e == pinf {
      r = e
    }
  } // avoid creating NaN
  r
}
