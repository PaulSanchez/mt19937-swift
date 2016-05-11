//
//  mt19937.swift
//  MT19937-swift
//
//  Ported to Swift by Paul J Sanchez on June-7-2014.
//
import Foundation

class MersenneTwister {
  // Magic numbers from the original C implementation...
  let NN = 312
  let MM = 156
  let UM: UInt64 = 0xFFFFFFFF80000000 // Most significant 33 bits
  let LM: UInt64 = 0x7FFFFFFF // Least significant 31 bits
  let mag01: Array<UInt64> = [0, 0xB5026F5AA96619E9]
  
  var mt: Array<UInt64>
  var mti: Int
  
  // initialize by an array
  init(seedBuffer: Array<UInt64>) {
    let arrayLength = seedBuffer.count
    mt = Array<UInt64>(count: NN, repeatedValue: UInt64(0))
    mt[0] = 19650218
    mti = 1
    while mti < NN {
      mt[mti] = 6364136223846793005 &* (mt[mti-1] ^ (mt[mti-1] >> 62))
        &+ UInt64(mti)
      mti += 1
    }
    var i = 1, j = 0
    var k = (NN > arrayLength) ? NN : arrayLength
    while k != 0 {
      mt[i] = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62))
        &* 3935559000370003845))
        &+ seedBuffer[j] &+ UInt64(j) // non linear
      i += 1
      j += 1
      if (i >= NN) {
        mt[0] = mt[NN-1]
        i=1
      }
      if (j>=arrayLength) {
        j=0
      }
      k -= 1
    }
    k = NN - 1
    while k != 0 {
      mt[i] = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 62))
        &* 2862933555777941757)) &- UInt64(i) // non linear
      i += 1
      if (i >= NN) {
        mt[0] = mt[NN-1]
        i=1
      }
      k -= 1
    }
    mt[0] = 1 << 63 // MSB is 1; assuring non-zero initial array
  }
  
  // initializes from /dev/random
  convenience init() {
    var bytes = Array<UInt8>(count: 2496, repeatedValue: 0)
    
    // NOTE: Update this when Swift gets ported to other platforms
    let inputStream = NSFileHandle(forReadingAtPath: "/dev/random")
    
    if nil == inputStream {
      perror("Opening /dev/random failed!")
      exit(-1)
    }
    
    let results = inputStream!.readDataOfLength(bytes.count)
    results.getBytes(&bytes, length: bytes.count)
    inputStream!.closeFile()
    var devRandBuffer = Array<UInt64>(count: bytes.count / 8, repeatedValue: 0)
    var counter = 0
    for b in bytes {
      let index = counter / 8
      counter += 1
      devRandBuffer[index] = devRandBuffer[index] << 8 + UInt64(b)
    }
    self.init(seedBuffer: Array<UInt64>(devRandBuffer))
  }
  
  // generates a random number on [0, 2^64-1]-interval */
  func unsignedInt64() -> UInt64 {
    var i: Int
    var x: UInt64
    
    if (mti >= NN) { /* generate NN words at one time */
      i = 0
      while i < NN - MM {
        x = (mt[i] & UM) | (mt[i+1] & LM)
        mt[i] = mt[i+MM] ^ (x >> 1) ^ mag01[Int(x&1)]
        i += 1
      }
      while i < NN - 1 {
        x = (mt[i] & UM) | (mt[i+1] & LM)
        mt[i] = mt[i+(MM-NN)] ^ (x>>1) ^ mag01[Int(x&1)]
        i += 1
      }
      x = (mt[NN-1] & UM) | (mt[0] & LM)
      mt[NN-1] = mt[MM-1] ^ (x>>1) ^ mag01[Int(x&1)]
      mti = 0
    }
    x = mt[mti]
    mti += 1
    x ^= (x >> 29) & 0x5555555555555555
    x ^= (x << 17) & 0x71D67FFFEDA60000
    x ^= (x << 37) & 0xFFF7EEE000000000
    x ^= (x >> 43)
    return x
  }
  
  // generates a random number on [0, 2^63-1]-interval
  func signedInt64() -> Int64 {
    return Int64(unsignedInt64() >> 1)
  }
  
  // generates a random number on [0,1]-real-interval
  func u0_1_Inclusive() -> Double {
    return Double(unsignedInt64() >> 11) / 9007199254740991.0
  }
  
  // generates a random number on [0,1)-real-interval
  func u0_1() -> Double {
    return Double(unsignedInt64() >> 11) / 9007199254740992.0
  }
  
  // generates a random number on (0,1)-real-interval
  func u0_1_Exclusive() -> Double {
    return (Double(unsignedInt64() >> 12) + 0.5) / 4503599627370496.0
  }
  
}
