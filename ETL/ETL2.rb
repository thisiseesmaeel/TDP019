##Alla tokens, rules och match

require './rdparse.rb'
require './classes.rb'

class Etl
    attr_accessor :result
    def initialize
        @etlParser = Parser.new("ETL") do
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        token(/\s+/)  #mellanrum ska inte matchas
        token(/(-?\d+[.]\d+)/) { |m| m.to_f } # positiv/negativ floattal
        token(/-?\d+/) { |m| m.to_i } #positiv/negativ heltal
        token(/'[^\']*'/) { |m| m } #sträng inom enkelt citattecken (' ')
        token(/"[^\"]*"/) { |m| m } #sträng inom dubbelt citattecken (" ")
        token(/[a-z]+[a-z0-9_]*/) { |m| m } #variabler name
        token(/./) { |m| m } #allt annat(enkla käraktarer)
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- END TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        

      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN BNF +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 

        start :expr do
            match(:expr, '+', :term) { |expr, _, term| Addition.new(expr, term) }
            match(:expr, '-', :term) { |expr, _, term| Subtraction.new(expr, term) }
            match(:term) 
            end

        rule :term do
            match(:term, '*', :atom) { |term, _, atom| Multiplication.new(term, atom) }
            match(:term, '/', :atom) { |term, _, atom| Division.new(term, atom) }
            #match(:function_call)
            match(:atom)
            end


        rule :string_expr do
            #match(/'[^\']*'/) { |string| str = Atom.new(string.slice(1, string.length-2)) }
            #match(/"[^\"]*"/) { |string| str = Atom.new(string.slice(1, string.length-2)) }
            ##match(/'[^\']*'/) { |string| str = Atom.new(string[1, string.length-2]) }
            ##match(/"[^\"]*"/) { |string| str = Atom.new(string[1, string.length-2]) }
            match(:id)
            ##match(:function_call)
            end 

        rule :assign do
            match(:id, '=', :expr) { |variable, _, expr| Assign.new(variable, expr) }
            ##match(:id, "=", :bool_expr) { |variable, _, bool_exp| Assign.new(variable, bool_exp) }
            ##match(:id, "=", :string_expr) { |variable, _, str_exp| Assign.new(variable, str_exp) }
            ##match(:id, "=", :string_adding) { |variable, _, expr| Assign.new(variable, str_add) }
            end

        

        rule :atom do
            match(Float) { |float_num| Int_Float.new(float_num) }
            match(Integer) { |int_num| Int_Float.new(int_num) }
            match(:id) 
            match('(',:expr,')') { |_,expr,_| Expr.new(expr) }
            ##match(:function_call)
            end

        rule :id do
            match(/[a-z]+[a-z0-9_]*/) { |variable_name| Variable.new(variable_name) }
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
    
    def log(state = true)
        if state
          @etlParser.logger.level = Logger::DEBUG
        else
          @etlParser.logger.level = Logger::WARN
        end
    end

end #end för klassen

test = Etl.new

#test.activate_file("etl.etl")

#test.log(false)
test.activate_terminal


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