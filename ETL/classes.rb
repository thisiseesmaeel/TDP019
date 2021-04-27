## Alla klasser som behövs

$our_vars = Hash.new

def look_up(variable, our_hash) # slå upp värde i $our_vars
    our_hash[variable]
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
    attr_accessor :sign, :lhs, :rhs
    def initialize(sign, lhs, rhs)
        @sign = sign
        @lhs = lhs
        @rhs = rhs
    end
    def eval()
        case sign
            when '+'
                return lhs.eval + rhs.eval 
            when '-'
                return lhs.eval - rhs.eval
            when '*'
                return lhs.eval * rhs.eval 
            when '/'
                return lhs.eval / rhs.eval
            else nil
        end
    end
end

class Plus_str
    attr_accessor :sign, :lhs, :rhs
    def initialize(sign, lhs, rhs)
        @sign = sign
        @lhs = lhs
        @rhs = rhs
    end
    def eval()
        case sign
            when 'plus'
                return lhs.eval + rhs.eval
            else nil
        end
    end
end

class Condition
    attr_accessor :sign, :lhs, :rhs
    def initialize(sign, lhs, rhs)
        @sign = sign
        @lhs = lhs
        @rhs = rhs
    end
    def eval()
        case sign
            when '<', 'less than'
                return lhs.eval < rhs.eval 
            when '>', 'greater than'
                return lhs.eval > rhs.eval 
            when '<=', 'less than or equal to'
                return lhs.eval <= rhs.eval 
            when '>=', 'greater than or equal to'
                return lhs.eval >= rhs.eval 
            when '!=', 'not equal to'
                return lhs.eval != rhs.eval
            when '==', 'equal'
                return lhs.eval == rhs.eval
            when 'and'
                return lhs.eval && rhs.eval
            when 'or'
                return lhs.eval || rhs.eval
            else nil
        end
    end
end

class Not
    attr_accessor :sign, :oper
    def initialize(sign, oper)
        @sign = sign
        @oper = oper
    end
    def eval()
        case sign
            when 'not'
                return  (not oper.eval)
            else nil
        end
    end
end

class Expression
    def initialize(value)
        @value = value
    end
    def eval()
        @value.eval
    end
end

class Assign             
    attr_reader :variable, :assign_expr
    def initialize(variable, assign_expr)
        @variable = variable
        @assign_expr = assign_expr
    end
    def eval()
        value = @assign_expr.eval
        #puts "-> Assigning '#{@variable.variable_name}' to '#{value}' \n"
        $our_vars[@variable.variable_name] = value
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
    def eval()
        #puts
        puts "--->>> Printing '#{@value.eval}'"
    end 
end

class If
    attr_accessor :bool_logic, :states, :otherwise_states
    def initialize(bool_logic, states, otherwise_states = nil)
        @bool_logic = bool_logic
        @states = states
        @otherwise_states = otherwise_states
    end
    def eval()
        if @bool_logic.eval()
            @states.eval()
        else @otherwise_states != nil
            @otherwise_states.eval()
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
        check_stop = false
	    while @bool_logic.eval
            @states.each { |segment|
            value = segment.eval()
            if (value == "stop")
                check_stop = true
            end }
            if (check_stop == true)
                break
            end
        end
        @states
    end
end

class Stop
    def initialize()
    end
    def eval()
        return "stop"
    end
end

$our_funcs = Hash.new

class Function     
    attr_accessor :def_name, :f_arguments, :states
    def initialize(def_name, f_arguments, states)
        @def_name = def_name
        @f_arguments = f_arguments
        @states = states
        if !$our_funcs.has_key?(@def_name)
            $our_funcs[def_name] = self
        else
            raise("OOOPS! THE FUNCTION \"#{@def_name}\" DOES ALREADY EXISTS!")
        end
    end
    def recieveStates()
        @states
    end
    def recieveArgs()
        @f_arguments
    end
end

class FunctionCall
    attr_accessor :def_name, :f_c_argument
    def initialize(def_name,f_c_argument)
        @def_name = def_name
        @f_c_argument = f_c_argument
        if !$our_funcs.has_key?(@def_name.variable_name)
            raise("OOOPS! THERE IS NO FUNCTION CALLED '#{@def_name.variable_name}' ")
        end

        @states = $our_funcs[@def_name.variable_name].recieveStates
        @f_arguments = $our_funcs[@def_name.variable_name].recieveArgs
        
        if (@f_c_argument.length != @f_arguments.length)
            raise("FAIL! WRONG NUMBER OF ARGUMENTS. (GIVEN #{@f_c_argument.length} EXPECTED #{@f_arguments.length})")
        end
    end
    def eval()
        funcArgs_len = 0
        funcCallArgs_len = @f_c_argument.length
        while (funcArgs_len < funcCallArgs_len)
            $our_vars[@f_arguments[funcArgs_len].variable_name] = @f_c_argument[funcArgs_len].eval
            funcArgs_len = funcArgs_len + 1
        end       
        @states.each { |state|
            if state.class == Return 
                return state.eval
                break
            else
                state.eval
            end }
    end
end

class Return
    def initialize(thing)
        @thing = thing
    end
    def eval
        return @thing.eval
    end
end 