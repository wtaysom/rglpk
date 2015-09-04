require File.expand_path('helper', File.dirname(__FILE__))

module TestProblemKind
  def setup
    @p = Rglpk::Problem.new
    @p.obj.dir = Rglpk::GLP_MAX
    
    cols = @p.add_cols(3)
    cols[0].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    cols[1].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    cols[2].set_bounds(Rglpk::GLP_LO, 0.0, 0.0)
    
    rows = @p.add_rows(3)
    
    rows[0].set_bounds(Rglpk::GLP_UP, 0, 4)
    rows[1].set_bounds(Rglpk::GLP_UP, 0, 5)
    rows[2].set_bounds(Rglpk::GLP_UP, 0, 6)
    
    @p.obj.coefs = [1, 1, 1]
    
    @p.set_matrix([
      1, 1, 0,
      0, 1, 1,
      1, 0, 1
    ])
    
    @p.cols.each{|c| c.kind = column_kind}
  end
  
  def verify_results(*results)
    if column_kind == Rglpk::GLP_CV
      solution_method = :simplex
      status_method = :status
      value_method = :get_prim
    else
      solution_method = :mip
      status_method = :mip_status
      value_method = :mip_val
    end
    
    @p.send(solution_method, {:presolve => Rglpk::GLP_ON})
    
    assert_equal Rglpk::GLP_OPT, @p.send(status_method)
    
    @p.cols.each_with_index do |col, index|
      assert_equal results[index], col.send(value_method)
    end

    @p.rows.each do |row|
      refute_nil row.send(value_method)
    end
  end
end

class BinaryVariables < Minitest::Test
  include TestProblemKind
  
  def column_kind
    Rglpk::GLP_BV
  end
  
  def test_results
    verify_results(1, 1, 1)
  end
end

class IntegerVariables < Minitest::Test
  include TestProblemKind
  
  def column_kind
    Rglpk::GLP_IV
  end
  
  def test_results
    verify_results(3, 1, 3)
  end
end

class ContinuousVariables < Minitest::Test
  include TestProblemKind
  
  def column_kind
    Rglpk::GLP_CV
  end
  
  def test_results
    verify_results(2.5, 1.5, 3.5)
  end
end
