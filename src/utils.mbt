// Constants
// let int_max : Int = 0x7fffffff
let double_nan : Double = (0x7fffffff_ffffffffUL).reinterpret_as_double()
let double_pos_inf : Double = (0x7ff00000_00000000UL).reinterpret_as_double()
let double_neg_inf : Double = (0xfff00000_00000000UL).reinterpret_as_double()
// pub let double_max : Double = (0x7fefffffffffffffUL).reinterpret_as_double()
// pub let double_pi : Double = pi

// epsilon
let double_epsilon : Double = 0x0.0000000000001P-1022
// const DoubleEpsilon : Double = 0x0.0000000000001P-1022

// Computation Utilities
fn __hi(x: Double) -> UInt {
  (x.reinterpret_as_uint64() >> 32).to_uint()
}

fn __low(x: Double) -> UInt {
  (x.reinterpret_as_uint64()).to_uint()
}

fn __combine(hi: UInt64, low: UInt64) -> Double {
  (hi << 32 | low).reinterpret_as_double()
}

fn __combineQ(hi: UInt64, low: UInt64) -> Double {
  (hi << 32 | low).reinterpret_as_double()
}

fn __combineW(hi: UInt, low: UInt) -> Double {
  __combineQ(hi.to_uint64(), low.to_uint64())
}

fn copysign(x: Double, y: Double) -> Double {
  let hx : UInt = __hi(x)
  let hy : UInt = __hi(y)
  __combineW((hx & 0x7fffffff | hy & 0x80000000), __low(x))
}

fn abs_i64(x: Int64) -> Int64 {
  if x < 0 {
    -x
  } else {
    x
  }
}

fn max_element(elements: Array[Double]) -> (Double, Int) {
  let mut max_val = elements[0]
  let mut idx = 0

  for i, v in elements {
    if v > max_val {
      max_val = v
      idx = i
    }
  }

  (max_val, idx)
}

// Ulp Error
// 1. if x is Nan, y is Nan, return 0
// 2. if x is +inf, y is +inf, return 0
// 3. if x is -inf, y is -inf, return 0
// 4. if x/y is NaN, y/x is not NaN, return INT_MAX
// 5. if x/y is +inf, y/x is not +inf, return INT_MAX
// 6. if x/y is -inf, y/x is not -inf, return INT_MAX
// 7. if x/y not inf, nan, return IEEE754(x) - IEEE754(y) |> abs
fn ulp_error(x: Double, y : Double) -> Int64 {
  let xisnan : Bool = isnan(x)
  let yisnan : Bool = isnan(y)
  let xispinf : Bool = isinf(x) && x > 0
  let yispinf : Bool = isinf(y) && y > 0
  let xisninf : Bool = isinf(x) && x < 0
  let yisninf : Bool = isinf(y) && y < 0

  if xisnan && yisnan {
    return 0
  }

  if xispinf && yispinf {
    return 0
  }

  if xisninf && yisninf {
    return 0
  }

  if xisnan && not(yisnan) {
    return INT64_MAX
  }

  if yisnan && not(xisnan) {
    return INT64_MAX
  }

  if xispinf && not(yispinf) {
    return INT64_MAX
  }

  if yispinf && not(xispinf) {
    return INT64_MAX
  }

  if xisninf && not(yisninf) {
    return INT64_MAX
  }

  if yisninf && not(xisninf) {
    return INT64_MAX
  }

  let xi : Int64 = x.reinterpret_as_int64()
  let yi : Int64 = y.reinterpret_as_int64()

  let diff = xi - yi

  abs_i64(diff)
}

fn assert_ulp(expect: Double, actual : Double, min_ulp: Int) -> Unit!Error {
  let min_ulp: Int64 = min_ulp.to_int64()
  let ulp_err = ulp_error(expect, actual)
  if ulp_err > min_ulp {
    println("expect: \{expect}, actual: \{actual}, ulp error: \{ulp_err}, min ulp: \{min_ulp}")
    assert_eq!(1, 0)
  }
}

let pi4a = 0x0.C90FDA000000000011B5

let pi4b = 0x0.000000A2216800000988

let pi4c = 0x0.000000000000C234BE07

// pub const PI = 0x3.243F6A8885A308CA8A54

let pi4 : Double = 4.0 / PI
let sin_ = [
  0x0.00000000AEC7E8FE9D35, -0x0.0000006B9796A4A487D, 0x0.00002E3BC6ACFA913766, -1.98412698295895385996e-4,
  0x0.02222222221EFA06A21A, -0x0.2AAAAAAAAAAA90C58591,
]
let cos_ = [
  -0x0.000000000C7D24D03C8, 0x0.00000008F74EBDA72B71, -0x0.0000049F93DFAB12FDC6,
  0x0.0001A01A019C844F3E07, -0x0.005B05B05B053E453C34, 0x0.0AAAAAAAAAAAA55A47E1,
]

fn absmaximum(vec: Array[Double]) -> Double {
  let mut max : Double = 0.0
  for p in vec {
    let ap = fabs(p)
    if ap > max {
      max = ap
    }
  }
  max
}

fn square(x: Double) -> Double {
  x * x
}
