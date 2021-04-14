##Alla tokens, rules och match

require './rdparse.rb'
require './classes.rb'

class Etl
    attr_accessor :result
    def initialize
        @etlParser = Parser.new("ETL") do
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        token(/\s+/)  #mellanrum ska inte matchas
        token(/(\d+[.]\d+)/) { |m| m.to_f } #floattal
        token(/\d+/) { |m| m.to_i } #heltal
        token(/'[^\']*'/) { |m| m } #sträng inom enkelt citattecken (' ')
        token(/"[^\"]*"/) { |m| m } #sträng inom dubbelt citattecken (" ")
        token(/[a-z]+[a-z0-9_]*/) { |m| m } #variabler name
        token(/plus/) { |m| m }
        token(/./) { |m| m } #allt annat(enkla käraktarer)
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- END TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN BNF +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 

        start :program do
            match("startprogram", :statements, "endprogram") { |_, states, _| states }
            end

        rule :statements do
            match(:statements, :statement) { |states, stat| Statements.new(states, stat) }
            match(:statement)
        end
            
        rule :statement do
            match(:string_expr)
            match(:string_adding)
            match(:expr)
            match(:print)
            match(:bool_logic)
            #match(:function) 
            #match(:function_call) 
            #match(:return) 
            #match(:while_loop)
            #match(:break) 
            match(:if_block) 
            match(:assign) 
            end

        rule :assign do
            match(:id, "=", :expr) { |variable, _, expr| Assign.new(variable, expr) }
            match(:id, "=", :bool_logic) { |variable, _, bool_exp| Assign.new(variable, bool_exp) }
            match(:id, "=", :string_expr) { |variable, _, str_exp| Assign.new(variable, str_exp) }
            match(:id, "=", :string_adding) { |variable, _, expr| Assign.new(variable, expr) }
            end

        rule :string_expr do
            match(/'[^\']*'/) { |string| str = Constant.new(string[1, string.length-2]) }
            match(/"[^\"]*"/) { |string| str = Constant.new(string[1, string.length-2]) }
            ##match(:function_call)
            end  

        rule :string_adding do
            match(:string_adding, "plus", :string_expr) { |str_add, _, str_exp| Expr.new("plus", str_add, str_exp) }
            match(:string_expr, "plus", :string_expr) { |str_exp1, _, str_exp2| Expr.new("plus", str_exp1, str_exp2) }
            end 
        
        rule :expr do
            match(:expr, '+', :term) { |expr, _, term| Expr.new('+', expr, term) }
            match(:expr, '-', :term) { |expr, _, term| Expr.new('-', expr, term) }
            ##match(:expr, '<', :expr) { |expr1, _, expr2| Condition.new('<', expr1, expr2) }
            match(:term) { |term| term }
            end

        rule :term do
            match(:term, '*', :atom) { |term, _, atom| Expr.new('*', term, atom) }
            match(:term, '/', :atom) { |term, _, atom| Expr.new('/', term, atom) }
            #match(:function_call)
            match(:atom) { |atom| atom }
            end
            
       rule :bool_logic do
            match(:bool_logic, 'and', :bool_logic) { |bool_exp1, _, bool_exp2| Condition.new('and', bool_exp1, bool_exp2) }
            match(:bool_logic, 'or', :bool_logic) { |bool_exp1, _, bool_exp2| Condition.new('or', bool_exp1, bool_exp2) }
            match('not', :bool_logic) { |_, bool_expr| Not.new('not', bool_expr) }
            match('true') { Constant.new(true) }
            match('false') { Constant.new(false) }
            match('(', :bool_logic, ')') { |_, expr, _| expr }
            ##match(:id) { |var| var }
            match(:bool_list)
            end 

        rule :bool_list do
            match(:less_than)
            match(:greater_than)
            match(:less_than_or_equal_to)
            match(:greater_than_or_equal_to)
            match(:not_equal_to)
            match(:equal)
        end

        rule :less_than do
            match(:expr, '<', :expr) { |expr1, _, expr2| Condition.new('<', expr1, expr2) }
            match(:expr, 'less', 'than', :expr) { |expr1, _, _, expr2| Condition.new('less than', expr1, expr2) }
        end

        rule :greater_than do
            match(:expr, '>', :expr) { |expr1, _, expr2| Condition.new('>', expr1, expr2) }
            match(:expr, 'greater', 'than', :expr) { |expr1, _, _, expr2| Condition.new('greater than', expr1, expr2) }
        end

        rule :less_than_or_equal_to do
            match(:expr, '<=', :expr) { |expr1, _, expr2| Condition.new('<=', expr1, expr2) }
            match(:expr, 'less', 'than', 'or', 'equal', 'to', :expr) { |expr1, _, _, _, _, _, expr2| Condition.new('less than or equal to', expr1, expr2) }
        end

        rule :greater_than_or_equal_to do
            match(:expr, '>=', :expr) { |expr1, _, expr2| Condition.new('>=', expr1, expr2) }
            match(:expr, 'greater', 'than', 'or', 'equal', 'to', :expr) { |expr1, _, _, _, _, _, expr2| Condition.new('greater than or equal to', expr1, expr2) }
        end

        rule :not_equal_to do
            match(:expr, '!=', :expr) { |expr1, _, expr2| Condition.new('!=', expr1, expr2) }
            match(:expr, 'not', 'equal', 'to', :expr) { |expr1, _, _, _, expr2| Condition.new('not equal to', expr1, expr2) }
        end

        rule :equal do
            match(:expr, '==', :expr) { |expr1, _, expr2| Condition.new('==', expr1, expr2) }
            match(:expr, 'equal', :expr) { |expr1, _, expr2| Condition.new('equal', expr1, expr2) }
        end

        rule :id do
            match(/[a-z]+[a-z0-9_]*/) { |variable_name| Variable.new(variable_name) }
            end

        rule :if_block do
            match("if", "(", :bool_logic, ")", "then", :statements, "endif") { |_, _, bool_exp, _, _, if_states, _| If.new(bool_exp, if_states) }
            match("if", "(", :bool_logic, ")", "then", :statements, "otherwise", :statements, "endif") { |_, _, bool_exp, _, _, if_states, _, else_states, _| 
                If.new(bool_exp, if_states, else_states) }
            match("if", "(", :bool_logic, ")", "then", :statements, "elseif", "(", :bool_logic, ")", "then", :statements, "otherwise", :statements, "endif") { |_, _, bool_exp_if, _, _, if_states, _, _, bool_exp_elseif, _, _, elseif_states, _, else_states, _| 
                If.new(bool_exp_if, if_states, bool_exp_elseif, elseif_states, else_states) }
            end    

        rule :print do
            match("write", :string_expr) { |_, str_exp| Print.new(str_exp) }
            match("write", :expr) { |_, exp| Print.new(exp) } 
            match("write", :bool_logic) { |_, bool_log| Print.new(bool_log) } 
            match("write", :id) { |_, id| Print.new(id) }
            match("write", :string_adding) { |_, str_add| Print.new(str_add) }
            end

        rule :atom do
            match(Float) { |float_num| Constant.new(float_num) }
            match(Integer) { |int_num| Constant.new(int_num) }
            match("-", Float) { |a, b| Constant.new(b, a) }
            match("-", Integer) { |a, b| Constant.new(b, a) }
            #match(:id) { |id| id }
            match('(',:expr,')') { |_,expr,_| Expression_node.new(expr) }
            ##match(:function_call)
            end
            
        end #end för alla rules
    #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- END BNF +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    end #end för initialize  
      
    def done(str)
        ["quit", "exit", "bye", "close", "stop"].include?(str.chomp)
    end

    #För att starta programmet i terminalen
    def activate_terminal
        print "[ETL] "
        str = gets
        if done(str) then
            puts "Bye."
        else
            parsePrinter = @etlParser.parse str
            puts "=> #{parsePrinter.eval}"
            activate_terminal
        end
    end

    #För att testa från en fil
    def activate_file(etl_file)
        @result = Array.new()
        etl_file = File.read(etl_file)
        @result = @etlParser.parse(etl_file)
        puts "=> #{result.eval}"
        @result
    end

    def for_test(string)
        return @etlParser.parse string
    end
    
    def log(state = true)
        if state
          @etlParser.logger.level = Logger::DEBUG
        else
          @etlParser.logger.level = Logger::WARN
        end
    end

end #end för klassen

test = Etl.new

test.activate_file("etl.etl")

#test.log(false)
#test.activate_terminal


=begin 
Ex 1. 

a = 12
b = 4

if a > b
puts "a is bigger than b" 

Ex 2.
a = 12
b = 4

if a greater than b
puts "a is bigger than b" 

=end