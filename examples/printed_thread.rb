#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad


t1 = PrintedThread.new
res = t1.show

res.save("printed_thread.scad")

