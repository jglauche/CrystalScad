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
		def bolt_912
			chart_din912 = {3 => {head_dia:5.5,head_length:3,thread_length:18},
											4 => {head_dia:7.0,head_length:4,thread_length:20},
											5 => {head_dia:8.5,head_length:5,thread_length:22}
										 }

			res = cylinder(d:chart_din912[@size][:head_dia],h:chart_din912[@size][:head_length]).translate(z:-chart_din912[@size][:head_length]) 
			res+= cylinder(d:@size, h:@length)
			res
		end
		
		
		
	end



end
