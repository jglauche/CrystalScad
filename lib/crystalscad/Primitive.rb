module CrystalScad
	class Primitive < CrystalScadObject
		attr_accessor :children		

		def rotate(args)
		  # always make sure we have a z parameter; otherwise RubyScad will produce a 2-dimensional output
		  # which can result in openscad weirdness
		  if args[:z] == nil
		    args[:z] = 0
		  end
			@transformations << Rotate.new(args)	
			self
		end

		def rotate_around(point,args)
			x,y,z= point.x, point.y, point.z
			self.translate(x:-x,y:-y,z:-z).rotate(args).translate(x:x,y:y,z:z)
		end

		def translate(args)
			@transformations << Translate.new(args)		
			self			
		end
		
		def union(args)
			@transformations << Union.new(args)		
			self			
		end

		def mirror(args)
			@transformations << Mirror.new(args)		
			self			
		end

		def scale(args)
			if args.kind_of? Numeric or args.kind_of? Array
					args = {v:args}
			end
			@transformations << Scale.new(args)		
			self			
		end


  end
end
