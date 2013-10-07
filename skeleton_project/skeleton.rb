#!/usr/bin/ruby1.9.3

require "rubygems"
require "crystalscad"
require "require_all"
require_all "assemblies"
include CrystalScad

assembly = Example.new.show
subassembly = nil

def save(file,output,start_text=nil)
  file = File.open(file,"w")
  file.puts start_text unless start_text == nil
  file.puts output
  file.close
end

@@bom.save

assembly.save(File.expand_path(__FILE__).gsub(".rb","")+".scad","$fn=64;") if assembly
subassembly.save("part.scad","$fn=64;") if subassembly

Dir.mkdir("output") unless Dir.exists?("output")
parts = [Example]

parts.each do |part|
  name = part.to_s.downcase
  part.new.output.save("output/#{name}.scad","$fn=64;")
  if ARGV[0] == "build"
    puts "Building #{name}..."
    system("openscad -o output/#{name}.stl output/#{name}.scad")
  end

end

  
  



