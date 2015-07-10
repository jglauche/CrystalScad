#    This file is part of CrystalScad.
#
#    CrystalScad is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    CrystalScad is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with CrystalScad.  If not, see <http://www.gnu.org/licenses/>fre.

require "rubygems"
require "rubyscad"
$fn = 64

module CrystalScad 
	include CrystalScad::BillOfMaterial
	include CrystalScad::Hardware
	include CrystalScad::LinearBearing
	include CrystalScad::Gears
	include CrystalScad::ScrewThreads
	include CrystalScad::PrintedThreads
	include CrystalScad::Extras
	include Math




	class Transformation < CrystalScadObject
	end

	class Rotate < Transformation
		def to_rubyscad
			return RubyScadBridge.new.rotate(@args).gsub('"','')		
		end	
	end

 	class Translate < Transformation
		def to_rubyscad
			return RubyScadBridge.new.translate(@args).gsub('"','')		
		end	
	end
	
 	class Mirror < Transformation
		def to_rubyscad
			return RubyScadBridge.new.mirror(@args)		
		end	
	end
	
	class Scale < Transformation
		def to_rubyscad
			return RubyScadBridge.new.scale(@args)		
		end
	end
	
	class Cylinder < Primitive
		def to_rubyscad	
			return RubyScadBridge.new.cylinder(@args)		
		end	
	end

	def cylinder(args)
		# inner diameter handling
		if args[:id]		
			id = args.delete(:id)	
			args2 = args.dup
			args2[:d] = id

			if args[:ih]
				# if it has an inner height, add a tiny bit to the bottom
				ih = args.delete(:ih)
				args2[:h] = ih + 0.01
			else	
				# otherwise add to both bottom and top to make a clear cut in OpenSCAD
				args2[:h] += 0.02
			end

			# if we have a ifn value, change the fn value of the inner cut
			if args[:ifn]
				ifn = args.delete(:ifn)
				args2[:fn] = ifn			
			end

			return cylinder(args) - cylinder(args2).translate(z:-0.01)
		end
	
		Cylinder.new(args)		
	end
	
	class Cube < Primitive
	  attr_accessor :x,:y,:z
	  
	  def initialize(*args)
	    super(args)
	    @x,@y,@z = args[0][:size].map{|l| l.to_f}
	  end

		def center_xy
			@transformations << Translate.new({x:-@x/2,y:-@y/2})
			self
		end

		def center_x
			@transformations << Translate.new({x:-@x/2})
			self
		end

		def center_y
			@transformations << Translate.new({y:-@y/2})
			self
		end

		def center_z
			@transformations << Translate.new({z:-@z/2})
			self
		end

		def center
			@transformations << Translate.new({x:-@x/2,y:-@y/2,z:-@z/2})
			self
		end
	
		def to_rubyscad
			return RubyScadBridge.new.cube(@args)		
		end	
	end

	def cube(args={},y=nil,z=nil)
		if args.kind_of? Array
			args = {size:args}
		elsif args.kind_of? Hash
		  args[:x] ||= 0
		  args[:y] ||= 0
		  args[:z] ||= 0
		  args = {size:[args[:x],args[:y],args[:z]]}		
		elsif args.kind_of? Numeric
			x = args
			args = {size:[x,y,z]}
		end	
		Cube.new(args)	
	end
	
	class Sphere < Primitive
		def to_rubyscad	
			return RubyScadBridge.new.sphere(@args)		
		end	
	end

	def sphere(args)
		Sphere.new(args)		
	end
		
	class Polyhedron < Primitive
		def to_rubyscad	
			return RubyScadBridge.new.polyhedron(@args)		
		end			
	end

	def polyhedron(args)
		Polyhedron.new(args)
	end
	

	#	2d primitives
	class Square < Primitive
	  def initialize(*args)
	    super(args)
			if args[0][:size].kind_of? Array
		    @x,@y = args[0][:size].map{|l| l.to_f}
			else
				@x = args[0][:size].to_f
				@y = @x
			end		
	  end

		def to_rubyscad
			return RubyScadBridge.new.square(@args)		
		end			
		
		def center_xy
			@transformations << Translate.new({x:-@x/2,y:-@y/2})
			self
		end
    alias center center_xy

		def center_x
			@transformations << Translate.new({x:-@x/2})
			self
		end

		def center_y
			@transformations << Translate.new({y:-@y/2})
			self
		end

				
	end

	def square(args,y=nil)
		if args.kind_of? Array
			args = {size:args}
		elsif args.kind_of? Numeric
			x = args
			args = {size:[x,y]}			
		elsif args.kind_of? Hash
		  unless args[:size]
		    args[:x] ||= 0
		    args[:y] ||= 0
		    args = {size:[args[:x],args[:y]]}		
      end
		end
		Square.new(args)	
	end

	class Circle < Primitive
		def to_rubyscad
			return RubyScadBridge.new.circle(@args)		
		end			
	end

	def circle(args)
		Circle.new(args)	
	end

	class Polygon < Primitive
		def to_rubyscad
			return RubyScadBridge.new.polygon(@args)		
		end			
	end

	def polygon(args)
		Polygon.new(args)	
	end

	
	class RubyScadBridge
		include RubyScad

		def raw_output(str)
			return str
		end

		def format_output(str)
			return str
		end

		def format_block(output_str)
			return output_str
		end
	end

  class AdvancedPrimitive < Primitive
    
    
    def initialize(attributes)
      @attr = attributes.collect { |k, v| "#{k} = \"#{v}\"" }.join(', ')
      super
    end
    
  	def to_rubyscad
			"#{@operation}(#{@attr});"
		end
  
  end


  class Text < AdvancedPrimitive
		def initialize(attributes)
			@operation = "text"
			super(attributes)
		end
  end

	def text(args={})
		return Text.new(args)				
	end


	class CSGModelling < Primitive
		def initialize(*list)
			@transformations = []
			@children = list
		end

		def to_rubyscad
			@children ||= []			
			ret = "#{@operation}(){"
			@children.each do |child|	
				begin
					ret +=child.walk_tree
				rescue NoMethodError	
				end
			end
			#puts @children.map{|l| l.walk_tree_classes}.inspect

			ret +="}"			
		end
	end	

	class Union < CSGModelling		
		def initialize(*list)
			@operation = "union"
			super(*list)
		end
	end

	class Difference < CSGModelling		
		def initialize(*list)
			@operation = "difference"
			super(*list)
		end
	end

	class Intersection < CSGModelling		
		def initialize(*list)
			@operation = "intersection"
			super(*list)
		end
	end

	class Hull < CSGModelling		
		def initialize(*list)
			@operation = "hull"
			super(*list)
		end
	end

	def optimize_union(top, child)
		if top.kind_of? Union and not child.kind_of? Union and top.transformations.to_a.size == 0
			top.children << child
			return top
		else
			return Union.new(top,child)
		end
	end

	def optimize_difference(top, child)
		if top.kind_of? Difference and not child.kind_of? Difference
			top.children << child
			return top
		else
			return Difference.new(top,child)
		end
	end

	def +(args)	
		return Union.new(nil,args)	 if self == nil		
		if args.kind_of? Array
			r = self			
			args.each do |a|
			#	if a.respond_to? :show
			#		r = Union.new(r,a.show)	
			#	else
					r = Union.new(r,a)	
			#	end
			end
			r
		else
			optimize_union(self,args)
		end		
	end

	def -(args)
		return args	 if self == nil		
		if args.kind_of? Array
			r = self			
			args.each do |a|
				#if a.respond_to? :output
				#	r = Difference.new(r,a.output)	
				#else	
					r = Difference.new(r,a)	
				#end
			end
			r
		else
			optimize_difference(self,args)
		end
	end
	
	def *(args)
		return args	 if self == nil		
		Intersection.new(self,args)
	end
	
	def hull(*parts)
	  Hull.new(*parts)	  
	end


	class Import < Primitive
		def initialize(args)
			@transformations = []
			@children = []			
		
			if args.kind_of? String
			  filename = args
			else # assume hash otherwise
			  filename = args[:file]
			  @layer = args[:layer]
			end			
			
			
			# we need to convert relative to absolute paths if the openscad output is not in the same directory
			# as the crystalscad program.
			@filename = File.expand_path(filename) 		
		end		
		
		def to_rubyscad	
		  layer = ""
		  if @layer
		    layer = ",layer=\"#{@layer}\""
		  end
			res = self.children.map{|l| l.walk_tree}
			if res == []
				res = ""
			end
 			res += RubyScadBridge.new.import("file=\""+@filename.to_s+"\"#{layer}") # apparently the quotes get lost otherwise
			res		
		end	
	end

	def import(filename)
		Import.new(filename)
	end

	class Render < Primitive
		def initialize(object, attributes)
			@operation = "render"
			@children = [object]
			super(object, attributes)
		end		

		def to_rubyscad	
		  layer = ""
		  if @layer
		    layer = ",layer=\"#{@layer}\""
		  end
			res = ""			
			self.children.map{|l| res += l.walk_tree}
 			res += RubyScadBridge.new.render
			res		
		end	

	end
	
	def render(args={})
		return Render.new(self,args)		
	end


	class CSGModifier < Primitive
		def initialize(object, attributes)
			@transformations = []
			@children = [object]
			@attributes = attributes
		end

		def to_rubyscad	
 			#	Apparently this doesn't work for CSGModifiers, like it does for other things in RubyScad?
		  # also this is a dirty, dirty hack. 	
			@attributes = @attributes.gsub("fn","$fn").gsub("$$","$") 
			ret = "#{@operation}(#{@attributes}){"
			@children ||= []			
			@children.each do |child|	
				begin
					ret +=child.walk_tree
				rescue NoMethodError
				end
			end
			ret +="}"			
		end
	end	

	class Color < CSGModifier
		def initialize(object, attributes)
			@operation = "color"
			if attributes.kind_of? String
				attributes = "\"#{attributes}\""			
			elsif attributes.kind_of? Hash
				attributes[:a] ||= 255
				
				r = attributes[:r].to_f / 255.0
				g = attributes[:g].to_f / 255.0
				b = attributes[:b].to_f / 255.0
				a = attributes[:a].to_f / 255.0
				attributes = [r,g,b,a]
			end
			
			super(object, attributes)
		end
	end

	class LinearExtrude < CSGModifier
		def initialize(object, attributes)
			@operation = "linear_extrude"
			super(object, attributes)
		end
	end

	class RotateExtrude < CSGModifier
		def initialize(object, attributes)
			@operation = "rotate_extrude"
			super(object, attributes)
		end
	end

	class Projection < CSGModifier
		def initialize(object, attributes)
			@operation = "projection"
			super(object, attributes)
		end
	end
	
	def color(args)
		return Color.new(self,args)		
	end


	def linear_extrude(args)
		if args[:h]	# rename to height
			args[:height] = args[:h]
			args.delete(:h)
		end
		args = args.collect { |k, v| "#{k} = #{v}" }.join(', ')
		return LinearExtrude.new(self,args)				
	end

	def rotate_extrude(args={})
		if args[:h]	# rename to height
			args[:height] = args[:h]
			args.delete(:h)
		end
		args = args.collect { |k, v| "#{k} = #{v}" }.join(', ')	
		return RotateExtrude.new(self,args)				
	end

	def projection(args={})
		args = args.collect { |k, v| "#{k} = #{v}" }.join(', ')
		return Projection.new(self,args)				
	end


	#	Deprecated: Stacks parts along the Z axis
	# works on all Assemblies that have a @height definition
	# TODO: Make a better functionality similar to this, that is:
	#				- easier to use
	#				- throws better error messages
	#				- doesn't assume that everything falls down like gravity in every case		
	def stack(args={}, *parts)
		args[:method] ||= "show"
		args[:spacing] ||= 0
		puts "CrystalScad Warning: Please note that the stack method is deprecated and will be removed or replaced in the future"
		@assembly = nil		
		z = 0
		parts.each do |part|
			item = (part.send args[:method])
			next if item == nil or !item.respond_to? "translate"
			@assembly += item.translate(z:z)
			z+= part.height	+ args[:spacing]
		end
		@assembly
	end

	def get_position_rec(obj, level=0)
		position = [0,0,0]
		return position if obj == nil
		obj.each do |o|
			o.transformations.each do |t|
				if t.class == Translate
					t.args[:x] ||= 0
					t.args[:y] ||= 0
					t.args[:z] ||= 0
					position[0] += t.args[:x]
					position[1] += t.args[:y]
					position[2] += t.args[:z]
				end
			end		
	#		puts "  " * level + position.inspect
			x,y,z = get_position_rec(o.children,level+1)
			position[0] += x
			position[1] += y
			position[2] += z
		end
		return position
	end

	#	this is experimental, does only work on simple parts. example:
	# The bolt head is on the -z plane, this will move it to "zero"
	def position(obj)
		get_position_rec(obj.children)
	end

  # produces a hull() of 2 cylidners
  # accepts d,r,h for cylinder options
  # l long slot length
  def long_slot(args)
    hull(cylinder(d:args[:d],r:args[:r],h:args[:h]),cylinder(d:args[:d],r:args[:r],h:args[:h]).translate(x:args[:l]))    
  end
  
	def radians(a)
  	a/180.0 * Math::PI
	end
  
  def degrees(a)
	  a*180 /  Math::PI
  end

		
	def save!
		Dir.glob("lib/**/*.rb").map{|l| get_classes_from_file(l)}.flatten.map{|l| save_all(l)}
	end

	# Saves all files generated of a CrystalScad file
	# Saves outputs of 
	# - show
	# - output
	# - view* 
	def save_all(class_name,fn=$fn)

		res = class_name.send :new

		# skip defined classes
		skip = class_name.send :get_skip
		skip = [] if skip == nil
		skip << "show_hardware"
		added_views = class_name.send :get_views

		# regexp for output* view* show* 
		(res.methods.grep(Regexp.union(/^output/,/^view/,/^show/)) + added_views).each do |i|
			next if skip.include? i.to_s
			output = nil

			res.send :initialize # ensure default values are loaded at each interation
			output = res.send i 

			# if previous call resulted in a CrystalScadObject, don't call the show method again,
			# otherwise call it.
			unless 	output.kind_of? CrystalScadObject
				unless i.to_s.include? "output"	
					output = res.show					
				else
					output = res.output
				end
			end


			output.save("output/#{res.class}_#{i}.scad","$fn=#{fn};") unless output == nil
		end
	
	end

	def get_classes_from_file(filename)
		classes = []
		File.readlines(filename).find_all{|l| l.include?("class")}.each do |line|
			# strip all spaces, tabs
			line.strip!			
			# ignore comments (Warning: will not worth with ruby multi line comments)
			next if line[0..0] == "#"
			#	strip class definition
			line = line[6..-1]
			# strip until space appears - or if not, to the end
			classes << Object.const_get(line[0..line.index(" ").to_i-1])		
		end

		return classes
	end


end


