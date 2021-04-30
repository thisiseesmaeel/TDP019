##Alla tokens, rules och match

require './rdparse.rb'
require './classes.rb'

class Etl
    attr_accessor :output
    def initialize
        @etlParser = Parser.new("ETL") do
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
        token(/\<comment[^!]*\<end/) #matcha inte flerarads kommentarer
        token(/(<<.+$)/) #matcha inte en rad kommentar
        token(/\s+/)  #mellanrum ska inte matchas
        token(/(\d+[.]\d+)/) { |m| m.to_f } #floattal
        token(/\d+/) { |m| m.to_i } #heltal
        token(/'[^\']*'/) { |m| m } #sträng inom enkeltcitattecken (' ')
        token(/"[^\"]*"/) { |m| m } #sträng inom dubbeltcitattecken (" ")
        token(/[a-z]+[a-z0-9_]*/) { |m| m } #namn på variabler
        token(/./) { |m| m } #allt annat(enkla käraktarer)
      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- END TOKENS +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

      #+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+- BEGIN BNF +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ 

        start :program do
            match(:statements)
            end
 
        rule :statements do
            match(:statements,:statement){|states, state| [states, state].flatten}
            match(:statement)
        end 

        rule :statement do
            match(:return)
            match(:func) 
            match(:funcCall)
            match(:stop) 
            match(:print)
            ##match(:bool_logic)
            match(:if_box) 
            match(:whileIteration)
            match(:assign)
            ##match(:multiple_strings)
            ##match(:string_expr)
            ##match(:expr)
            end

        rule :assign do
            match(:id, "=", :bool_logic) { |variable_name, _, bool_log| Assign.new(variable_name, bool_log) }
            match(:id, "=", :multiple_strings) { |variable_name, _, mult_str| Assign.new(variable_name, mult_str) }
            match(:id, "=", :string_expr) { |variable_name, _, str_exp| Assign.new(variable_name, str_exp) }
            match(:id, "=", :expr) { |variable_name, _, expr| Assign.new(variable_name, expr) }
            end

        rule :string_expr do
            match(/'[^\']*'/) { |string| str = Constant.new(string[1, string.length-2]) }
            match(/"[^\"]*"/) { |string| str = Constant.new(string[1, string.length-2]) }
            #match(:funcCall)
            end  

        rule :multiple_strings do
            match(:string_expr, "plus", :string_expr) { |str_exp1, _, str_exp2| Plus_str.new("plus", str_exp1, str_exp2) }
            match(:id, "plus", :string_expr) { |id, _, str_exp| Plus_str.new("plus", id, str_exp) }
            match(:string_expr, "plus", :id) { |str_exp, _, id| Plus_str.new("plus", str_exp, id) }
            match(:multiple_strings, "plus", :string_expr) { |mult_str, _, str_exp| Plus_str.new("plus", mult_str, str_exp) }
            match(:id, "plus", :id) { |id1, _, id2| Plus_str.new("plus", id1, id2) }
            end 
        
        rule :expr do
            match(:expr, '+', :term) { |expr, _, term| Expr.new('+', expr, term) }
            match(:expr, '-', :term) { |expr, _, term| Expr.new('-', expr, term) }
            match(:term)
            end

        rule :term do
            match(:term, '*', :atom) { |term, _, atom| Expr.new('*', term, atom) }
            match(:term, '/', :atom) { |term, _, atom| Expr.new('/', term, atom) }
            #match(:funcCall)
            match(:atom)
            end
            
       rule :bool_logic do
            match(:bool_logic, 'and', :bool_logic) { |lhs, _, rhs| Condition.new('and', lhs, rhs) }
            match(:bool_logic, 'or', :bool_logic) { |lhs, _, rhs| Condition.new('or', lhs, rhs) }
            match('not', :bool_logic) { |_, oper| Not.new('not', oper) }
            match('true') { Constant.new(true) }
            match('false') { Constant.new(false) }
            match('(', :bool_logic, ')') { |_, bool_log, _| bool_log }
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
            match(:expr, '<', '=', :expr) { |expr1, _, _, expr2| Condition.new('<=', expr1, expr2) }
            match(:expr, 'less', 'than', 'or', 'equal', 'to', :expr) { |expr1, _, _, _, _, _, expr2| Condition.new('less than or equal to', expr1, expr2) }
        end

        rule :greater_than_or_equal_to do
            match(:expr, '>', '=', :expr) { |expr1, _, _, expr2| Condition.new('>=', expr1, expr2) }
            match(:expr, 'greater', 'than', 'or', 'equal', 'to', :expr) { |expr1, _, _, _, _, _, expr2| Condition.new('greater than or equal to', expr1, expr2) }
        end

        rule :not_equal_to do
            match(:expr, '!', '=', :expr) { |expr1,_, _, expr2| Condition.new('!=', expr1, expr2) }
            match(:expr, 'not', 'equal', 'to', :expr) { |expr1, _, _, _, expr2| Condition.new('not equal to', expr1, expr2) }
        end

        rule :equal do
            match(:expr, '=', '=', :expr) { |expr1,_, _, expr2| Condition.new('==', expr1, expr2) }
            match(:expr, 'equal', :expr) { |expr1, _, expr2| Condition.new('equal', expr1, expr2) }
        end

        rule :id do
            match(/[a-z]+[a-z0-9_]*/) { |id| Variable.new(id) }
            end

        rule :func do
            match("define", /[a-z]+[a-z0-9_]*/, "(", :arguments, ")", :statements, "enddef") { |_, def_name, _, args, _, states, _| 
                Function.new(def_name, args, states) }
            match("define", /[a-z]+[a-z0-9_]*/, "(", ")", :statements, "enddef") { |_, def_name, _, _, states, _| Function.new(def_name, Array.new, states) }
            end

        rule :funcCall do
            match(:id, "(", ")") { |def_name, _, _| FunctionCall.new(def_name, Array.new) }
            match(:id, "(", :arguments, ")") { |def_name, _, args, _| FunctionCall.new(def_name, args) }
            end 

        rule :return do
            match("return", :argument) { |_, arg| Return.new(arg) }
            end

        rule :arguments do
            match(:arguments,',',:argument){|args,_,arg| [args, arg].flatten}
            match(:argument)
            end  

        rule :argument do
            match(:multiple_strings)
            match(:string_expr)
            match(:expr)
            match(:bool_logic)
            end  

        rule :whileIteration do
            match("while", "(", :bool_logic, ")", :statements, "endwhile") { |_, _, bool_log, _, states, _| While.new(bool_log, states) }    
            end

        rule :stop do
            match("stop") { |_| Stop.new() }
            end
    
        rule :if_box do
            match("if", "(", :bool_logic, ")", "then", :statements, "endif") { |_, _, bool_log, _, _, if_states, _| If.new(bool_log, if_states) }
            match("if", "(", :bool_logic, ")", "then", :statements, "otherwise", :statements, "endif") { |_, _, bool_log, _, _, if_states, _, else_states, _| 
                If.new(bool_log, if_states, else_states) }
            end    

        rule :print do
            match("write", :multiple_strings) { |_, mult_str| Print.new(mult_str) }
            match("write", :string_expr) { |_, str_exp| Print.new(str_exp) }
            match("write", :bool_logic) { |_, bool_log| Print.new(bool_log) } 
            match("write", :expr) { |_, exp| Print.new(exp) } 
            end

        rule :atom do
            match(:funcCall)
            match(Float) { |float_num| Constant.new(float_num) }
            match(Integer) { |int_num| Constant.new(int_num) }
            match("-", Float) { |a, b| Constant.new(b, a) }
            match("-", Integer) { |a, b| Constant.new(b, a) }
            match('(', :expr, ')') { |_,exp,_| Expression.new(exp) }
            match(:id)
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
        @output = []
        etl_file = File.read(etl_file)
        @output = @etlParser.parse(etl_file)
        ##puts "=> #{output.eval}"
        @output
    end

    #def for_test(string)
    #    return @etlParser.parse string
    #end
    
    def log(state = true)
        if state
          @etlParser.logger.level = Logger::DEBUG
        else
          @etlParser.logger.level = Logger::WARN
        end
    end

end #end för klassen

checkEtl = Etl.new
checkEtl.log(false)
#checkEtl.activate_terminal
checkEtl.activate_file("etl.etl")
checkEtl.output.each { |segment|
	if segment.class != Function and segment.class != FunctionCall
		 segment.eval()
    end }
  
