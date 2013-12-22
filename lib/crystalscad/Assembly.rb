module CrystalScad
	class Assembly
		attr_accessor :height

	  def initialize(args={})
	    @args = args if @args == nil
      @@bom.add(description) unless args[:no_bom] == true
	  end
	  
	  def description
	    "No description set for Class #{self.class.to_s}"
	  end
	  
	  def show
	    part(true)
	  end
	  
	  def output
	    part(false)
	  end

		def part(show=false)
			CrystalScadObject.new
		end
	  
	  def walk_tree
	    return output.walk_tree
	  end
	  
	  def +(args)
	    return self.output+args
	  end

	  def -(args)
	    return self.output-args
	  end

	  def *(args)
	    return self.output*args
	  end
	  
	  def translate(args)
	    return self.output.translate(args)
	  end 

	  def mirror(args)
	    return self.output.mirror(args)
	  end 

	  def rotate(args)
	    return self.output.rotate(args)
	  end 

	  def scad_output()
	    return self.output.scad_output
	  end 

	end

	class Printed < Assembly
	  def description
	    "Printed part #{self.class.to_s}"
	  end		
	end
end

