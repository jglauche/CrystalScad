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
	class Ruler < CrystalScad::Assembly
		def initialize(args={})
			@x = args[:x] || 50
			@y = args[:y] || 5
			@height = args[:height] || 1
			@mm_mark = args[:mm_mark] || 3
			@five_mm_mark = args[:five_mm_mark] || 4
			@ten_mm_mark = args[:ten_mm_mark] || 5
			@rotation = args[:rotation] || 0
		end

		def part(show)
			res = cube([@x,@y,@height]).color("Gainsboro")
			(@x+1).times do |i|
				res += cube([0.1,@mm_mark,@height+0.1]).translate(x:i).color("black")
				if i % 10 == 0
					res += cube([0.1,@ten_mm_mark,@height+0.1]).translate(x:i).color("black")							
				elsif i % 5 == 0
					res += cube([0.1,@five_mm_mark,@height+0.1]).translate(x:i).color("black")							
				end
			end
			if @rotation > 0
				res = res.rotate(z:@rotation)
			end
			res
		end
	
		
	end
end

