## Den ska innehålla alla klasser som behövs

#(HJÄLP) kanske spara statements i en lista

$our_vars = Hash.new
##@@our_funcs = Hash.new
$our_str_vars = Array.new   
$our_num_vars = Array.new
##@@our_bool_vars = Array.new


def look_up(variable, our_vars)
    our_vars[variable]
end

class Variable              
    attr_accessor :name
    def initialize(id)
        @name = id
    end
    def eval()
        return look_up(@name, $our_vars)
    end
end 


class Expr
    def initialize(nn)
        @next_node = nn
    end
    def eval()
        @next_node.eval
    end
end
  
class Addition
    def initialize(a, b)
        @a = a
        @b = b
    end

    def eval()
        @a.eval + @b.eval
    end
end

class Subtraction
    def initialize(a, b)
        @a = a
        @b = b
    end

    def eval()
        @a.eval - @b.eval
    end
end

class Multiplication
    def initialize(a, b)
        @a = a
        @b = b
    end

    def eval()
        @a.eval * @b.eval
    end
end

class Division
    def initialize(a, b)
        @a = a
        @b = b
    end

    def eval()
        @a.eval / @b.eval
    end
end

class Int_Float
    def initialize(i)
        @number = i
    end

    def eval()
        @number
    end
end


=begin 
class Assign
    attr_accessor :var, :tilldelnings_uttryck
    def initialize(var, uttr)
      @var=var
      @tilldelnings_uttryck = uttr
    end
    def eval()
      varde = tilldelnings_uttryck.eval
      if  (@@string_vars.include?(var.name)) and varde.class == String  then
        @@our_vars[var.name] = varde
      elsif  (@@our_num_vars.include?(var.name)) and varde.class == Fixnum  then
        @@our_vars[var.name] = varde
      else
        abort( "ERROR: variabeln #{varde.name} finns inte eller är fel typ. (#{varde.class})")
      end
    end
end
=end

 
=begin 
class Assign        # <tilldelning> := <var> <tilldelnings_uttryck>
    attr_reader :variable  
    def initialize(variable, expr)
      @variable = variable
      @assign_expr = expr
    end
    def eval()
      value = assign_expr.eval
      puts "--> assign " + @variable.name + " = #{value} \n"
      $our_vars[@variable.name] = value
    end
end
#p Assign.new("a", 5)
=end


=begin  
class Assign
    def initialize(variable, oper, expr) # a = 3 + 4
		@variable = variable
		@expression = expression
		@oper = oper
	end

end 
=end

=begin class Expr
    attr_accessor :oper, :oper1, :oper2
    def initialize(oper, oper1, oper2)
      @oper = oper
      @oper1 = oper1
      @oper2 = oper2
    end
    def eval()
      case oper
          when '+'
              return oper1.eval + oper2.eval 
          when '-'
              return oper1.eval - oper2.eval
          when '*'
              return oper1.eval * oper2.eval 
          when '/'
              return oper1.eval / oper2.eval
          when 'plus'
              return oper1.eval + oper2.eval
          when '<'
              return oper1.eval < oper2.eval 
          when '>'
              return oper1.eval > oper2.eval 
          when '<='
              return oper1.eval <= oper2.eval 
          when '>='
              return oper1.eval >= oper2.eval 
          when '!='
              return oper1.eval != oper2.eval
          when '=='
              return oper1.eval == oper2.eval
          when 'and'
              return oper1.eval && oper2.eval
          when 'not'
              return  (not oper2.eval)
          when 'or'
              return oper1.eval || oper2.eval
          else nil
      end
    end
end
=end