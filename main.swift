//
//  main.swift
//  MT19937-swift
//
//  Created by Paul J Sanchez on 6/7/14.
//  Copyright (c) 2014-2016 Paul Sanchez. All rights reserved.
//

import Foundation

var seeds:[UInt64] = [UInt64(0x12345), UInt64(0x23456),
                      UInt64(0x34567), UInt64(0x45678)]
var mt = MersenneTwister(seedBuffer: seeds)

print("1000 outputs of unsignedInt64()")

for var i in 1...1000 {
  let result = NSString(format:"%20llu", mt.unsignedInt64())
  print("\(result) ", terminator: "")
  if (i % 5 == 0) {
    print("")
  }
}

print("")

print("1000 outputs of u0_1()")

var i = 0
for var i in 1...1000 {
  let result = NSString(format:"%10.8f", mt.u0_1())
  print("\(result) ", terminator: "")
  if (i % 5 == 0) {
    print("")
  }
}
