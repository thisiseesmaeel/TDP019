require './ETL2.rb'
require 'test/unit'

class TestEtl < Test::Unit::TestCase
  $p = Etl.new
  
  def test1
  assert_equal(true, $p.for_test("3 < 5"))
  end
  
end

=begin assert_equal(true, logicLang.for_test("(set a true)"))
assert_equal(true, logicLang.for_test("(or true true)"))
assert_not_equal(false, logicLang.for_test("(or true true)"))
assert_equal(false, logicLang.for_test("(and true false)"))
assert_equal(false, logicLang.for_test("(not true)"))
assert_equal(true, logicLang.for_test("true"))
assert_equal(false, logicLang.for_test("false"))
assert_not_equal(false, logicLang.for_test("true"))
end 
=end