## Alla klasser som behövs

$our_vars = Hash.new()
$our_funcs = Hash.new()
#$our_str_vars = Array.new   
#$our_num_vars = Array.new
#$our_bool_vars = Array.new


class Statements
    attr_accessor :stat, :states
    def initialize (stat,states)
        @stat = stat 
        @states = states  
    end
    def eval()
        return_value = @stat.eval()
        if @stat.class != ExpressionNode
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
    def get_name
        for var in $our_vars 
            if var[@variable_name]
                return @variable_name
            end
        end
        return "false"
    end
    def return_var_name
    	return @variable_name
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

class ExpressionNode
    def initialize(nn)
        @next_node = nn
    end
    def eval()
        @next_node.eval
    end
end

class Assign             
    attr_reader :var, :assign_expr
    def initialize(var, expr)
        @var=var
        @assign_expr = expr
    end
    def eval()
        value = @assign_expr.eval
        puts "-> Assigning '#{@var.variable_name}' to '#{value}' \n"
        $our_vars[@var.variable_name] = value
        #p $our_vars
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
        #if @value.class == FunctionCall then
         #  temp = @value.eval
          # p temp["Returning"]
        #else
            puts "-> Printing '#{@value.eval}'"
        #end
        return "Result '#{[@value.eval]}'"
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
        else @else_states != false
            @else_states.eval()
        end
    end
end 


class While
    attr_accessor :bool_logic, :states
    def initialize(bool_logic, states)
        @bool_logic = bool_logic
        @states = states
    end
    def eval()
        while @bool_logic.eval()
            while_check = @states.eval()
            if while_check == "break"
                return "Done!"
            end
        end
    end
end

class Break
    def initialize()
    end
    def eval()
        return "break"
    end
end

class Function
    attr_accessor :def_name, :states, :parameters
	def initialize(def_name, states, parameters = nil)
		@def_name = def_name
        @states = states
		@parameters = parameters
	end
	def eval()
		if (@def_name.get_name() != "false")
			puts "Function's name already exists"
			return nil
		else
			$our_funcs[@def_name.return_var_name()] = [@parameters, @states]
		end
        #puts
        #p $our_funcs
	end
end

class FunctionCall
    attr_accessor :def_name, :parameters
	def initialize(def_name, parameters = nil)
		@def_name = def_name
		@parameters = parameters
    end
	def eval()
		if !($our_funcs[@def_name.return_var_name()])
			return "No function exists with the name: '#{@def_name.return_var_name()}'"
		end

        puts 
        p $our_funcs

        #return look_up(@def_name, $our_funcs)
        if !(parameters)
            return $our_funcs[@def_name.return_var_name()][1].eval 
        else
            return $our_funcs[@def_name.return_var_name()][0].eval 
        end 
	end
end 

class Return
    #attr_accessor :re_value
    def initialize (value)
        @value = value
    end
    def eval()
        re_value = Hash.new
        re_value["Returning"] = @value.eval()
        #return "Returning '#{@value.eval}'"
        re_value 
    end
end 



#{"add"=>[nil, #<Return:0x00005642b051d760 @value=#<Expr:0x00005642b05cc6c0 @oper="+", @oper1=#<Constant:0x00005642b05ce538 @value=2, @negative=nil>, @oper2=#<Constant:0x00005642b05cd1d8 @value=3, @negative=nil>>>]}

