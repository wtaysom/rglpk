require File.expand_path('helper', File.dirname(__FILE__))

class TestBriefExample < Minitest::Test
  include Examples
  
  def test_brief_example
    p = brief_example
    cols = p.cols
    rows = p.rows
    
    z = p.obj.get
    x1 = cols[0].get_prim
    x2 = cols[1].get_prim
    x3 = cols[2].get_prim
    
    result = "z = %g; x1 = %g; x2 = %g; x3 = %g" % [z, x1, x2, x3]
    assert_equal "z = 733.333; x1 = 33.3333; x2 = 66.6667; x3 = 0", result
    assert_equal Rglpk::GLP_NU, rows[0].get_stat
    assert_equal 100, rows[0].get_prim
    assert_equal 3.333333333333333, rows[0].get_dual
    File.delete("test.lp") rescue Errno::ENOENT
    p.write_lp("test.lp")
    assert File.exists?("test.lp")    
  end
end
