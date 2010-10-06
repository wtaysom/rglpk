require 'glpk_wrapper'

module Rglpk
  Glpk_wrapper.constants.each do |c|
    v = Glpk_wrapper.const_get(c)
    self.const_set(c, v) if v.kind_of? Numeric
  end
  TypeConstants = [GLP_FR, GLP_LO, GLP_UP, GLP_DB, GLP_FX]

  class RowColArray < Array
    def [](i)
      super(i - 1)
    end
    
    def []=(i, n)
      super(i - 1, n)
    end
    
    def fix_idx
      self.each_with_index do |rc, i|
        if rc.respond_to?(:i)
          rc.i = i + 1
        else
          rc.j = i + 1
        end
      end
    end
  end
  
  class RowArray < RowColArray
    def [](i)
      if i.kind_of?(Numeric)
        super(i)
      elsif i.kind_of?(String)
        raise RuntimeError if self[1].nil?
        idx = Glpk_wrapper.glp_find_row(self[1].p.lp, i)
        raise ArgumentError if idx == 0
        super(idx)
      else
        raise ArgumentError
      end
    end
     
    def []=(i, n)
      raise ArgumentError unless n.is_a?(Row)
      super
    end
  end
  
  class ColArray < RowColArray
    def [](i)
      if i.kind_of?(Numeric)
        super(i)
      elsif i.kind_of?(String)
        raise RuntimeError if self[1].nil?
        idx = Glpk_wrapper.glp_find_col(self[1].p.lp, i)
        raise ArgumentError if idx == 0
        super(idx)
      else
        raise ArgumentError
      end
    end
    
    def []=(i, n)
      raise ArgumentError unless n.is_a?(Col)
      super
    end
  end

  class Problem
    attr_accessor :rows, :cols, :obj, :lp

    def initialize
      @lp = Glpk_wrapper.glp_create_prob
      @obj = ObjectiveFunction.new(self)
      @rows = RowArray.new
      @cols = ColArray.new
      Glpk_wrapper.glp_create_index(@lp)
      @status = nil
    end
    
    def name=(n)
      Glpk_wrapper.glp_set_prob_name(@lp, n)
    end
    
    def name
      Glpk_wrapper.glp_get_prob_name(@lp)
    end
    
    def nz
      Glpk_wrapper.glp_get_num_nz(@lp)
    end

    def add_rows(n)
      Glpk_wrapper.glp_add_rows(@lp, n)
      s = @rows.size
      n.times{|i| @rows << Row.new(self, s + i + 1)}
      @rows
    end
    
    def add_cols(n)
      Glpk_wrapper.glp_add_cols(@lp, n)
      s = @cols.size
      n.times{|i| @cols << Column.new(self, s + i + 1)}
      @cols
    end
        
    def del_rows(a)
      # Ensure the array of rows tro delete is sorted and unique.
      a = a.sort.uniq

      r = Glpk_wrapper.new_intArray(a.size + 1)
      a.each_with_index{|n, i| Glpk_wrapper.intArray_setitem(r, i + 1, n)}
      Glpk_wrapper.glp_del_rows(@lp, a.size, r)

      a.each do |n|
        @rows.delete_at(n)
        a.each_with_index do |nn, i|
          a[i] -= 1
        end
      end
      @rows.fix_idx
      a
    end

    def del_cols(a)
      # Ensure the array of rows tro delete is sorted and unique.
      a = a.sort.uniq

      r = Glpk_wrapper.new_intArray(a.size + 1)
      a.each_with_index{|n, i| Glpk_wrapper.intArray_setitem(r, i + 1, n)}
      Glpk_wrapper.glp_del_cols(@lp, a.size, r)

      a.each do |n|
        @cols.delete_at(n)
        a.each_with_index do |nn, i|
          a[i] -= 1
        end
      end
      @cols.fix_idx
      a
    end

    def set_matrix(v)
      nr = Glpk_wrapper.glp_get_num_rows(@lp)
      nc = Glpk_wrapper.glp_get_num_cols(@lp)
      
      ia = Glpk_wrapper.new_intArray(v.size + 1)
      ja = Glpk_wrapper.new_intArray(v.size + 1)
      ar = Glpk_wrapper.new_doubleArray(v.size + 1)
      
      v.each_with_index do |x, y|
        rn = (y + nr) / nc
        cn = (y % nc) + 1

        Glpk_wrapper.intArray_setitem(ia, y + 1, rn) # 1, 1, 2, 2
        Glpk_wrapper.intArray_setitem(ja, y + 1, cn) # 1, 2, 1, 2
        Glpk_wrapper.doubleArray_setitem(ar, y + 1, x)
      end
      
      Glpk_wrapper.glp_load_matrix(@lp, v.size, ia, ja, ar)
    end

    def simplex(options)
      parm = Glpk_wrapper::Glp_smcp.new
      Glpk_wrapper.glp_init_smcp(parm)

      # Default to errors only temrinal output.
      parm.msg_lev = GLP_MSG_ERR

      # Set Options
      options.each do |k, v|
        begin
          parm.send("#{k}=".to_sym, v)
        rescue NoMethodError
          raise ArgumentError, "Unrecognised option: #{k}"
        end
      end

      Glpk_wrapper.glp_simplex(@lp, parm)
    end

    def status
      Glpk_wrapper.glp_get_status(@lp)
    end
  end
        
  class Row
    attr_accessor :i, :p
    
    def initialize(problem, i)
      @p = problem
      @i = i
    end
    
    def name=(n)    
      Glpk_wrapper.glp_set_row_name(@p.lp, @i, n)
    end
    
    def name
      Glpk_wrapper.glp_get_row_name(@p.lp, @i)
    end
    
    def set_bounds(type, lb, ub)
      raise ArgumentError unless TypeConstants.include?(type)
      lb = 0.0 if lb.nil?
      ub = 0.0 if ub.nil?
      Glpk_wrapper.glp_set_row_bnds(@p.lp, @i, type, lb.to_f, ub.to_f)
    end
    
    def bounds
      t  = Glpk_wrapper.glp_get_row_type(@p.lp, @i)
      lb = Glpk_wrapper.glp_get_row_lb(@p.lp, @i)
      ub = Glpk_wrapper.glp_get_row_ub(@p.lp, @i)
      
      lb = (t == GLP_FR or t == GLP_UP) ? nil : lb
      ub = (t == GLP_FR or t == GLP_LO) ? nil : ub
      
      [t, lb, ub]
    end
    
    def set(v)
      raise RuntimeError unless v.size == @p.cols.size
      ind = Glpk_wrapper.new_intArray(v.size + 1)
      val = Glpk_wrapper.new_doubleArray(v.size + 1)
      
      1.upto(v.size){|x| Glpk_wrapper.intArray_setitem(ind, x, x)}
      v.each_with_index{|x, y|
        Glpk_wrapper.doubleArray_setitem(val, y + 1, x)}
      
      Glpk_wrapper.glp_set_mat_row(@p.lp, @i, v.size, ind, val)      
    end
    
    def get
      ind = Glpk_wrapper.new_intArray(@p.cols.size + 1)
      val = Glpk_wrapper.new_doubleArray(@p.cols.size + 1)      
      len = Glpk_wrapper.glp_get_mat_row(@p.lp, @i, ind, val)
      row = Array.new(@p.cols.size, 0)
      len.times do |i|
        v = Glpk_wrapper.doubleArray_getitem(val, i + 1)
        j = Glpk_wrapper.intArray_getitem(ind, i + 1)
        row[j - 1] = v
      end
      row
    end
  end
  
  class Column
    attr_accessor :j, :p
    
    def initialize(problem, i)
      @p = problem
      @j = i
    end
    
    def name=(n)
      Glpk_wrapper.glp_set_col_name(@p.lp, @j, n)
    end
    
    def name
      Glpk_wrapper.glp_get_col_name(@p.lp, @j)
    end
    
    def set_bounds(type, lb, ub)
      raise ArgumentError unless TypeConstants.include?(type)
      lb = 0.0 if lb.nil?
      ub = 0.0 if ub.nil?
      Glpk_wrapper.glp_set_col_bnds(@p.lp, @j, type, lb, ub)
    end
    
    def bounds
      t  = Glpk_wrapper.glp_get_col_type(@p.lp, @j)
      lb = Glpk_wrapper.glp_get_col_lb(@p.lp, @j)
      ub = Glpk_wrapper.glp_get_col_ub(@p.lp, @j)
      
      lb = (t == GLP_FR or t == GLP_UP) ? nil : lb
      ub = (t == GLP_FR or t == GLP_LO) ? nil : ub
      
      [t, lb, ub]
    end
    
    def set(v)
      raise RuntimeError unless v.size == @p.rows.size
      ind = Glpk_wrapper.new_intArray(v.size + 1)
      val = Glpk_wrapper.new_doubleArray(v.size + 1)
      
      1.upto(v.size){|x| Glpk_wrapper.intArray_setitem(ind, x, x)}
      v.each_with_index{|x, y|
        Glpk_wrapper.doubleArray_setitem(val, y + 1, x)}
      
      Glpk_wrapper.glp_set_mat_col(@p.lp, @j, v.size, ind, val)    
    end
    
    def get
      ind = Glpk_wrapper.new_intArray(@p.rows.size + 1)
      val = Glpk_wrapper.new_doubleArray(@p.rows.size + 1)      
      len = Glpk_wrapper.glp_get_mat_col(@p.lp, @j, ind, val)
      col = Array.new(@p.rows.size, 0)
      len.times do |i|
        v = Glpk_wrapper.doubleArray_getitem(val, i + 1)
        j = Glpk_wrapper.intArray_getitem(ind, i + 1)
        col[j - 1] = v
      end
      col
    end
  end

  class ObjectiveFunction
    
    def initialize(problem)
      @p = problem
    end
    
    def name=(n)
      Glpk_wrapper.glp_set_obj_name(@p.lp, n)
    end
    
    def name
      Glpk_wrapper.glp_get_obj_name(@p.lp)
    end
    
    def dir=(d)
      raise ArgumentError if d != GLP_MIN and d != GLP_MAX
      Glpk_wrapper.glp_set_obj_dir(@p.lp, d)
    end
    
    def dir
      Glpk_wrapper.glp_get_obj_dir(@p.lp)
    end
    
    def set_coef(j, coef)
      Glpk_wrapper.glp_set_obj_coef(@p.lp, j, coef)
    end
    
    def coefs=(a)
      @p.cols.each{|c| Glpk_wrapper.glp_set_obj_coef(@p.lp, c.j, a[c.j - 1])}
      a
    end
    
    def coefs
      @p.cols.map{|c| Glpk_wrapper.glp_get_obj_coef(@p.lp, c.j)}
    end
    
    def get
      Glpk_wrapper.glp_get_obj_val(@p.lp)
    end
  end
end
