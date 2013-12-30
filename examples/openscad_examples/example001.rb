#!/usr/bin/ruby1.9.3
require "rubygems"
require "crystalscad"
include CrystalScad

size=50
hole=25
h = size * 2.5

res = sphere(d:size)
res -= cylinder(d:hole,h:h,center:true)
res -= cylinder(d:hole,h:h,center:true).rotate(x:90)
res -= cylinder(d:hole,h:h,center:true).rotate(y:90)
		
res.save("example001.scad")



=begin
module example001()
{
	function r_from_dia(d) = d / 2;

	module rotcy(rot, r, h) {
		rotate(90, rot)
			cylinder(r = r, h = h, center = true);
	}

	difference() {
		sphere(r = r_from_dia(size));
		rotcy([0, 0, 0], cy_r, cy_h);
		rotcy([1, 0, 0], cy_r, cy_h);
		rotcy([0, 1, 0], cy_r, cy_h);
	}

	size = 50;
	hole = 25;

	cy_r = r_from_dia(hole);
	cy_h = r_from_dia(size * 2.5);
}

example001();
=end

