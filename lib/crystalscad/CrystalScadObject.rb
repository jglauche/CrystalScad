module CrystalScad
	class CrystalScadObject
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
			
			@transformations.reverse.each{|trans|
				res += trans.walk_tree 
			}
			res += self.to_rubyscad.to_s+ "\n"
			res
		end
		alias :scad_output :walk_tree		
		
		def walk_tree_classes
			res = []
			@transformations.reverse.each{|trans|
				res += trans.walk_tree_classes 
			}
			res << self.class
			res
		end

		def to_rubyscad
			""
		end
		
		def save(filename,start_text=nil)
      file = File.open(filename,"w")
      file.puts start_text unless start_text == nil
      file.puts scad_output
      file.close		
		end
	end
end
