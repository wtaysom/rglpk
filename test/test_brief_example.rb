require File.expand_path('helper', File.dirname(__FILE__))

class TestExample < Test::Unit::TestCase
  def test_example
    # The same Brief Example as found in section 1.3 of 
    # glpk-4.44/doc/glpk.pdf.
    #
    # maximize
    #   z = 10 * x1 + 6 * x2 + 4 * x3
    #
    # subject to
    #   p:      x1 +     x2 +     x3 <= 100
    #   q: 10 * x1 + 4 * x2 + 5 * x3 <= 600
    #   r:  2 * x1 + 2 * x2 + 6 * x3 <= 300
    #
    # where all variables are non-negative
    #   x1 >= 0, x2 >= 0, x3 >= 0
    #    
    p = Rglpk::Problem.new
    p.name = "sample"
    p.obj.dir = Rglpk::GLP_MAX
    
    rows = p.add_rows(3)
    rows[0].name = "p"
    rows[0].set_bounds(Rglpk::GLP_UP, 0, 100)
    rows[1].name = "q"
    rows[1].set_bounds(Rglpk::GLP_UP, 0, 600)
    rows[2].name = "r"
    rows[2].set_bounds(Rglpk::GLP_UP, 0, 300)
    
    cols = p.add_cols(3)
    cols[0].name = "x1"
    cols[0].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    cols[1].name = "x2"
    cols[1].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    cols[2].name = "x3"
    cols[2].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    
    p.obj.coefs = [10, 6, 4]
    
    p.set_matrix([
       1, 1, 1,
      10, 4, 5,
       2, 2, 6
    ])
    
    p.simplex
    z = p.obj.get
    x1 = cols[0].get_prim
    x2 = cols[1].get_prim
    x3 = cols[2].get_prim
    
    result = "z = %g; x1 = %g; x2 = %g; x3 = %g" % [z, x1, x2, x3]
    assert_equal "z = 733.333; x1 = 33.3333; x2 = 66.6667; x3 = 0", result
  end
end