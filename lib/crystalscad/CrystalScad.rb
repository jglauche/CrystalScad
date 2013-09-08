require "rubygems"
require "rubyscad"

module CrystalScad 


	class ScadObject
		attr_accessor :args		
  	attr_accessor :transformations
		def initialize(*args)
			@transformations = []
			@args = args.flatten
			if @args[0].kind_of? Hash
				@args = @args[0]			
			end		
		end		


		def walk_tree
			res = ""			
			@transformations.each{|trans|
				res += trans.walk_tree	 
			}
			res += self.to_rubyscad.to_s+ "\n"
			res
		end
		alias :output :walk_tree		
		
		def to_rubyscad
			""
		end
	
	end

	class TransformedObject < ScadObject
		attr_accessor :scad
		def initialize(string)
			@scad = string
		end		
	
		def walk_tree
			return @scad		
		end

	
	end

	class Primitive < ScadObject

		def rotate(args)
			@transformations << Rotate.new(args)	
			self
		end

		def translate(args)
			@transformations << Translate.new(args)		
			self			
		end
		
		def union(args)
			@transformations << Union.new(args)		
			self			
		end

  end

	class Transformation < ScadObject
	end

#	class Union < Transformation
#		def to_rubyscad
#			str= RubyScadBridge.new.union(){
#				@args			
#			}		
#			str
#		end	
#	end

	class Rotate < Transformation
		def to_rubyscad
			return RubyScadBridge.new.rotate(@args)		
		end	
	end

 	class Translate < Transformation
		def to_rubyscad
			return RubyScadBridge.new.translate(@args)		
		end	
	end

	class Cylinder < Primitive
		def to_rubyscad	
			return RubyScadBridge.new.cylinder(@args)		
		end	
	end

	class Cube < Primitive
		def to_rubyscad
			return RubyScadBridge.new.cube(@args)		
		end	
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

	def cylinder(args)
		Cylinder.new(args)		
	end
	
	def cube(args)
		if args.kind_of? Array
			args = {size:args}
		end	
		Cube.new(args)	
	end

	
	def csg_operation(operation, code1, code2)
		ret = "#{operation}(){"
		ret +=code1
		ret +=code2
		ret +="}"
		return TransformedObject.new(ret)
	end

	def +(args)	
		csg_operation("union",self.walk_tree,args.walk_tree)
	end

	def -(args)
		csg_operation("difference",self.walk_tree,args.walk_tree)		
	end
	
	def *(args)
		csg_operation("intersection",self.walk_tree,args.walk_tree)		
	end
	
	# Fixme: currently just accepting named colors
	def color(args)
		ret = "color(\"#{args}\"){"
		ret +=self.walk_tree
		ret +="}"
		return TransformedObject.new(ret)		
	end

end


