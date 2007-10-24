require 'rglpk.so'

module GLPK

  Rglpk.constants.each do |c|
    v = Rglpk.const_get(c)
    self.const_set(c,v) if v.kind_of? Numeric
  end
  TypeConstants =[GLP_FR, GLP_LO, GLP_UP, GLP_DB, GLP_FX]

  class RowColArray < Array
    def [](i)
      super(i-1)
    end
    def []=(i,n)
      super(i-1,n)
    end
    def fix_idx
      self.each_with_index do |rc,i|
        if rc.respond_to?(:i)
          rc.i = i+1
        else
          rc.j = i+1
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
        idx = Rglpk.glp_find_row(self[1].p.lp,i)
        raise ArgumentError if idx == 0
        super(idx)
      else
        raise ArgumentError
      end
    end   
    def []=(i,n)
      raise ArgumentError unless n.is_a?(GLPK::Row)
      super
    end
  end
  class ColArray < RowColArray
    def [](i)
      if i.kind_of?(Numeric)
        super(i)
      elsif i.kind_of?(String)
        raise RuntimeError if self[1].nil?
        idx = Rglpk.glp_find_col(self[1].p.lp,i)
        raise ArgumentError if idx == 0
        super(idx)
      else
        raise ArgumentError
      end
    end   
    def []=(i,n)
      raise ArgumentError unless n.is_a?(GLPK::Col)
      super
    end
  end

  class Problem

    attr_accessor :rows, :cols, :obj, :lp

    def initialize
      @lp = Rglpk.glp_create_prob
      @obj = GLPK::ObjectiveFunction.new(self)
      @rows = GLPK::RowArray.new
      @cols = GLPK::ColArray.new
      Rglpk.glp_create_index(@lp)
      @status = nil
    end
    
    def name=(n)
      Rglpk.glp_set_prob_name(@lp,n)
    end
    def name
      Rglpk.glp_get_prob_name(@lp)
    end
    
    def nz
      Rglpk.glp_get_num_nz(@lp)
    end

    def add_rows(n)
      Rglpk.glp_add_rows(@lp,n)
      s = @rows.size
      n.times{|i| @rows << GLPK::Row.new(self,s+i+1)}
      @rows
    end
    def add_cols(n)
      Rglpk.glp_add_cols(@lp,n)
      s = @cols.size
      n.times{|i| @cols << GLPK::Column.new(self,s+i+1)}
      @cols
    end      
        
    def del_rows(a)
      #ensure the array of rows tro delete is sorted and unique
      a = a.sort.uniq

      r = Rglpk.new_intArray(a.size+1)
      a.each_with_index{|n,i| Rglpk.intArray_setitem(r,i+1,n)}
      Rglpk.glp_del_rows(@lp,a.size,r)

      a.each do |n|
        @rows.delete_at(n)
        a.each_with_index do |nn,i|
          a[i] -= 1
        end
      end
      @rows.fix_idx
      a
    end

    def del_cols(a)
      #ensure the array of rows tro delete is sorted and unique
      a = a.sort.uniq

      r = Rglpk.new_intArray(a.size+1)
      a.each_with_index{|n,i| Rglpk.intArray_setitem(r,i+1,n)}
      Rglpk.glp_del_cols(@lp,a.size,r)

      a.each do |n|
        @cols.delete_at(n)
        a.each_with_index do |nn,i|
          a[i] -= 1
        end
      end
      @cols.fix_idx
      a
    end

    def set_matrix(v)
      
      nr = Rglpk.glp_get_num_rows(@lp)
      nc = Rglpk.glp_get_num_cols(@lp)
      
      ia = Rglpk.new_intArray(v.size+1)
      ja = Rglpk.new_intArray(v.size+1)
      ar = Rglpk.new_doubleArray(v.size+1)
      
      v.each_with_index do |x,y|
        rn = (y+nr) / nc
        cn = (y % nc) + 1

        Rglpk.intArray_setitem(ia,y+1,rn) # 1,1,2,2
        Rglpk.intArray_setitem(ja,y+1,cn) # 1,2,1,2
        Rglpk.doubleArray_setitem(ar,y+1,x)
      end
      
      Rglpk.glp_load_matrix(@lp,v.size,ia,ja,ar)
      
    end

    def simplex(options)

      parm = Rglpk::Glp_smcp.new
      Rglpk.glp_init_smcp(parm)

      #Default to errors only temrinal output
      parm.msg_lev = GLPK::GLP_MSG_ERR

      #set options
      options.each do |k,v|
        begin
          parm.send("#{k}=".to_sym,v)
        rescue NoMethodError
          raise ArgumentError, "Unrecognised option: #{k}"
        end
      end

      Rglpk.glp_simplex(@lp,parm)
    end

    def status
      Rglpk.glp_get_status(@lp)
    end

  end
        
  class Row
    attr_accessor :i, :p
    def initialize(problem,i)
      @p = problem
      @i = i
    end
    def name=(n)    
      Rglpk.glp_set_row_name(@p.lp,@i,n)
    end
    def name
      Rglpk.glp_get_row_name(@p.lp,@i)
    end
    def set_bounds(type,lb,ub)
      raise ArgumentError unless GLPK::TypeConstants.include?(type)
      lb = 0.0 if lb.nil?
      ub = 0.0 if ub.nil?
      Rglpk.glp_set_row_bnds(@p.lp,@i,type,lb.to_f,ub.to_f)
    end 
    def bounds
      t  = Rglpk.glp_get_row_type(@p.lp,@i)
      lb = Rglpk.glp_get_row_lb(@p.lp,@i)
      ub = Rglpk.glp_get_row_ub(@p.lp,@i)

      lb = (t == GLPK::GLP_FR or t == GLPK::GLP_UP) ? nil : lb
      ub = (t == GLPK::GLP_FR or t == GLPK::GLP_LO) ? nil : ub      
      
      [t,lb,ub]
    end
    def set(v)
      raise RuntimeError unless v.size == @p.cols.size
      ind = Rglpk.new_intArray(v.size+1)
      val = Rglpk.new_doubleArray(v.size+1)
      
      1.upto(v.size){|x| Rglpk.intArray_setitem(ind,x,x)}
      v.each_with_index{|x,y| Rglpk.doubleArray_setitem(val,y+1,x)}
      
      Rglpk.glp_set_mat_row(@p.lp,@i,v.size,ind,val)      
    end
    def get
      ind = Rglpk.new_intArray(@p.cols.size+1)
      val = Rglpk.new_doubleArray(@p.cols.size+1)      
      len = Rglpk.glp_get_mat_row(@p.lp,@i,ind,val)
      row = Array.new(@p.cols.size,0)
      len.times do |i|
        v = Rglpk.doubleArray_getitem(val,i+1)
        j = Rglpk.intArray_getitem(ind,i+1)
        row[j-1] = v
      end
      return row
    end
  end
  class Column
    attr_accessor :j, :p
    def initialize(problem,i)
      @p = problem
      @j = i
    end
    def name=(n)
      Rglpk.glp_set_col_name(@p.lp,@j,n)
    end
    def name
      Rglpk.glp_get_col_name(@p.lp,@j)
    end
    def set_bounds(type,lb,ub)
      raise ArgumentError unless GLPK::TypeConstants.include?(type)
      lb = 0.0 if lb.nil?
      ub = 0.0 if ub.nil?
      Rglpk.glp_set_col_bnds(@p.lp,@j,type,lb,ub)
    end     
    def bounds
      t  = Rglpk.glp_get_col_type(@p.lp,@j)
      lb = Rglpk.glp_get_col_lb(@p.lp,@j)
      ub = Rglpk.glp_get_col_ub(@p.lp,@j)

      lb = (t == GLPK::GLP_FR or t == GLPK::GLP_UP) ? nil : lb
      ub = (t == GLPK::GLP_FR or t == GLPK::GLP_LO) ? nil : ub      
      
      [t,lb,ub]
    end
    def set(v)
      raise RuntimeError unless v.size == @p.rows.size
      ind = Rglpk.new_intArray(v.size+1)
      val = Rglpk.new_doubleArray(v.size+1)
      
      1.upto(v.size){|x| Rglpk.intArray_setitem(ind,x,x)}
      v.each_with_index{|x,y| Rglpk.doubleArray_setitem(val,y+1,x)}
      
      Rglpk.glp_set_mat_col(@p.lp,@j,v.size,ind,val)    
    end 
    def get
      ind = Rglpk.new_intArray(@p.rows.size+1)
      val = Rglpk.new_doubleArray(@p.rows.size+1)      
      len = Rglpk.glp_get_mat_col(@p.lp,@j,ind,val)
      col = Array.new(@p.rows.size,0)
      len.times do |i|
        v = Rglpk.doubleArray_getitem(val,i+1)
        j = Rglpk.intArray_getitem(ind,i+1)
        col[j-1] = v
      end
      return col
    end    
  end    

  class ObjectiveFunction
    def initialize(problem)
      @p = problem
    end
    def name=(n)
      Rglpk.glp_set_obj_name(@p.lp,n)
    end
    def name
      Rglpk.glp_get_obj_name(@p.lp)
    end
    def dir=(d)
      raise ArgumentError if d != GLPK::GLP_MIN and d != GLPK::GLP_MAX
      Rglpk.glp_set_obj_dir(@p.lp,d)
    end
    def dir
      Rglpk.glp_get_obj_dir(@p.lp)
    end
    def set_coef(j,coef)
      Rglpk.glp_set_obj_coef(@p.lp,j,coef)
    end
    def coefs=(a)
      @p.cols.each{|c| Rglpk.glp_set_obj_coef(@p.lp,c.j,a[c.j-1])}
      a
    end
    def coefs
      @p.cols.map{|c| Rglpk.glp_get_obj_coef(@p.lp,c.j)}
    end
    def get
      Rglpk.glp_get_obj_val(@p.lp)
    end
  end
end
