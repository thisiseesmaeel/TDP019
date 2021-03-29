##Den ska innehålla rules och match

require './rdparse.rb'
require './classes.rb'

class Etl

    def initialize
        @etlParser = Parser.new("ETL") do
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        token(/\s+/)  #mellanrum ska inte matchas
        token(/-?\d+/) { |m| m.to_i } #positiv/negativ heltal
        token(/'[^\']*'/) { |m| m } #sträng inom enkelt citattecken (' ')
        token(/"[^\"]*"/) { |m| m } #sträng inom dubbelt citattecken (" ")
        #token(/(<|>|==|=|!=|<=|>=|\(|\)|\+|\-|\*|\/|\.|\,)/)
        token(/[a-z]+[a-z0-9_]*/) { |m| m } #variabler name
        token(/./) { |m| m } #allt annat(enkla käraktarer)
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- END TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        @our_var = Hash.new
        

        start :valid do
            match(:assign)
            match(:expr)
            end

        rule :assign do
            match('(', 'set', :var, :expr, ')') { |_, _, var_a, exp_b, _| @our_var[var_a] = exp_b}
            end
 

        rule :expr do
            match('(', 'or', :expr, :expr, ')') { |_, _, expr_a, expr_b, _| expr_a || expr_b }
            match('(', 'and', :expr, :expr, ')') { |_, _, expr_a, expr_b, _| expr_a && expr_b }
            match('(', 'not', :expr, ')') { |_, _, expr_a, _| (!expr_a) }
            match(:term)
            end

        rule :term do
            match('true') {|term| true}
            match('false') {|term| false}
            match(:var) {|var_a| @our_var[var_a]}
            end

        rule :var do
            match(String) 
            end
        end
    end

    def done(str)
        ["quit", "exit", "bye", "close", "stop"].include?(str.chomp)
    end

    def activate
        print "[ETL] "
        str = gets
        if done(str) then
            puts "Bye."
        else
            puts "=> #{@etlParser.parse str}"
            activate
        end
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

end

#LogicLang.new.activate