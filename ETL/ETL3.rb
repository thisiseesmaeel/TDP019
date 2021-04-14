##Alla tokens, rules och match

require './rdparse.rb'
require './classes.rb'

class Etl
    attr_accessor :result
    def initialize
        @etlParser = Parser.new("ETL") do
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        token(/\s+/)  #mellanrum ska inte matchas
        token(/'[^\']*'/) { |m| m } #sträng inom enkelt citattecken (' ')
        token(/"[^\"]*"/) { |m| m } #sträng inom dubbelt citattecken (" ")
        token(/[a-z]+[a-z0-9_]*/) { |m| m } #variabler name
        token(/(\+|\-|\*|\/|!=|\.|%|&|\(|\)|\[|\]|\:|;|<=|!|>=|<|>|==|=|\,|<<,>>)/) {|m| m}
        token(/./) { |m| m } #allt annat(enkla käraktarer)
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- END TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        

      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN BNF +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 

        start :string_expr do
            #match(/'[^\']*'/) { |str| string = Atom.new(str.slice(1, str.length-2)) }
            #match(/"[^\"]*"/) { |str| string = Atom.new(str.slice(1, str.length-2)) }
            match(/'[^\']*'/) { |str| string = Atom.new(str[1, str.length-2]) }
            match(/"[^\"]*"/) { |str| string = Atom.new(str[1, str.length-2]) }
            match(:id) { |var| var }
            ##match(:function_call)
            end 

        rule :assign do
            ##match(:id, '=', :expr) { |variable, _, expr| Assign.new(variable, expr) }
            ##match(:id, "=", :bool_expr) { |variable, _, bool_exp| Assign.new(variable, bool_exp) }
            match(:id, "=", :string_expr) { |var, _, str_exp| Assign.new(var, str_exp) }
            ##match(:id, "=", :string_adding) { |variable, _, expr| Assign.new(variable, str_add) }
            end

        rule :atom do
            ##match(Float) { |float_num| Number.new(float_num) }
            ##match(Integer) { |int_num| Number.new(int_num) }
            match(:id) { |var| var }
            ##match('(',:expr,')') { |_,expr,_| Expression_node.new(expr) }
            ##match(:function_call)
            end

        rule :id do
            match(/[a-z]+[a-z0-9_]*/) { |name| Variable.new(name) }
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