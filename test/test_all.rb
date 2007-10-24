require 'test/unit'
require 'glpk'

class TestGLPK < Test::Unit::TestCase

  def test_create
    assert_instance_of GLPK::Problem, GLPK::Problem.new
  end

  def test_name
    p = GLPK::Problem.new
    p.name = 'test'
    assert_equal 'test', p.name
  end

  def test_obj_fun_name
    p = GLPK::Problem.new
    p.obj.name = 'test'
    assert_equal 'test', p.obj.name
  end

  def test_obj_fun_dir
    p = GLPK::Problem.new
    p.obj.dir = GLPK::GLP_MIN
    assert_equal GLPK::GLP_MIN, p.obj.dir
    p.obj.dir = GLPK::GLP_MAX
    assert_equal GLPK::GLP_MAX, p.obj.dir
    assert_raise(ArgumentError){p.obj.dir = 3}    
  end

  def test_add_rows
    p = GLPK::Problem.new
    p.add_rows(2)
    assert_equal 2, p.rows.length
    p.add_rows(2)
    assert_equal 4, p.rows.length
  end

  def test_add_cols
    p = GLPK::Problem.new
    p.add_cols(2)
    assert_equal 2, p.cols.length
    p.add_cols(2)
    assert_equal 4, p.cols.length
  end

  def test_set_row_name
    p = GLPK::Problem.new
    p.add_rows(10)
    p.rows[1].name = 'test'
    assert_equal 'test', p.rows[1].name
    assert_nil p.rows[2].name
  end

  def test_set_col_name
    p = GLPK::Problem.new
    p.add_cols(2)
    p.cols[1].name = 'test'
    assert_equal 'test', p.cols[1].name
    assert_nil p.cols[2].name
  end

  def test_set_row_bounds
    p = GLPK::Problem.new
    p.add_rows(2)
    p.rows[1].set_bounds(GLPK::GLP_FR,nil,nil)
    assert_equal [GLPK::GLP_FR, nil, nil], p.rows[1].bounds
  end

  def test_set_col_bounds
    p = GLPK::Problem.new
    p.add_cols(2)
    p.cols[1].set_bounds(GLPK::GLP_FR,nil,nil)
    assert_equal [GLPK::GLP_FR, nil, nil], p.cols[1].bounds
  end

  def test_obj_coef
    p = GLPK::Problem.new
    p.add_cols(2)
    p.obj.set_coef(1,2)
    assert_equal [2,0], p.obj.coefs
    p.obj.coefs = [1,2]
    assert_equal [1,2], p.obj.coefs    
  end

  def test_set_row
    p = GLPK::Problem.new
    p.add_rows(2)
    assert_raise(RuntimeError){p.rows[1].set([1,2])}    
    p.add_cols(2)
    p.rows[1].set([1,2])
    assert_equal [1,2], p.rows[1].get
  end

  def test_set_col
    p = GLPK::Problem.new
    p.add_cols(2)
    assert_raise(RuntimeError){p.cols[1].set([1,2])}    
    p.add_rows(2)
    p.cols[1].set([1,2])
    assert_equal [1,2], p.cols[1].get
  end

  def test_set_mat
    p = GLPK::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1,2,3,4])
    assert_equal [1,2], p.rows[1].get
    assert_equal [3,4], p.rows[2].get
    assert_equal [1,3], p.cols[1].get
    assert_equal [2,4], p.cols[2].get
  end

  def test_del_row
    p = GLPK::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1,2,3,4])
    assert_equal [1,2], p.rows[1].get
    p.del_rows([1])
    assert_equal [3,4], p.rows[1].get
    assert_equal [3],   p.cols[1].get
  end

  def test_del_col
    p = GLPK::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1,2,3,4])
    assert_equal [1,3], p.cols[1].get
    p.del_cols([1])
    assert_equal [2,4], p.cols[1].get
    assert_equal [2],   p.rows[1].get
  end

  def test_nz
    p = GLPK::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1,2,3,4])
    assert_equal 4, p.nz
  end

  def test_row_get_by_name
    p = GLPK::Problem.new
    assert_raises(RuntimeError){ p.rows['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1,2,3,4])
    assert_raises(ArgumentError){ p.rows['test'] }
    p.rows[1].name = 'test'
    assert_equal [1,2], p.rows['test'].get
  end

  def test_col_get_by_name
    p = GLPK::Problem.new
    assert_raises(RuntimeError){ p.cols['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1,2,3,4])
    assert_raises(ArgumentError){ p.cols['test'] }
    p.cols[1].name = 'test'
    assert_equal [1,3], p.cols['test'].get
  end

  def test_solve
    p = GLPK::Problem.new
    assert_raises(RuntimeError){ p.cols['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1,2,3,4])
    p.simplex({:msg_lev => 1})
  end

  class D < GLPK::Problem
    attr_accessor :species
    def initialize
      @species = []
      super
    end
  end  

  def test_derived
    D.new.add_rows(10)
  end

end
