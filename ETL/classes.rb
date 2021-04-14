## Alla klasser som behövs

$our_vars = Hash.new
$our_funcs = Hash.new
$our_str_vars = Array.new   
$our_num_vars = Array.new
$our_bool_vars = Array.new


class Statements
  attr_accessor :stat, :states
  def initialize (stat,states)
    @stat = stat 
    @states = states  
  end
  def eval()
    return_value = @stat.eval
    if @stat.class != Expression_node
      	@states.eval
    else
      return_value
    end
  end
end

def look_up(var, hash)
  hash[var]
end 

class Variable              
  attr_accessor :variable_name
  def initialize(id)
    @variable_name = id
  end
  def eval()
    return look_up(@variable_name, $our_vars)
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
        else nil
    end
  end
end

class Condition
  attr_accessor :oper, :oper1, :oper2
  def initialize(oper, oper1, oper2)
    @oper = oper
    @oper1 = oper1
    @oper2 = oper2
  end
  def eval()
    case oper
        when '<', 'less than'
            return oper1.eval < oper2.eval 
        when '>', 'greater than'
            return oper1.eval > oper2.eval 
        when '<=', 'less than or equal to'
            return oper1.eval <= oper2.eval 
        when '>=', 'greater than or equal to'
            return oper1.eval >= oper2.eval 
        when '!=', 'not equal to'
            return oper1.eval != oper2.eval
        when '==', 'equal'
            return oper1.eval == oper2.eval
        when 'and'
            return oper1.eval && oper2.eval
        when 'or'
            return oper1.eval || oper2.eval
        else nil
    end
  end
end

class Not
  attr_accessor :oper, :oper1
  def initialize(oper, oper1)
    @oper = oper
    @oper1 = oper1
  end
  def eval()
    case oper
        when 'not'
            return  (not oper1.eval)
        else nil
    end
  end
end

class Expression_node
  def initialize(nn)
    @next_node = nn
  end
  def eval()
    @next_node.eval
  end
end

class Assign             
  attr_reader :var
  def initialize(var, expr)
    @var=var
    @assign_expr = expr
  end
  def eval()
    value = @assign_expr.eval
    puts "--> assigning #{@var.variable_name} to #{value} \n"
    $our_vars[@var.variable_name] = value
  end
end

class Constant
  attr_accessor :value
  def initialize (value, negative = nil)
    @value = value
    @negative = negative
  end
  def eval()
    if @negative
      @value * -1
    else
      @value
    end
  end
end 

class Print
  def initialize(value)
    @value = value
  end
  def eval
    #if @value.class == Function_call then
     # temp = @value.eval
      #p temp["_-_Return_-_"]
    #else
    puts "--> Printing  #{@value.eval}"
    #end
    return "Result #{[@value.eval]}"
  end
end 

class If
  attr_accessor :bool_logic, :states, :else_states
  def initialize(bool_logic, states, else_states = false)
    @bool_logic = bool_logic
    @states = states
    @else_states = else_states
  end
  def eval()
    if @bool_logic.eval()
      @states.eval()
    elsif @else_states != false
      @else_states.eval()
    end
  end
end