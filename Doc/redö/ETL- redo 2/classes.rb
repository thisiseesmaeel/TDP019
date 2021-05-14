## Alla klasser som behövs

$our_funcs = Hash.new

class ScopeHandler
    def initialize()
        @@level = 1
        @@holder = {}
    end
    def defineScope(s)
        @@holder = s
        return @@holder
    end
    def receiveHolder()
        return @@holder
    end
    def receiveLevel()
        return @@level
    end
    def incre()
        @@level = @@level + 1
        return @@holder
    end
    def decre(s)
        defineScope(s)
        @@level = @@level - 1
        return nil
    end
end

$scope = ScopeHandler.new

def look_up(variable, our_vars)
    levelNr = $scope.receiveLevel
    if our_vars == $scope.receiveHolder
        loop do 
            if our_vars[levelNr] and our_vars[levelNr][variable]
                return our_vars[levelNr][variable]
            end
            levelNr = levelNr - 1
        break if (levelNr < 0)
        end
        
        if our_vars[levelNr] == nil
            our_vars[variable]
        end
    end
end

class Variable
    attr_accessor :variable_name
    def initialize(id)
        @variable_name = id
    end
    def eval
        return look_up(@variable_name, $scope.receiveHolder)
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
            when '^'
                return lhs.eval ** rhs.eval
            when '%'
                return lhs.eval % rhs.eval
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
        case @sign
            when 'plus'
                return @lhs.eval + @rhs.eval 
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
    def eval
        value = @assign_expr.eval
        @level_Nr = $scope.receiveLevel
        scp = $scope.receiveHolder
        if scp[@level_Nr]
            if scp[@level_Nr].has_key?(@variable.variable_name)
                return scp[@level_Nr][@variable.variable_name] = value
            else
                scp[@level_Nr][@variable.variable_name] = value
                return $scope.defineScope(scp)
            end
        elsif scp[@level_Nr] = {} and scp[@level_Nr][@variable.variable_name] = value
            return $scope.defineScope(scp)
        end
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
        if @value.eval != nil   
            puts "-->> Printing '#{@value.eval}'"
            @value.eval
        else
            nil
        end   
    end
end

class If
    attr_accessor :if_bool_logic, :states, :elsif_bool_logic, :elsif_state, :otherwise_states
    def initialize(if_bool_logic, states, elsif_bool_logic = nil, elsif_state = nil, otherwise_states = nil)
        @if_bool_logic = if_bool_logic
        @states = states
        @elsif_bool_logic = elsif_bool_logic
        @elsif_state = elsif_state
        @otherwise_states = otherwise_states
    end
    def eval()
        if @if_bool_logic.eval()
            @states.eval()
        elsif @elsif_bool_logic.eval()
                @elsif_state.eval()
        elsif @otherwise_states != nil
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
            if (segment.eval() == "stop")
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

class Function     
    attr_accessor :def_name, :f_arguments, :states
    def initialize(def_name, f_arguments, states)
        @def_name = def_name
        @f_arguments = f_arguments
        @states = states
        if !$our_funcs.has_key?(@def_name)
            $our_funcs[def_name] = self
        else
            raise("OOOPS! THE FUNCTION \"#{@def_name}\" DOES ALREADY EXIST!")
        end
    end
    def recieveStates()
        @states
    end
    def recieveArgs()
        @f_arguments
    end
    def eval()
    end
end

class FunctionCall
    attr_accessor :def_name, :f_c_arguments
    def initialize(def_name, f_c_arguments)
        @def_name = def_name
        @f_c_arguments = f_c_arguments
        @states = $our_funcs[@def_name.variable_name].recieveStates
        @f_arguments = $our_funcs[@def_name.variable_name].recieveArgs

        if !$our_funcs.has_key?(@def_name.variable_name)
            raise("OOOPS! THERE IS NO FUNCTION CALLED '#{@def_name.variable_name}' ")
        end
        if (@f_c_arguments.length != @f_arguments.length)
            raise("FAIL! WRONG NUMBER OF ARGUMENTS. (GIVEN #{@f_c_arguments.length} EXPECTED #{@f_arguments.length})")
        end
    end
    def eval()        
        scp = $scope.incre
        funcArgs_len = 0
        funcCallArgs_len = @f_c_arguments.length
        while (funcArgs_len < funcCallArgs_len)
            scp[@f_arguments[funcArgs_len].variable_name] = @f_c_arguments[funcArgs_len].eval
            funcArgs_len = funcArgs_len + 1
        end   
        @states.each { |state|
            if state.class == Return 
                puts "-->> Function '#{@def_name.variable_name}' returning '#{state.eval}'"
            else
                state.eval
            end }
        scp.delete($scope.receiveLevel)
        $scope.decre(scp)
    end
end 

class Return
    def initialize(value)
        @value = value
    end
    def eval
        return @value.eval
    end
end