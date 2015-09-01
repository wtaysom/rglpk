require File.expand_path('helper', File.dirname(__FILE__))

class TestRglpk < Minitest::Test

  def test_create
    assert_instance_of Rglpk::Problem, Rglpk::Problem.new
  end

  def test_name
    p = Rglpk::Problem.new
    p.name = 'test'
    assert_equal 'test', p.name
  end

  def test_obj_fun_name
    p = Rglpk::Problem.new
    p.obj.name = 'test'
    assert_equal 'test', p.obj.name
  end

  def test_obj_fun_dir
    p = Rglpk::Problem.new
    p.obj.dir = Rglpk::GLP_MIN
    assert_equal Rglpk::GLP_MIN, p.obj.dir
    p.obj.dir = Rglpk::GLP_MAX
    assert_equal Rglpk::GLP_MAX, p.obj.dir
    assert_raises(ArgumentError){p.obj.dir = 3}
  end

  def test_add_row
    p = Rglpk::Problem.new
    r = p.add_row
    assert_kind_of Rglpk::Row, r
    assert_equal 1, r.i
    assert_equal 1, p.rows.size
    r = p.add_row
    assert_equal 2, r.i
    assert_equal 2, p.rows.size
  end

  def test_add_rows
    p = Rglpk::Problem.new
    p.add_rows(2)
    assert_equal 2, p.rows.size
    p.add_rows(2)
    assert_equal 4, p.rows.size
  end

  def test_add_column
    p = Rglpk::Problem.new
    c = p.add_col
    assert_kind_of Rglpk::Column, c
    assert_equal 1, c.j
    assert_equal 1, p.cols.size
    c = p.add_col
    assert_equal 2, c.j
    assert_equal 2, p.cols.size
  end

  def test_add_cols
    p = Rglpk::Problem.new
    p.add_cols(2)
    assert_equal 2, p.cols.size
    p.add_cols(2)
    assert_equal 4, p.cols.size
  end

  def test_set_row_name
    p = Rglpk::Problem.new
    p.add_rows(10)
    p.rows[1].name = 'test'
    assert_equal 'test', p.rows[1].name
    assert_nil p.rows[2].name
  end

  def test_set_col_name
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.cols[0].name = 'test'
    assert_equal 'test', p.cols[0].name
    assert_nil p.cols[1].name
  end

  def test_set_row_bounds
    p = Rglpk::Problem.new
    p.add_rows(2)
    p.rows[1].set_bounds(Rglpk::GLP_FR, nil, nil)
    assert_equal [Rglpk::GLP_FR, nil, nil], p.rows[1].bounds
  end

  def test_set_col_bounds
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.cols[1].set_bounds(Rglpk::GLP_FR, nil, nil)
    assert_equal [Rglpk::GLP_FR, nil, nil], p.cols[1].bounds
  end

  def test_obj_coef
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.obj.set_coef(1, 2)
    assert_equal [2, 0], p.obj.coefs
    p.obj.coefs = [1, 2]
    assert_equal [1, 2], p.obj.coefs
  end

  def test_set_row
    p = Rglpk::Problem.new
    p.add_rows(2)
    assert_raises(RuntimeError){p.rows[1].set([1, 2])}
    p.add_cols(2)
    p.rows[1].set([1, 2])
    assert_equal [1, 2], p.rows[1].get
  end

  def test_set_col
    p = Rglpk::Problem.new
    p.add_cols(2)
    assert_raises(RuntimeError){p.cols[1].set([1, 2])}
    p.add_rows(2)
    p.cols[1].set([1, 2])
    assert_equal [1, 2], p.cols[1].get
  end

  def test_set_mat
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_equal [1, 2], p.rows[0].get
    assert_equal [3, 4], p.rows[1].get
    assert_equal [1, 3], p.cols[0].get
    assert_equal [2, 4], p.cols[1].get
  end

  def test_del_row
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_equal [1, 2], p.rows[0].get
    p.del_rows([1])
    assert_equal [3, 4], p.rows[0].get
    assert_equal [3], p.cols[0].get
  end

  def test_del_col
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_equal [1, 3], p.cols[0].get
    p.del_cols([1])
    assert_equal [2, 4], p.cols[0].get
    assert_equal [2], p.rows[0].get
  end

  def test_nz
    p = Rglpk::Problem.new
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_equal 4, p.nz
  end

  def test_row_get_by_name
    p = Rglpk::Problem.new
    assert_raises(RuntimeError){ p.rows['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_raises(ArgumentError){ p.rows['test'] }
    p.rows[0].name = 'test'
    assert_equal [1, 2], p.rows['test'].get
  end
  
  def test_get_row_range
    p = Rglpk::Problem.new
    p.add_rows(5)
    assert_equal 2, p.rows[3..-1].size
  end

  def test_col_get_by_name
    p = Rglpk::Problem.new
    assert_raises(RuntimeError){ p.cols['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    assert_raises(ArgumentError){ p.cols['test'] }
    p.cols[0].name = 'test'
    assert_equal [1, 3], p.cols['test'].get
  end

  def test_solve
    p = Rglpk::Problem.new
    assert_raises(RuntimeError){ p.cols['test'] }
    p.add_cols(2)
    p.add_rows(2)
    p.set_matrix([1, 2, 3, 4])
    p.simplex({:msg_lev => 1})
  end

  def test_sparse_row
    p = Rglpk::Problem.new
    p.add_cols(7)
    rows = p.add_rows(3)
    rows[0].set [1], [5]
    rows[1].set [3, 6], [6, 7]
    rows[2].set [1, 2, 3], [4, 5, 7]
    assert_equal [0, 0, 0, 0, 1, 0, 0], rows[0].get
    assert_equal [0, 0, 0, 0, 0, 3, 6], rows[1].get
    assert_equal [0, 0, 0, 1, 2, 0, 3], rows[2].get
  end

  class D < Rglpk::Problem
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
