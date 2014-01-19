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

module CrystalScad::ScrewThreads
	class ScrewThread
		# I would name this Thread but that's already taken by something else

		attr_accessor :x,:y,:z,:size, :depth, :face

		def initialize(args={})
			@x = args[:x] || 0
			@y = args[:y] || 0
			@z = args[:z] || 0
			@depth = args[:depth] 		
			@size = args[:size]
			@face = args[:face] || :top
		end

		def rotation
			case @face.to_s
				when "top"
					return {}
				when "bottom"
					return {y:180}
				when "left"
					return {y:-90}
				when "right"
					return {y:90}
				when "front" # checkme
					return {x:90}
				when "back"
					return {x:-90}
			end				
		end

		def show
			cylinder(d:@size,h:@depth).rotate(rotation).translate(x:@x,y:@y,z:@z).color(r:130,g:130,b:130)
		end

		def orientation_swap_to(coords,rotation)
			if rotation[:x].to_i == -90
				return [coords[0],coords[2],-coords[1]]
			end			
			if rotation[:x].to_i == 90
				return [coords[0],-coords[2],coords[1]]
			end			
			if rotation[:y].to_i == -90
				return [coords[2],coords[1],coords[0]]
			end			
			if rotation[:y].to_i == 90
				return [-coords[2],coords[1],-coords[0]]
			end			
	
		return coords
		end

		def position_on(other_thread,rotation={})
		  if other_thread.kind_of? Bolt
		    # we assume that a bolt is always centered and center the object on
		    # the screwthread position
		    return {x:-@x,y:-@y,z:-@z}
		  else
		    # on a screwthread find out its position and orientation
  		  oc = other_thread.x, other_thread.y, other_thread.z
	  		oc = orientation_swap_to(oc,rotation)
        return {x:@x-oc[0],y:@y-oc[1],z:@z-oc[2]}	
	    end
		end

	end

	def create_bolts(face,obj1,obj2,args={})
		# make a obj1-=obj2 with bolts corresponding to the heigh tof obj1
		
		if face == nil or obj1 == nil or obj2 == nil
			raise "usage: create_bolts(face,obj1,obj2,args={})  - args can include (obj1.)height and bolt_height"
			return			
		end			

		# we need to know obj1 height (if not supplied by user)
		height ||= args[:height]			
		case face.to_s
			when "top"
				height ||= obj1.z rescue nil
			when "bottom"
				height ||= obj1.z rescue nil
			when "left"
				height ||= obj1.x rescue nil
			when "right"
				height ||= obj1.x rescue nil
			when "front"
				height ||= obj1.y rescue nil
			when "back"
				height ||= obj1.y rescue nil
		end		
		height ||= obj1.height rescue nil
		if height == nil
			raise "the object we're substracting from doesn't have a height defined; please define manually"
			return
		end			
		
		# lets check if the obj2 responds to the threads_[face] method
		
		meth = "threads_#{face}"
		
		unless obj2.respond_to?(meth)
			raise "The object you're trying to get bolts from doesn't supply any on the face '#{face}'. Please add a method #{meth} to this object"				
			return
		end
		holes = obj2.send(meth)		
		
		return if holes == nil

		# let the user either define bolt_heights as integer, array or none (will be guessed)
		if args[:bolt_height].kind_of? Array
			bolt_heights = args[:bolt_height]
			if bolt_heights.size != holes.size
				raise "object has #{holes.size} threads for bolts but you supplied #{bolt_heights.size}"
				return
			end
		else			
			bolt_heights = []
			holes.each do |hole|
				if args[:bolt_height]
					bolt_heights << args[:bolt_height] 
				else
					bolt_heights << (height+hole.depth).floor
				end
			end
		end

		ret = []
		holes.each_with_index do |hole,i|
			bolt = Bolt.new(hole.size,bolt_heights[i],washer:args[:washer])
		  case face
				when "top"
					bolt.transformations << Rotate.new(x:180)	
					bolt.transformations << Translate.new({x:hole.x,y:hole.y,z:hole.z+height})		
				when "bottom"
					bolt.transformations << Translate.new({x:hole.x,y:hole.y,z:hole.z})		
				when "left"
					bolt.transformations << Rotate.new(y:90)						
					bolt.transformations << Translate.new({x:hole.x,y:hole.y,z:hole.z+height})		
				when "right"
					bolt.transformations << Rotate.new(y:-90)						
					bolt.transformations << Translate.new({x:hole.x+height,y:hole.y,z:hole.z})		
				when "front"
					bolt.transformations << Rotate.new(x:-90)						
					bolt.transformations << Translate.new({x:hole.x,y:hole.y,z:hole.z})		
				when "back"
					bolt.transformations << Rotate.new(x:90)						
					bolt.transformations << Translate.new({x:hole.x,y:hole.y+height,z:hole.z})		
			end

			ret << bolt
		end
		
		ret
	end	

end
