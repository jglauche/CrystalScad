class Example < CrystalScad::Assembly
  
  def initialize(args={})
    super
  end
  
  def show
    part(show=true)
  end
  
  def output
    part(show=false)
  end
  
  def part(show)  
    bolt = Bolt.new(3,20)
    
    res = cube([20,20,20]).center_xy
    res -= bolt.output.translate(x:2,y:2)
    res += bolt.show.translate(x:2,y:2) if show
    
    res
  end
  
end
