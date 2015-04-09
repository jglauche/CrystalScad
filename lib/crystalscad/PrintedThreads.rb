module CrystalScad::PrintedThreads
  # Ported from
  # http://dkprojects.net/openscad-threads/threads.scad
  #
  # original Author Dan Kirshner - dan_kirshner@yahoo.com

  class PrintedThread


    # internal - true = clearances for internal thread (e.g., a nut).
    #            false = clearances for external thread (e.g., a bolt).
    #            (Internal threads should be "cut out" from a solid using
    #            difference()).
    # number_of_starts - Number of thread starts (e.g., DNA, a "double helix," has
    #            n_starts=2).  See wikipedia Screw_thread.
    def initialize(args={})
      @args                      = args
      @args[:diameter]         ||= 8
      @args[:pitch]            ||= 1.25
      @args[:length]           ||= 10
      @args[:internal]         ||= false
      @args[:number_of_starts] ||= 1
    end

    def show
      output
    end

    def output
      number_of_turns    = (@args[:length].to_f/@args[:pitch].to_f).floor
      number_of_segments = segments(@args[:diameter])
      h                  = @args[:pitch] * Math::cos(radians(30))

      res  = nil
      ((-1*@args[:number_of_starts])..(number_of_turns+1)).each do |i|
        res += metric_thread_turn(@args[:diameter], @args[:pitch], @args[:internal], @args[:number_of_starts]).translate(z:i*@args[:pitch])
      end
      # cut to length
      res *= cube(x:@args[:diameter]*1.1, y:@args[:diameter]*1.1, z:@args[:length]).center.translate(z:@args[:length]/2.0)

      if @args[:internal]
        # Solid center, including Dmin truncation.
        res += cylinder(r:@args[:diameter]/2.0 - h*5.0/8.0, h:@args[:length], segments:number_of_segments)
      else
        # External thread includes additional relief.
        res += cylinder(r:@args[:diameter]/2.0 - h*5.3/8.0, h:@args[:length], segments:number_of_segments)
      end

      res
    end

    def segments(diameter)
      [50, (diameter*6).ceil].min
    end

    def metric_thread_turn(diameter, pitch, internal, number_of_starts)
      number_of_segments = segments(diameter)
      fraction_circle    = 1.0/number_of_segments
      res                = nil

      (0..number_of_segments-1).each do |i|
        res += thread_polyhedron(diameter/2.0, pitch, internal, number_of_starts).translate(z:i*number_of_starts*pitch*fraction_circle).rotate(z:i*360*fraction_circle)
      end
      res

    end

    # z (see diagram) as function of current radius.
    # (Only good for first half-pitch.)
    def z_fct(current_radius, radius, pitch)
      0.5*(current_radius - (radius - 0.875*pitch*Math::cos(radians(30))))/Math::cos(radians(30))
    end

=begin
        (angles x0 and x3 inner are actually 60 deg)

                              /\  (x2_inner, z2_inner) [2]
                             /  \
       (x3_inner, z3_inner) /    \
                      [3]   \     \
                            |\     \ (x2_outer, z2_outer) [6]
                            | \    /
                            |  \  /|
                 z          |   \/ / (x1_outer, z1_outer) [5]
                 |          |   | /
                 |   x      |   |/
                 |  /       |   / (x0_outer, z0_outer) [4]
                 | /        |  /     (behind: (x1_inner, z1_inner) [1]
                 |/         | /
        y________|          |/
       (r)                  / (x0_inner, z0_inner) [0]

=end
    def thread_polyhedron(radius, pitch, internal, n_starts)
      n_segments      = segments(radius*2)
      fraction_circle = 1.0/n_segments

      h       = pitch * Math::cos(radians(30))
      outer_r = radius + (internal ? h/20 : 0) # Adds internal relief.

      inner_r = radius - 0.875*h #  Does NOT do Dmin_truncation - do later with cylinder.

      # Make these just slightly bigger (keep in proportion) so polyhedra will overlap.
      x_incr_outer = outer_r * fraction_circle * 2 * Math::PI * 1.005
      x_incr_inner = inner_r * fraction_circle * 2 * Math::PI * 1.005
      z_incr       = n_starts * pitch * fraction_circle * 1.005

      x1_outer = outer_r * fraction_circle * 2 * Math::PI

      z0_outer = z_fct(outer_r, radius, pitch);
      z1_outer = z0_outer + z_incr;
      # Rule for triangle ordering: look at polyhedron from outside: points must
      # be in clockwise order.

      points = [
        [-x_incr_inner/2, -inner_r, 0],                        # [0]
        [x_incr_inner/2, -inner_r, z_incr],                    # [1]
        [x_incr_inner/2, -inner_r, pitch + z_incr],            # [2]
        [-x_incr_inner/2, -inner_r, pitch],                    # [3]

        [-x_incr_outer/2, -outer_r, z0_outer],                 # [4]
        [x_incr_outer/2, -outer_r, z0_outer + z_incr],         # [5]
        [x_incr_outer/2, -outer_r, pitch - z0_outer + z_incr], # [6]
        [-x_incr_outer/2, -outer_r, pitch - z0_outer]          # [7]
      ]

      triangles = [
        [0, 3, 4],  # This-side trapezoid, bottom
        [3, 7, 4],  # This-side trapezoid, top

        [1, 5, 2],  # Back-side trapezoid, bottom
        [2, 5, 6],  # Back-side trapezoid, top

        [0, 1, 2],  # Inner rectangle, bottom
        [0, 2, 3],  # Inner rectangle, top

        [4, 6, 5],  # Outer rectangle, bottom
        [4, 7, 6],  # Outer rectangle, top

        [7, 2, 6],  # Upper rectangle, bottom
        [7, 3, 2],  # Upper rectangle, top

        [0, 5, 1],  # Lower rectangle, bottom
        [0, 4, 5]   # Lower rectangle, top
      ]

      return polyhedron(points:points, triangles:triangles)
    end

  end
end




