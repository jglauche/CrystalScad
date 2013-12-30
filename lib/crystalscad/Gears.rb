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


module CrystalScad::Gears

  class Gear < CrystalScad::Assembly
    # this library is to be used to easily work with gears and their distances to each other

    attr_reader :module, :teeth, :height, :hub_dia, :hub_height
    
    def initialize(args={})
      @module = args[:module] || 1.0
      @teeth = args[:teeth] || 1.0
      @bore = args[:bore] || 0.0
      @height = args[:height] || 3.0
			@hub_dia = args[:hub_dia] || 0.0
			@hub_height = args[:hub_height] || 0.0
			@output_margin_dia = args[:output_margin_dia] || 2
			@output_margin_height = args[:output_margin_height] || 1
    end 
    
    def show
      res = cylinder(d:@module*@teeth,h:@height)

			if @hub_height.to_f > 0 && @hub_dia.to_f > 0
				res += cylinder(d:@hub_dia,h:@hub_height).translate(z:@height)
			end      

			if @bore.to_f > 0.0
        res -= cylinder(d:@bore,h:@height+@hub_height+0.2).translate(z:-0.1)
      end
      res.color("darkgray")
    end

		def output
			res = cylinder(d:@module*@teeth+@output_margin_dia,h:@height+@output_margin_height)
			if @hub_height.to_f > 0 && @hub_dia.to_f > 0
				res += cylinder(d:@hub_dia+@output_margin_dia,h:@hub_height+@output_margin_height).translate(z:@height)
			end   

			res   
		end
    
    def distance_to(other_gear)
      if @module != other_gear.module
        raise "You cannot use two gears with different gear modules."
        return
      end
      return (@module * (@teeth + other_gear.teeth))/2.0
    end
    
  end 

  # Acts the same as Gear, but does produce printable output
  class PrintedGear < Gear

    def initialize(args={})
      super
      @pressure_angle = args[:pressure_angle] || 20
      @clearance = args[:clearance] || 0.0
      @backlash = args[:backlash] || 0.0
      @twist = args[:twist] || 0.0
      @teeth_to_hide = args[:teeth_to_hide] || 0.0
    end
  
    def show
      output
    end
    
    # ported from publicDomainGearV1.1.scad
    def output
      p = @module * @teeth / 2.0
      c  = p + @module - @clearance       # radius of pitch circle
	    b  = p*Math::cos(radians(@pressure_angle))         # radius of base circle
    	r  = p-(c-p)-@clearance             # radius of root circle
    	t  = (@module*Math::PI)/2.0-@backlash/2.0     # tooth thickness at pitch circle
    	k  = -iang(b, p) - t/2.0/p/Math::PI*180    # angle to where involute meets base circle on each side of tooth
	    
	    points=[
								[0, -@hub_dia/10.0],
								polar(r, -181/@teeth.to_f),
								polar(r, r<b ? k : -180/@teeth.to_f),
								q7(0/5,r,b,c,k, 1),q7(1/5,r,b,c,k, 1),q7(2/5,r,b,c,k, 1),q7(3/5,r,b,c,k, 1),q7(4/5,r,b,c,k, 1),q7(5/5,r,b,c,k, 1),
								q7(5/5,r,b,c,k,-1),q7(4/5,r,b,c,k,-1),q7(3/5,r,b,c,k,-1),q7(2/5,r,b,c,k,-1),q7(1/5,r,b,c,k,-1),q7(0/5,r,b,c,k,-1),
								polar(r, r<b ? -k : 180/@teeth.to_f),
								polar(r, 181/@teeth.to_f)
							]
			paths=[(0..16).to_a]
      
      res = CrystalScadObject.new
      (0..@teeth-@teeth_to_hide-1).each do |i|
        res+= polygon(points:points,paths:paths).linear_extrude(h:@height,convexity:10,center:false,twist:@twist).rotate(z:i*360/@teeth.to_f)
      end

     res-= cylinder(h:@height+0.2,d:@bore).translate(z:-0.1)
      
    end

    def radians(a)
      a/180.0 * Math::PI
    end
  
    def degrees(a)
      a*180 /  Math::PI
    end
  
    def polar(r,theta)
      [r*Math::sin(radians(theta)), r*Math::cos(radians(theta))]  #convert polar to cartesian coordinates
    end
    
    def iang(r1,r2) 
      Math::sqrt((r2/r1)*(r2/r1) - 1)/Math::PI*180 - degrees(Math::acos(r1/r2)) #//unwind a string this many degrees to go from radius r1 to radius r2
    end
    
    def q7(f,r,b,r2,t,s)
      q6(b,s,t,(1-f)*[b,r].max+f*r2) #radius a fraction f up the curved side of the tooth 
    end
    
    def q6(b,s,t,d)
      polar(d,s*(iang(b,d)+t)) # point at radius d on the involute curve
    end
  
  end
  
end

