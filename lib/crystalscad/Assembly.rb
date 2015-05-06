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
	class Assembly < CrystalScad::Primitive
		attr_accessor :height,:x,:y,:z,:skip,:color,:hardware,:transformations

		def transform(obj)	
			return obj if @transformations == nil
			@transformations.each do |t|
				obj.transformations << t
			end
			
			return obj
		end

	  def initialize(args={})
	    @args = args if @args == nil
			
			@x = args[:x]
			@y = args[:y]
			@z = args[:z]

      add_to_bom
	  end

		def add_to_bom
			if !@bom_added				
				@@bom.add(description) unless @args[:no_bom] == true
				@bom_added = true
			end
		end		
	  
	  def description
	    "No description set for Class #{self.class.to_s}"
	  end
	  
	  def show
	    transform(part(true))
	  end
	  
	  def output
	    transform(part(false))
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

	  def scad_output()
	    return self.output.scad_output
	  end 
		
		def threads
			a = []
			[:threads_top,:threads_bottom,:threads_left,:threads_right,:threads_front,:threads_back].each do |m|
				if self.respond_to? m
					ret = self.send m
					unless ret == nil
						if ret.kind_of? Array
							a+= ret
						else
							a << ret
						end
					end				
				end
			end

			return a
		end

		# Makes the save_all method in CrystalScad skip the specified method(s)
		def self.skip(args)
		@skip = [] if @skip == nil
			if args.kind_of? Array
				args.each do |arg|
					skip(arg)
				end
				return
			end			
				
			@skip << args.to_s
			return
		end

		def self.get_skip
			@skip		
		end


		def self.view(args)
			@added_views = [] if @added_views == nil
			if args.kind_of? Array
				args.each do |arg|
					view(arg)
				end
				return
			end			
				
			@added_views << args.to_s
			return
		end

		def self.get_views
			@added_views || []
		end


		def color(args)
			@color = args
			return self
		end

		def colorize(res)
			return res if @color == nil
			return res.color(@color)
		end

		def show_hardware
			return nil if @hardware == nil or @hardware == []
			res = nil			
			@hardware.each do |part|
				res += part.show
			end
			transform(res)
		end

	end

	class Printed < Assembly
	  def description
	    "Printed part #{self.class.to_s}"
	  end		
	end
	
	class LasercutSheet < Assembly
	
	  def description
	    "Laser cut sheet #{self.class.to_s}"
	  end				
		
		def part(show)
			square([@x,@y])
		end
	end	

end

