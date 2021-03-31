## Den ska innehålla alla klasser som behövs

# spara statments i en lista
@@our_vars = Hash.new
@@our_funcs = Hash.new
@@our_str_vars = Array.new   
@@our_num_vars = Array.new
@@our_bool_vars = Array.new


def look_up(var, our_hashs)
    our_hashs[var]
end

class Look_up_var
	attr_accessor :value
	def initialize (var)
		@value = var
	end
	def eval()
		@@our_vars.each_key  do |key|
			if key == @value then
				return @@our_vars[key]
			else
				return nil
			end
		end
	end
end

class Print         
    attr_accessor :print
    def initialize (variable)
      @print = variable 
    end
    def eval()
      if @print.class == Function_call then
          temp = @print.eval
          p temp["_-_Return_-_"]
      else
          p @print.eval
      end
      return nil
    end
end

class Atom           
    attr_accessor :value
    def initialize (param)
      @value = param
    end
    def eval()
      return @value
    end
end

class Variable              
    attr_accessor :variable_name
    def initialize(id)
      @variable_name = id
    end
    def eval()
      return look_up(@variable_name, @@our_vars)
    end
end

class Expr
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

  