module CrystalScad::Extras


	# This currently can solve triangels knowing 1 side and 2 angels 
	class Triangle
		attr_accessor :alpha, :beta, :gamma, :a, :b, :c
		def initialize(args={})
			@alpha = args[:alpha]
			@beta = args[:beta]
			@gamma = args[:gamma]
			@a = args[:a]
			@b = args[:b]
			@c = args[:c]	
			solve
		end

		def solve
			# see if we have two angles, so we know the third one
			if @alpha == nil and @beta != nil and @gamma != nil
				@alpha = 180 - @beta - @gamma
			elsif @alpha != nil and @beta == nil and @gamma != nil
				@beta = 180 - @alpha - @gamma 
			elsif @alpha != nil and @beta != nil and @gamma == nil			
				@gamma = 180 - @alpha - @beta
			end			

			if @alpha != nil and @beta != nil and @gamma != nil
				
				if @a == nil
					if @b != nil
						@a = (@b / Math::sin(radians(@beta))) * Math::sin(radians(@alpha))	
					elsif @c != nil
						@a = (@c / Math::sin(radians(@gamma))) * Math::sin(radians(@alpha))	
					end
				end

				if @b == nil
					if @a != nil
						@b = (@a / Math::sin(radians(@alpha))) * Math::sin(radians(@beta))	
					elsif @c != nil
						@b = (@c / Math::sin(radians(@gamma))) * Math::sin(radians(@beta))	
					end
				end

				if @c == nil
					if @a != nil
						@c = (@a / Math::sin(radians(@alpha))) * Math::sin(radians(@gamma))	
					elsif @b != nil
						@c = (@b / Math::sin(radians(@beta))) * Math::sin(radians(@gamma))	
					end
				end					
	
			end			


		end


	end


	def knurl(y)
		x = 1.5
		height = 1.5
		res = cube(([x,y,height]))
		res -= cylinder(d:0.9,h:height*1.42,fn:16).rotate(y:45).translate(x:0)
		res -= cylinder(d:0.9,h:height*1.42,fn:16).rotate(y:-45).translate(x:1.5)

		res
	end
	

	def knurled_cube(size)
		x = size[0]
		y = size[1]
		z = size[2]
		res = nil
			
		(x / 1.5).ceil.times do |i|
			(z / 1.5).ceil.times do |f|
				res += knurl(y).translate(x:i*1.5,z:f*1.5) 			
			end
		end

		res *= cube([x,y,z])
 

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
