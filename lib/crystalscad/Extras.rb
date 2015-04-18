module CrystalScad::Extras

	def knurled_cube(size)
		x = size[0]
		y = size[1]
		height = size[2]
		res = cube(size)

		offset = [x,height].max

		(offset*2.2).ceil.times do |i|
			res -= cylinder(d:0.9,h:height*2).rotate(y:45).translate(x:i*1.5-offset)
			res -= cylinder(d:0.9,h:height*2).rotate(y:-45).translate(x:i*1.5-offset)
		end
		res
	end

	def knurled_cylinder(args={})
		res = cylinder(args)	
		height = args[:h]
		r = args[:d] / 2.0

		24.times do |i|
			(height/2).ceil.times do |f| 
				res -= cylinder(d:0.9,h:height*2).rotate(y:45).translate(y:-r,z:f*2)
				res -= cylinder(d:0.9,h:height*2).rotate(y:-45).translate(y:-r,z:f*2)
			end
			res.rotate(z:15)
		end
		res
	end


end
