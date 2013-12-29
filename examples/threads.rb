#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad

# This example shows the use of ScrewThreads in CrystalScad.

class BlackBox < CrystalScad::Assembly
	# This is a box (the part that you want to make a mount for)

	def initialize
		@x=200
		@y=100
		@z=50
	end
	
	#	note: when you design a box like that, make sure that it starts at 0,0,0
	def show
		cube([@x,@y,@z]).color(r:10,b:10,g:10,a:150)
	end

	# We're defining threads on every side. It must be called thread_side
	# where side is either top, bottom, left, right, front, back
	def threads_top
		holes =*ScrewThread.new(x:50,y:50,size:8,depth:10)	 # note that =* creates an Array
		holes << ScrewThread.new(x:150,y:50,size:8,depth:10)	# and << adds stuff to an Array
	end 
	
	def threads_bottom
		holes =*ScrewThread.new(x:50,y:50,size:8,depth:10)	
	end

	# note that the coordinates for the threads are needed in 2 directions from 0,0,0
	# on top and bottom you're defining x & y
	# on left and right you're defining y & z
	# on front and back you're defining x & z
	def threads_left
		holes =*ScrewThread.new(y:15,z:10,size:3,depth:5)	
		holes << ScrewThread.new(y:40,z:30,size:3,depth:5)	
	end

	def threads_right
		holes =*ScrewThread.new(y:15,z:10,size:3,depth:5)	
		holes << ScrewThread.new(y:40,z:30,size:3,depth:5)	
	end

	# this example has different thread sizes for m3 and m6
	def threads_front
		holes =*ScrewThread.new(x:20,z:10,size:3,depth:5)	
		holes << ScrewThread.new(x:100,z:20,size:6,depth:25)	
		holes << ScrewThread.new(x:140,z:20,size:6,depth:25)	
		holes << ScrewThread.new(x:180,z:45,size:3,depth:5)	
	end

	def threads_back
		holes =*ScrewThread.new(x:20,z:10,size:3,depth:5)	
		holes << ScrewThread.new(x:100,z:25,size:12,depth:25)	
		holes << ScrewThread.new(x:180,z:45,size:3,depth:5)	
	end
	
end

# this is what a basic mount looks like. 
class BlackBoxMountTop < CrystalScad::Printed
	def part(show)
		box = BlackBox.new
		mount = cube(x:200,y:100,z:7)
		# the mount should either be a cube or an object that returns x,y,z as dimensions
		# if you have a complicated part, split the cube and add it later on to your object
		# Alternatively, define height in the arguments.
	
		# create_bolts needs the face as first argument, your new mount as second argument
		# and the object that has the threads as third argument
		# it accepts an hash of arguments as 4th argument. You can define
		#	height: define a custom height of your mount
		# bolt_height: custom height for your bolt(s). Can also be an array for different lengths.
		#							 This is useful if the automatic length calculation doesn't produce values
		#							 that are available.  
		# 						 This example would, without the setting 16 produce a M8x17 bolt. We don't have
		#							 that size, so we use M8x16 instead.

		bolts = create_bolts("top",mount,box,bolt_height:16)
		mount-=bolts
		mount+=bolts if show

		res = mount.translate(z:box.z)
		res += box.show if show
		res	
	end
end

class BlackBoxMountBottom < CrystalScad::Printed
	def part(show)
		box = BlackBox.new
		mount = cube(x:200,y:100,z:z=2)
		# note that the bolt height bom output is unchecked in this and the following examples
		bolts = create_bolts("bottom",mount,box)
		mount-=bolts
		mount+=bolts if show

		res = mount.translate(z:-z)
		res += box.show if show
		res
	end
end

class BlackBoxMountLeft < CrystalScad::Printed
	def part(show)
		box = BlackBox.new
		mount = cube(x:x=5,y:100,z:50)


		bolts = create_bolts("left",mount,box)
		mount-=bolts
		mount+=bolts if show

		res = mount.translate(x:-x)
		res += box.show if show
		res
	end
end

class BlackBoxMountRight < CrystalScad::Printed
	def part(show)
		box = BlackBox.new
		mount = cube(x:5,y:100,z:50)
		
		bolts = create_bolts("right",mount,box)
		mount-=bolts
		mount+=bolts if show

		res = mount.translate(x:box.x)
		res += box.show if show
		res
	end
end

class BlackBoxMountFront < CrystalScad::Printed
	def part(show)
		box = BlackBox.new
		mount = cube(x:box.x,y:y=15,z:box.z)
		
		bolts = create_bolts("front",mount,box)
		mount-=bolts
		mount+=bolts if show

		res = mount.translate(y:-y)
		res += box.show if show
		res
	end
end

class BlackBoxMountBack < CrystalScad::Printed
	def part(show)
		box = BlackBox.new
		mount = cube(x:box.x,y:35,z:box.z)
		
		bolts = create_bolts("back",mount,box)
		mount-=bolts
		mount+=bolts if show

		res = mount.translate(y:box.y)
		res += box.show if show
		res
	end
end


b=CrystalScadObject.new

# uncomment as many mounts as you like here

b +=BlackBoxMountTop.new.show
#b +=BlackBoxMountBottom.new.show
#b +=BlackBoxMountLeft.new.show
#b +=BlackBoxMountRight.new.show
#b +=BlackBoxMountFront.new.show
#b +=BlackBoxMountBack.new.show

# you can also try output instead of show
#b =BlackBoxMountTop.new.output

# Uncomment this for checking the BOM output
# puts @@bom.output

b.save("threads.scad")
