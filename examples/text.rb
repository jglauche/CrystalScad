#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad

string = "CrystalScad!"

res = text(text: string)
res += text(text: string, size: 3).translate(y: 10)
res += text(text: string, spacing: 0.75).translate(y: 20)
res.save("text.scad")
