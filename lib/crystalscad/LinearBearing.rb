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

  class Lm_uu < CrystalScad::Assembly
          
    def initialize(args={inner_diameter:10})    
      @args = args
      @lm_uu = {
              3  => {diameter:7, length:10},
              4  => {diameter:8, length:12},
              5  => {diameter:10, length:15},
              6  => {diameter:12, length:19},
              8  => {diameter:15, length:24},
              10 => {diameter:19, length:29},
              12 => {diameter:21, length:30},
              13 => {diameter:23, length:32},
              16 => {diameter:28, length:37},
              20 => {diameter:32, length:42},
              25 => {diameter:40, length:59},
              30 => {diameter:45, length:64},
              35 => {diameter:52, length:70},
              40 => {diameter:60, length:80},
              50 => {diameter:80, length:100},
              60 => {diameter:90, length:110},
        
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
    
    def dimensions
      diameter = @lm_uu[@args[:inner_diameter]][:diameter]
      length = @lm_uu[@args[:inner_diameter]][:length]
      return diameter, length    
    end
    
    def show
      diameter, length = dimensions
      shell=cylinder(d:diameter, h:length)
      shell-=cylinder(d:diameter-@shell_thickness*2, h:length+0.2).translate(z:-0.1)
      shell=shell.color("LightGrey")
      
      inner = cylinder(d:diameter-@shell_thickness*2, h:length)
      inner-= cylinder(d:@args[:inner_diameter], h:length+0.2).translate(z:-0.1)
      inner=inner.color("DimGray")
            
      shell+inner
      
    end    
    
    
  end    
    
  class Lm_luu < Lm_uu
          
    def initialize(args={inner_diameter:10})    
      @args = args
      @lm_uu = {
              12 => {diameter:21, length:57},
        
      }
      @shell_thickness = 1.1
      @@bom.add(description) unless args[:no_bom] == true
    end
   
    def description
			"LM#{@args[:inner_diameter]}LUU (long) Linear bearing"
		end  
    
  end

end
