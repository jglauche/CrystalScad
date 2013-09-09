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

module CrystalScad::LinearBearing

  class Lm_uu
          
    def initialize(args={inner_diameter:10})    
      @args = args
      @lm_uu = {8  => {diameter:15, length:24},
              10 => {diameter:19, length:29},
              12 => {diameter:21, length:30},
    
      }
      @shell_thickness = 1.1
      @@bom.add(description) unless args[:no_bom] == true
    end
   
    def description
			"LM#{@args[:inner_diameter]}UU Linear bearing"
		end
    
    def output
      show
    end
    
    def show
      diameter = @lm_uu[@args[:inner_diameter]][:diameter]
      length = @lm_uu[@args[:inner_diameter]][:length]
      
      shell=cylinder(d:diameter, h:length)
      shell-=cylinder(d:diameter-@shell_thickness*2, h:length+0.2).translate(z:-0.1)
      shell=shell.color("LightGrey")
      
      inner = cylinder(d:diameter-@shell_thickness*2, h:length)
      inner-= cylinder(d:@args[:inner_diameter], h:length+0.2).translate(z:-0.1)
      inner=inner.color("DimGray")
            
      shell+inner
      
    end    
    
    
  end    
    
end
