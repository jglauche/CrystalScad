module CrystalScad
	class Assembly
	  def initialize(args={})
	    @args = args if @args == nil
      @@bom.add(description) unless args[:no_bom] == true
	  end
	  
	  def description
	    "No description set for Class #{self.class.to_s}"
	  end
	  
	  def show
	    ScadObject.new
	  end
	  
	  def output
	    show
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
end

