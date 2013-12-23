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
    # TODO: maybe at some point port the publicDomainGear.scad into it?

    attr_reader :module, :teeth
    
    def initialize(args={})
      @module = args[:module] || 1.0
      @teeth = args[:teeth] || 1.0
      @bore = args[:bore] || 0.0
      @height = args[:height] || 3.0
    end 
    
    def show
      output
    end
    
    # very simple output
    def output
      res = cylinder(d:@module*@teeth,h:@height)
      if @bore.to_f > 0.0
        res -= cylinder(d:@bore,h:@height+0.2).translate(z:-0.1)
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
  
end

