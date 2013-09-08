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

module CrystalScad::Hardware

	class Bolt	
		def initialize(size,length, type="912", material="8.8", surface="zinc plated")
			@size = size
			@length = length
			@type = type
			@material = material
			@surface = surface

			@@bom.add(description)
		end

		def description
			"M#{@size}x#{@length} Bolt, DIN #{@type}, #{@material} #{@surface}"
		end

		def output
			return bolt_912
		end

		# currently only din912	
		def bolt_912(addtional_size=0.2)
			
	
			chart_din912 = {3 => {head_dia:5.5,head_length:3,thread_length:18},
											4 => {head_dia:7.0,head_length:4,thread_length:20},
											5 => {head_dia:8.5,head_length:5,thread_length:22},
											8	=> {head_dia:13,head_length:8,thread_length:28}
										 }

			res = cylinder(d:chart_din912[@size][:head_dia],h:chart_din912[@size][:head_length]).translate(z:-chart_din912[@size][:head_length]).color("Gainsboro") 
			
			thread_length=chart_din912[@size][:thread_length]		
	    if @length.to_i <= thread_length
				res+= cylinder(d:@size+addtional_size, h:@length).color("DarkGray")
			else
				res+= cylinder(d:@size+addtional_size, h:@length-thread_length).color("Gainsboro")
				res+= cylinder(d:@size+addtional_size, h:thread_length).translate(z:@length-thread_length).color("DarkGray")		
			end				
			res
		end
		
		
		
	end

	class TSlot
		# the code in this class is based on code by Nathan Zadoks 	
		# taken from https://github.com/nathan7/scadlib
		# Ported to CrystalScad by Joachim Glauche
		# License: GPLv3
		attr_accessor :args
		def initialize(args={})
			@args = args
		
			@args[:size] ||= 20
			@args[:length] ||= 100
			@args[:configuration] ||= 1
			@args[:gap] ||= 8.13
			@args[:thickness] ||= 2.55
		end

		def output(length=nil)
			if length != nil
				@args[:length] = length
			end
			@@bom.add(bom_string,1) unless @@bom == nil

			return TransformedObject.new(single_profile.output)	 if @args[:configuration] == 1 		
			return TransformedObject.new(multi_profile.output)	 				
		end

		def bom_string
			"T-Slot #{@args[:size]}x#{@args[:size]*@args[:configuration]}, length #{@args[:length]}mm"
		end

		def single_profile
			start=@args[:thickness].to_f/Math.sqrt(2);
		 
			gap = @args[:gap]
			thickness = @args[:thickness]
			size= @args[:size]
			profile = square(size:gap+thickness,center:true);
		  (0..3).each{|d|
		      profile+=polygon(points:[[0,0],[0,start],[size/2-thickness-start,size/2-thickness],[gap/2,size/2-thickness],[gap/2,size/2],[size/2,size/2],[size/2,gap/2],[size/2-thickness,gap/2],[size/2-thickness,size/2-thickness-start],[start,0]]).rotate(z:d*90)
		  }
			profile-=circle(r:gap/2,center:true);
			profile=profile.translate(x:size/2,y:size/2);
		
			return profile.linear_extrude(height:@args[:length])		
		end

		def multi_profile
			res = single_profile
			(@args[:configuration]-1).times do |c| c=c+1 
				res+= single_profile.translate(y:c*@args[:size])
			end
			return res
		end

	end

	class TSlotMachining < TSlot

		def initialize(args={})			
			super(args)
			@args[:holes] ||= "front,back" # nil, front, back
			@args[:bolt_size] ||= 8
			@args[:bolt_length] ||= 25
		end

		alias tslot_output output

		def output(length)
			tslot_output(length)-bolts		
		end

		def show
			output+bolts
		end

		def bolts
			bolt = ScadObject.new
			return bolt if @args[:holes] == nil
		
			if @args[:holes].include?("front")
				@args[:configuration].times do |c|			
					bolt+=Bolt.new(@args[:bolt_size],@args[:bolt_length]).output.rotate(y:90).translate(y:@args[:size]/2+c*@args[:size],z:@args[:size]/2)
				end
			end

			if @args[:holes].include?("back")
				@args[:configuration].times do |c|			
					bolt+=Bolt.new(@args[:bolt_size],@args[:bolt_length]).output.rotate(y:90).translate(y:@args[:size]/2+c*@args[:size],z:@args[:length]-@args[:size]/2)
				end
			end

			bolt
		end

		def bom_string
			str = "T-Slot #{@args[:size]}x#{@args[:size]*@args[:configuration]}, length #{@args[:length]}mm"
			if @args[:holes] != nil
				str << " with holes for M#{@args[:bolt_size]} on "+ @args[:holes].split(",").join(' and ')
			end
		end

	end	

end
