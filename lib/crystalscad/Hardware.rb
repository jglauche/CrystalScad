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

	class Hardware < CrystalScad::Assembly
	end

	class Bolt	< Hardware

		def initialize(size,length,args={})
			@args = args
			@args[:type] ||= "912"
			@args[:material] ||= "steel 8.8"
			@args[:surface] ||= "zinc plated"
			# options for output only:	
			@args[:additional_length] ||= 0
			@args[:additional_diameter] ||= 0.3 
			@args[:head_margin] ||= 0.0

			if @args[:washer] == true
				@washer = Washer.new(size,{:material => @args[:material], :surface => @args[:surface]})
			end

			@size = size
			@length = length
			@transformations ||= []
		end

		def description
		  norm = ""
		  if ["912","933"].include? @args[:type]
		    norm = "DIN"
		  elsif ["7380"].include? @args[:type]
		    norm = "ISO"
		  end
		  
			"M#{@size}x#{@length} Bolt, #{norm} #{@args[:type]}, #{@args[:material]} #{@args[:surface]}"
		end

		def output
			add_to_bom
			case @args[:type].to_s
  			when "912"
    			res = bolt_912(@args[:additional_length], @args[:additional_diameter])
  			when "933"
    			res = bolt_933(@args[:additional_length], @args[:additional_diameter], @args[:head_margin])
	      when "7380"
    			res = bolt_7380(@args[:additional_length], @args[:additional_diameter])
		    else
		      raise "unkown type #{args[:type]} for Bolt!"
		  end
		  
		  return transform(res)
		end

		def show
			add_to_bom
			case @args[:type].to_s
  			when "912"
    			res = bolt_912(0,0)
  			when "933"
    			res = bolt_933(0,0)
	      when "7380"
    			res = bolt_7380(0,0)
		    else
		      raise "unkown type #{args[:type]} for Bolt!"
		  end
						
			if @washer
				res += @washer.show
				res = res.translate(z:-@washer.height)
			end
	
		
			transform(res)			
		end 

    # ISO 7380
  	def bolt_7380(additional_length=0, addtional_diameter=0)
	    chart_iso7380 = {
	                    3 => {head_dia:5.7,head_length:1.65},
	                    4 => {head_dia:7.6,head_length:2.2},
	                    5 => {head_dia:9.5,head_length:2.75},
	                    6 => {head_dia:10.5,head_length:3.3},
	                    8 => {head_dia:14,head_length:4.4},
	                    10=> {head_dia:17.5,head_length:5.5},
	                    12=> {head_dia:21,head_length:6.6},
	    
	    
	    }
	  	res = cylinder(d1:chart_iso7380[@size][:head_dia]/2.0,d2:chart_iso7380[@size][:head_dia],h:chart_iso7380[@size][:head_length]).translate(z:-chart_iso7380[@size][:head_length]).color("Gainsboro") 
      total_length = @length + additional_length
      res+= cylinder(d:@size+addtional_diameter, h:total_length).color("DarkGray")		
	  end

    # DIN 912
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
	  
	  def bolt_933(additional_length=0, addtional_diameter=0, head_margin=0)
	
			chart        = {2 => {head_side_to_side:4,head_length:1.4},
              			  2.5=> {head_side_to_side:5,head_length:1.7},
			                3 => {head_side_to_side:5.5,head_length:2},
											4 => {head_side_to_side:7,head_length:2.8},
											5 => {head_side_to_side:8,head_length:3.5},
											6	=> {head_side_to_side:10,head_length:4},
											8	=> {head_side_to_side:13,head_length:5.5},
	  									10=> {head_side_to_side:17,head_length:7},
	  									12=> {head_side_to_side:19,head_length:8},
	  									14=> {head_side_to_side:22,head_length:9},
	  									16=> {head_side_to_side:24,head_length:10},										
										 }
	    head_dia = chart[@size][:head_side_to_side].to_f + head_margin.to_f
    	res = cylinder(d:(head_dia/Math.sqrt(3))*2,fn:6,h:chart[@size][:head_length]).translate(z:-chart[@size][:head_length]).color("Gainsboro") 
      total_length = @length + additional_length
      res+= cylinder(d:@size+addtional_diameter, h:total_length).color("DarkGray")		
										
	  end
	  
	end
	
	class Washer	< Hardware
		def initialize(size,args={})
			@args=args			
			@size = size
			@args[:type] ||= "125"
			@args[:material] ||= "steel 8.8"
			@args[:surface] ||= "zinc plated"			
	
			@chart_din125 = { 3.2 => {outer_diameter:7, height:0.5},
												3.7 => {outer_diameter:8, height:0.5}, 											  
												4.3 => {outer_diameter:9, height:0.8},
												5.3 => {outer_diameter:10, height:1.0},
												6.4 => {outer_diameter:12, height:1.6},
												8.4 => {outer_diameter:16, height:1.6},
												10.5 => {outer_diameter:20, height:2.0},
												13.0 => {outer_diameter:24, height:2.5},

											}
			if @chart_din125[@size] == nil
				sizes = @chart_din125.map{|k,v| k}.sort.reverse.map{|s| s > @size ? size=s :nil}
				@size = size
			end			
			@height = @chart_din125[@size][:height]
			
			@transformations ||= []
		end

		def description
			"Washer #{@args[:size]}, Material #{@args[:material]} #{@args[:surface]}"
		end
		
		def show
			add_to_bom
			washer = cylinder(d:@chart_din125[@size][:outer_diameter].to_f,h:@chart_din125[@size][:height].to_f)
			washer-= cylinder(d:@size,h:@chart_din125[@size][:outer_diameter].to_f+0.2).translate(z:-0.1)
			washer.color("Gainsboro")
			transform(washer)
		end

	end

	class Nut < Hardware
		attr_accessor :height
		def initialize(size,args={})
			@size = size
			@type = args[:type] ||= "934"
			@material = args[:material] ||= "8.8"
			@surface = args[:surface] ||= "zinc plated"
			@support = args[:support] ||= false
			@support_layer_height = args[:support_layer_height] ||= 0.2
			@margin = args[:margin] ||= 0.3 # default output margin

			@slot = args[:slot] || nil
			@slot_margin = args[:slot_margin] || 0.5
			@slot_direction = args[:slot_direction] || "z"
			@cylinder_length = args[:cylinder_length] || 0	# for slot only

			@transformations ||= []
			@args = args
			prepare_data
			@height = args[:height] || @height 

			@direction = args[:direction] || @slot_direction 

			@bolt = nil

		end

		def description
			"M#{@size} Nut, DIN #{@type}, #{@material} #{@surface}"
		end

		def bolt(length=nil, args={})
			return @bolt if @bolt
			@bolt = Bolt.new(@size,length,args)
			case @direction
				when "z"
					bolt.transformations << Rotate.new(x:180)	
					bolt.transformations << Translate.new({z:length	})		
				when "-z"
					bolt.transformations << Translate.new({z:-length+@height})		
				when "-x"
					bolt.transformations << Rotate.new(x:180)	
					bolt.transformations << Translate.new({z:length})		
				when "x"
					bolt.transformations << Translate.new({z:-length+@height})		
				when "-y"
					bolt.transformations << Rotate.new(x:180)	
					bolt.transformations << Translate.new({z:length})		
				when "y"
					bolt.transformations << Translate.new({z:-length+@height})		
			end			
			@bolt.transformations += self.transformations.dup
			
			return @bolt
		end

		def prepare_data
			chart_934 = {2.5=> {side_to_side:5,height:2, support_diameter:2.8}, 
										3 => {side_to_side:5.5,height:2.4, support_diameter:3.5},
									  4 => {side_to_side:7,height:3.2, support_diameter:4.4},
										5 => {side_to_side:8,height:4, support_diameter:5.3},
										6 => {side_to_side:10,height:5, support_diameter:6.3},
										8 => {side_to_side:13,height:6.5, support_diameter:8.3},
									 10 => {side_to_side:17,height:8, support_diameter:10.3},
									 12 => {side_to_side:19,height:10, support_diameter:12.3},

									}
			# for securing nuts
			chart_985 = {
									 3 => {height:4},
									 4 => {height:5},										
									 5 => {height:5},										
									 6 => {height:6},										
									}

			@s = chart_934[@size][:side_to_side]
			@height = chart_934[@size][:height]
			@support_diameter = chart_934[@size][:support_diameter]
			if @type == "985"
				@height = chart_985[@size][:height]			
			end
	
		end

		def add_support(layer_height=@support_layer_height)
			res = cylinder(d:@support_diameter,h:@height-layer_height)
			# on very small nuts, add a support base of one layer height, so the support won't fall over
			if @size < 6 
				res += cylinder(d:@s-1,h:layer_height)
			end	
			res
		end

		def slot
			case @slot_direction	
				when "x" 
					pos = {x:@slot}
				when "y"
					pos = {y:@slot}
				when "z"
					pos = {z:@slot}
				when "-x" 
					pos = {x:-@slot}
				when "-y"
					pos = {y:-@slot}
				when "-z"
					pos = {z:-@slot}
				else
				raise "Invalid slot direction #{@slot_direction}"
			end
			res = hull(
				nut_934(false,@margin,@slot_margin),
				nut_934(false,@margin,@slot_margin).translate(pos)
			)				
			if @cylinder_length > 0
				res += cylinder(d:@size+@margin,h:@cylinder_length)			
			end	
			res	
		end

		def output	
			add_to_bom
			if @slot == nil
				return transform(nut_934(false,@margin))			
			else	
				return transform(slot)
			end
		end

		def show
			add_to_bom
			return transform(nut_934)
		end

		def nut_934(show=true,margin=0,height_margin=0)		
			@s += margin
			
			res = cylinder(d:(@s/Math.sqrt(3))*2,h:@height+height_margin,fn:6)
			res -= cylinder(d:@size,h:@height) if show == true
		 	if @support
				res -= add_support			
			end 	
			res.color("Gainsboro")
		end	

	end


	class TSlot < CrystalScad::Assembly
		# the code in this class is based on code by edef1c 	
		# Ported to CrystalScad by Jennifer Glauche 
		# License: GPLv3
		attr_accessor :args
		def initialize(args={})
			@args = args
		
			@args[:size] ||= 20
			@args[:length] ||= 100
			@args[:configuration] ||= 1
			@args[:gap] ||= 8.13
			@args[:thickness] ||= 2.55
			@args[:simple] ||= false
		  @machining = CrystalScadObject.new
		  @machining_string = ""
		end

		def output
      res = profile
 
      res - @machining 				
		end
		
    alias :show :output

		def description
			"T-Slot #{@args[:size]}x#{@args[:size]*@args[:configuration]}, length #{@args[:length]}mm #{@machining_string}"
		end
  
    def length(length)
      @args[:length] = length
      self
    end
  
    def thread(args={})
     position = args[:position] || "front"
     @machining_string += "with thread on #{position} "
     self
    end
    
    def threads
      self.thread().thread(position:"back")      
    end

    def holes(args={})
      args[:position] = "front"
      res = self.hole(args)
      args[:position] = "back"
      res.hole(args)
    end

    def hole(args={})
      diameter = args[:diameter] || 8
      position = args[:position] || "front"
      side = args[:side] || "x"
      
      if position.kind_of? String
        case position
          when "front"
            z = @args[:size]/2
            @machining_string += "with #{diameter}mm hole on front "
          when "back"
            z = @args[:length] - @args[:size]/2
            @machining_string += "with #{diameter}mm hole on back "
        end
      else
        z = position
        @machining_string += "with #{diameter}mm hole on #{z}mm "
      end
        
      @args[:configuration].times do |c|
        cyl = cylinder(d:diameter,h:@args[:size])
        if side == "x"
          @machining += cyl.rotate(x:-90).translate(x:@args[:size]/2+c*@args[:size],z:z) 
        else
          @machining += cyl.rotate(y:90).translate(y:@args[:size]/2+c*@args[:size],z:z) 
        end
      end
      
      self
    end

    def profile
			@@bom.add(description) unless args[:no_bom] == true
			return single_profile.color("Silver")	 if @args[:configuration] == 1 		
			return multi_profile.color("Silver")      
    end
  
		def single_profile
		  if @args[:simple] == true
		    return cube([@args[:size],@args[:size],@args[:length]])
		  else
			  start=@args[:thickness].to_f/Math.sqrt(2);
		   
			  gap = @args[:gap].to_f
			  thickness = @args[:thickness].to_f
			  size= @args[:size]
				square_size = gap+thickness
				if square_size > 0
				  profile = square(size:square_size,center:true)
				else
					profile = nil
				end
		    (0..3).each{|d|
		        profile+=polygon(points:[[0,0],[0,start],[size/2-thickness-start,size/2-thickness],[gap/2,size/2-thickness],[gap/2,size/2],[size/2,size/2],[size/2,gap/2],[size/2-thickness,gap/2],[size/2-thickness,size/2-thickness-start],[start,0]]).rotate(z:d*90)
		    }
			  profile-=circle(r:gap/2,center:true);
			  profile=profile.translate(x:size/2,y:size/2);
        return profile.linear_extrude(height:@args[:length],convexity:2)	
      end				
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
			puts "TSlotMachining is deprecated and will be removed in the 0.4.0 release."
		end

		alias tslot_output output

		def output(length=nil)
			tslot_output(length)-bolts()		
		end

		def show(length=nil)
			output(length)+bolts
		end

		def bolts
			bolt = CrystalScadObject.new
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
