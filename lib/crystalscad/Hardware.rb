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

	class Bolt	< CrystalScad::Assembly
		def initialize(size,length,args={})
			@args = args
			@args[:type] ||= "912"
			@args[:material] ||= "8.8"
			@args[:surface] ||= "zinc plated"
			# options for output only:	
			@args[:additional_length] ||= 0
			@args[:additional_diameter] ||= 0.2 

			@size = size
			@length = length


			@@bom.add(description)
		end

		def description
			"M#{@size}x#{@length} Bolt, DIN #{@args[:type]}, #{@args[:material]} #{@args[:surface]}"
		end

		def output
			return bolt_912(@args[:additional_length],@args[:additional_diameter])
		end

		def show
			return bolt_912(0,0)
		end

		# currently only din912	
		def bolt_912(additional_length=0, addtional_diameter=0)
			
	
			chart_din912 = {2 => {head_dia:3.8,head_length:2,thread_length:16},
              			  2.5=> {head_dia:4.5,head_length:2.5,thread_length:17},
			                3 => {head_dia:5.5,head_length:3,thread_length:18},
											4 => {head_dia:7.0,head_length:4,thread_length:20},
											5 => {head_dia:8.5,head_length:5,thread_length:22},
											6	=> {head_dia:10,head_length:6,thread_length:24},
											8	=> {head_dia:13,head_length:8,thread_length:28},
	  									10=> {head_dia:16,head_length:10,thread_length:32},
	  									12=> {head_dia:18,head_length:12,thread_length:36},
	  									14=> {head_dia:21,head_length:14,thread_length:40},
	  									16=> {head_dia:24,head_length:16,thread_length:44},
	  									18=> {head_dia:27,head_length:18,thread_length:48},
	  									20=> {head_dia:30,head_length:20,thread_length:52},
	  									22=> {head_dia:33,head_length:22,thread_length:56},
	  									24=> {head_dia:36,head_length:24,thread_length:60},
	  									30=> {head_dia:45,head_length:30,thread_length:72},
	  									36=> {head_dia:54,head_length:36,thread_length:84},
										
										
										 }

			res = cylinder(d:chart_din912[@size][:head_dia],h:chart_din912[@size][:head_length]).translate(z:-chart_din912[@size][:head_length]).color("Gainsboro") 
			
			total_length = @length + additional_length
			thread_length=chart_din912[@size][:thread_length]		
	    if total_length.to_f <= thread_length
				res+= cylinder(d:@size+addtional_diameter, h:total_length).color("DarkGray")
			else
				res+= cylinder(d:@size+addtional_diameter, h:total_length-thread_length).color("Gainsboro")
				res+= cylinder(d:@size+addtional_diameter, h:thread_length).translate(z:total_length-thread_length).color("DarkGray")		
			end				
			res
		end
				
	end
	
	class Washer	< CrystalScad::Assembly
		def initialize(size,args={})
			@args=args			
			@size = size
			@args[:type] ||= "125"
			@args[:material] ||= "steel"
			@args[:surface] ||= "zinc plated"			

			@chart_din125 = { 3.2 => {outer_diameter:7, height:0.5},
 											  4.3 => {outer_diameter:9, height:0.8},
												5.3 => {outer_diameter:10, height:1.0},

											}
			@height = @chart_din125[@size][:height]
			super(args)		
		end

		def description
			"Washer #{@args[:size]}, Material #{@args[:material]} #{@args[:surface]}"
		end
		
		def show
			washer = cylinder(d:@chart_din125[@size][:outer_diameter].to_f,h:@chart_din125[@size][:height].to_f)
			washer-= cylinder(d:@size,h:@chart_din125[@size][:outer_diameter].to_f+0.2).translate(z:-0.1)
			washer.color("Gainsboro")
		end

	end

	class Nut < CrystalScad::Assembly
		attr_accessor :height
		def initialize(size,args={})
			@size = size
			@type = args[:type] ||= "934"
			@material = args[:material] ||= "8.8"
			@surface = args[:surface] ||= "zinc plated"

			@@bom.add(description) unless args[:no_bom] == true
			prepare_data
		end

		def description
			"M#{@size} Nut, DIN #{@type}, #{@material} #{@surface}"
		end

		def prepare_data
			chart_934 = {2.5=> {side_to_side:5,height:2}, 
										3 => {side_to_side:5.5,height:2.4},
									  4 => {side_to_side:7,height:3.2},
										5 => {side_to_side:8,height:4},
										6 => {side_to_side:10,height:5},
										8 => {side_to_side:13,height:6.5},
									 10 => {side_to_side:17,height:8},
									 12 => {side_to_side:19,height:10},

									}
			@s = chart_934[@size][:side_to_side]
			@height = chart_934[@size][:height]
		end

		def output(margin=0.2)
			return nut_934(margin)
		end

		def show
			return nut_934
		end

		def nut_934(margin=0)		
			@s += margin
			nut=cylinder(d:(@s/Math.sqrt(3))*2,h:@height,fn:6)
			nut-=cylinder(d:@size,h:@height)
			nut.color("Gainsboro")
		end	

	end


	class TSlot < CrystalScad::Assembly
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
			@@bom.add(description) unless args[:no_bom] == true

			return TransformedObject.new(single_profile.output)	 if @args[:configuration] == 1 		
			return TransformedObject.new(multi_profile.output)	 				
		end
		
    alias :show :output

		def description
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
		
			return profile.linear_extrude(height:@args[:length],convexity:2)		
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

		def output(length=nil)
			tslot_output(length)-bolts		
		end

		def show(length=nil)
			output(length)+bolts
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

		def description
			str = "T-Slot #{@args[:size]}x#{@args[:size]*@args[:configuration]}, length #{@args[:length]}mm"
			if @args[:holes] != nil
				str << " with holes for M#{@args[:bolt_size]} on "+ @args[:holes].split(",").join(' and ')
			end
		end

	end	

end
