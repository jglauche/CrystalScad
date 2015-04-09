#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad


parts = [
  Washer.new(4.3),
  Nut.new(4),
  Washer.new(4.3),
  Nut.new(4)
]
bolt = Bolt.new(4,16).show
bolt_assembly = bolt
bolt_assembly += stack({method:"output"}, *parts)

x,y,z = position(bolt)
bolt_assembly.translate(x:x*-1,y:y*-1,z:z*-1)

puts bolt_assembly.scad_output


