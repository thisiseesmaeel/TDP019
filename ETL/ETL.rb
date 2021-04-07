##Alla tokens, rules och match

require './rdparse.rb'
require './classes.rb'

class Etl
    attr_accessor :result
    def initialize
        @etlParser = Parser.new("ETL") do
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        ##token(/\s+/)  #mellanrum ska inte matchas
        ##token(/(-?\d+[.]\d+)/) # positiv/negativ floattal
        ##token(/-?\d+/) { |m| m.to_i } #positiv/negativ heltal
        ##token(/'[^\']*'/) { |m| m } #sträng inom enkelt citattecken (' ')
        ##token(/"[^\"]*"/) { |m| m } #sträng inom dubbelt citattecken (" ")
        #token(/(<|>|==|=|!=|<=|>=|\(|\)|\+|\-|\*|\/|\.|\,)/)
        ##token(/[a-z]+[a-z0-9_]*/) { |m| m } #variabler name
        ##token(/./) { |m| m } #allt annat(enkla käraktarer)
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- END TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        

      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN BNF +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 
        start :program do
            match("startprogram", :statements, "endprogram") { |_, states, _| states }
            end

        #HJÄLP
        rule :statements do
            match(:statements, :statement) { |states, state| 
            states << state
            states }
            match(:statement) { |state| state }
            end 

        rule :statement do
            match(:print)
            match(:function) 
            match(:function_call) 
            match(:return) 
            match(:while_loop)
            match(:break) 
            match(:if_block) 
            match(:assign) 
            end

        rule :print do
            match("write", :string_expr) { |_, str_exp| Print.new(print) }
            match("write", :expr) { |_, exp| Print.new(print) } 
            match("write", :string_adding) { |_, str_add| Print.new(print) }
            end

=begin         rule :string_expr do
            #match(/'[^\']*'/) { |string| str = Atom.new(string.slice(1, string.length-2)) }
            #match(/"[^\"]*"/) { |string| str = Atom.new(string.slice(1, string.length-2)) }
            match(/'[^\']*'/) { |string| str = Atom.new(string[1, string.length-2]) }
            match(/"[^\"]*"/) { |string| str = Atom.new(string[1, string.length-2]) }
            match(:id)
            match(:function_call)
            end  
=end

=begin         rule :expr do
            match(:expr, "+", :term) { |expr, _, term| Expr.new("+", expr, term) }
            match(:expr, "-", :term) { |expr, _, term| Expr.new("-", expr, term) }
            match(:term) 
            end

        rule :term do
            match(:term, "*", :atom) { |term, _, atom| Expr.new("*", term, atom) }
            match(:term, "/", :atom) { |term, _, atom| Expr.new("/", term, atom) }
            #match(:function_call)
            match(:atom)
            end 
=end

        rule :string_adding do
            match(:string_adding, "plus", :string_expr) { |str_add, _, str_exp| Expr.new("plus", str_add, str_exp) }
            match(:string_expr, "plus", :string_expr) { |str_exp1, _, str_exp2| Expr.new("plus", str_exp1, str_exp2) }
            end
        
=begin         rule :id do
            match(/[a-z]+[a-z0-9_]*/) { |variable_name| Variable.new(variable_name) }
            end 
=end

        rule :function do
            match("define", :id, "(", :parameters, ")", :statements, "enddef") { |_, def_name, _, params, _, states, _| 
                Function.new(def_name, params, states) }
            match("define", :id, "()", :statements, "enddef") { |_, def_name, _, states, _| Function.new(def_name, states) }
            end

        rule :function_call do
            match(:id, "()") { |def_name, _| Function_call.new(def_name) }
            match(:id, "(", :parameters, ")") { |def_name, _, params, _| Function_call.new(def_name, params) }
            end

        rule :return do
            match("return", :expr) { |_, expr| Return.new(expr) }
            match("return", :string_expr) { |_, str_exp| Return.new(str_exp) }
            end

=begin  rule :parameters do
            match(:parameter) { |param| [param] }
            match(:parameters, ',', :parameter) { |params,_,param| params + [param] }
        end 
=end
        rule :parameters do
            match(:parameters, ",", :parameter) { |params, _, param|
            params << param
            params }
            match(:parameter)
            end
            
        rule :parameter do
            match(:expr)
            match(:string_expr)
            end

        rule :while_loop do
            match("while", "(", :bool_expr, ")", :statements, "endwhile") { |_, _, bool_exp, _, states, _| While.new(bool_exp, states) }    
            end

        rule :break do
            match("break") { |_| Break.new() }
            end

=begin         rule :bool_expr do
            match(:bool_expr, "and", :bool_expr) { |bool_exp1, _, bool_exp2| Expr.new("and", bool_exp1, bool_exp2) }
            match(:bool_expr, "or", :bool_expr) { |bool_exp1, _, bool_exp2| Expr.new("or", bool_exp1, bool_exp2) }
            match("not", :bool_expr) { |_, bool_expr| Expr.new("not", bool_expr) }
            match(:bool_word)
            match(:bool_symbol)
            end

        rule :bool_word do
            match(:expr, "less than", :expr) { |expr1, _, expr2| Expr.new("less than", expr1, expr2) }
            match(:expr, "greater than", :expr) { |expr1, _, expr2| Expr.new("greater than", expr1, expr2) }
            match(:expr, "less than or equal to", :expr) { |expr1, _, expr2| Expr.new("less than or equal to", expr1, expr2) }
            match(:expr, "greater than or equal to", :expr) { |expr1, _, expr2| Expr.new("greater than or equal to", expr1, expr2) }
            match(:expr, "not equal to", :expr) { |expr1, _, expr2| Expr.new("not equal to", expr1, expr2) }
            match(:expr, "equal", :expr) { |expr1, _, expr2| Expr.new("equal", expr1, expr2) }
            end

        rule :bool_sympol do
            match(:expr, "<", :expr) { |expr1, _, expr2| Expr.new("<", expr1, expr2) }
            match(:expr, ">", :expr) { |expr1, _, expr2| Expr.new(">", expr1, expr2) }
            match(:expr, "<=", :expr) { |expr1, _, expr2| Expr.new("<=", expr1, expr2) }
            match(:expr, ">=", :expr) { |expr1, _, expr2| Expr.new(">=", expr1, expr2) }
            match(:expr, "!=", :expr) { |expr1, _, expr2| Expr.new("!=", expr1, expr2) }
            match(:expr, "==", :expr) { |expr1, _, expr2| Expr.new("==", expr1, expr2) }
            end 
=end 

        rule :if_block do
            match("if", "(", :bool_expr, ")", "then", :statements, "endif") { |_, _, bool_exp, _, _, if_states, _| If.new(bool_exp, if_states) }
            match("if", "(", :bool_expr, ")", "then", :statements, "otherwise", :statements, "endif") { |_, _, bool_exp, _, _, if_states, _, else_states, _| 
                If.new(bool_exp, if_states, else_states) }
            match("if", "(", :bool_expr, ")", "then", :statements, "elseif", "(", :bool_expr, ")", "then", :statements, "otherwise", :statements, "endif") { |_, _, bool_exp_if, _, _, if_states, _, _, bool_exp_elseif, _, _, elseif_states, _, else_states, _| 
                If.new(bool_exp, if_states, bool_exp, elseif_states, else_states) }
            end    
                    
=begin         rule :assign do
            match(:id, "=", :expr) { |variable, _, expr| Assign.new(variable, expr) }
            match(:id, "=", :bool_expr) { |variable, _, bool_exp| Assign.new(variable, bool_exp) }
            match(:id, "=", :string_expr) { |variable, _, str_exp| Assign.new(variable, str_exp) }
            match(:id, "=", :string_adding) { |variable, _, expr| Assign.new(variable, str_add) }
            end

        rule :atom do
            match(Float) { |float_num| Atom.new(float_num.to_f) }
            match(Integer) { |int_num| Atom.new(int_num.to_i) }
            match(:id)
            match(:function_call)
            match('(',:expr,')') { |_,expr,_| Expr.new(expr) }
            end 
=end
        end #end för alla rules
    #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- END BNF +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    end #end för initialize  
      
=begin     def done(str)
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
    
    def log(state = true)
        if state
          @etlParser.logger.level = Logger::DEBUG
        else
          @etlParser.logger.level = Logger::WARN
        end
    end 
=end

end #end för klassen

test = Etl.new
test.activate_file("etl.etl")

#Etl.new.activate_terminal


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