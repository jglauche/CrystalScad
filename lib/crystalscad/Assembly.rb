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
#    along with CrystalScad.  If not, see <http://www.gnu.org/licenses/>.

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

