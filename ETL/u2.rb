#!/usr/bin/env ruby
require './rdparse.rb'

class LogicLang

    def initialize
        @logicParser = Parser.new("Logic Lang") do
        token(/\s+/)
        token(/\w+/) { |m| m }
        token(/./) { |m| m }
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
        ["quit", "exit", "bye", "close", "stop", ""].include?(str.chomp)
    end

    def activate
        print "[logicLang] "
        str = gets
        if done(str) then
            puts "Bye."
        else
            puts "=> #{@logicParser.parse str}"
            activate
        end
    end

    def for_test(string)
        return @logicParser.parse string
    end

    def log(state = true)
        if state
          @logicParser.logger.level = Logger::DEBUG
        else
          @logicParser.logger.level = Logger::WARN
        end
    end

end

#LogicLang.new.activate