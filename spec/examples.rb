require 'spec_helper'

describe Polly::Calculation do

  before :each do
    @calc = \
      Polly::Calculation.new do
        name :name
        version 1

        # constants
        const :a, 150.percent
        const :b, 5000
        const :c, 12
        const :d, 80.percent

        # inputs
        var :e
        var :f
        var :g
        var :h
        var :i, b
      end

      @calc.evaluate do
        # eq can nest other equations or vars
        eq :eq1, (e * f + g) / 3.0 - f + -e
        eq :eq2, br(h.length > 4, eq1.to_i, e)
        eq :eq3, max(ceil(pv(a.round(1), c, eq2), 50), e)
        eq :eq4, eq3

        eq :final, 100.to_sexpr + Sexpr(1000) + eq4 + b
      end

    @calc.h = "str"
    @calc.e = 3000
    @calc.f = 2
    @calc.g = 10000
  end

  it 'should perform a complex calculation' do
    @calc.final.should == 9100
  end

  it 'should perform a complex calculation' do
    @calc.h = "string"
    @calc.final.should == 9100
  end

  it 'should perform a complex calculation' do
    @calc.e = 20000
    @calc.final.should == 26100
  end

  it 'should convert the calculation to an array' do
    @calc.final.to_ary.should == \
      [:+, [:+, [:+, [100], [1000]], [:self, [:eq3]]], [:b]]
    @calc.final.to_ary(numeric: true).should == \
      [:+, [:+, [:+, [100], [1000]], [:self, [3000]]], [5000]]
    @calc.final.to_ary(expand: true).should == \
      [:+, [:+, [:+, [100], [1000]], [:self, [:max, [:ceil, [:pv, [:round, [:a], [1]], [:c], [:br, [:>, [:length, [:h]], [4]], [:to_i, [:+, [:-, [:/, [:+, [:*, [:e], [:f]], [:g]], [3.0]], [:f]], [:-@, [:e]]]], [:e]]], [50]], [:e]]]], [:b]]
    @calc.final.to_ary(numeric: true, expand: true).should == \
      [:+, [:+, [:+, [100], [1000]], [:self, [:max, [:ceil, [:pv, [:round, [1.5], [1]], [12], [:br, [:>, [:length, ["str"]], [4]], [:to_i, [:+, [:-, [:/, [:+, [:*, [3000], [2]], [10000]], [3.0]], [2]], [:-@, [3000]]]], [3000]]], [50]], [3000]]]], [5000]]
  end

  it 'should convert the calculation to a human readable string' do
    @calc.final.to_s.should == \
      "(((100 + 1000) + self(:eq3)) + :b)"
    @calc.final.to_s(numeric: true).should == \
      "(((100 + 1000) + self(3000)) + 5000)"
    @calc.final.to_s(expand: true).should == \
      "(((100 + 1000) + self(max(ceil(pv(round(:a, 1), :c, br((length(:h) > 4), to_i((((((:e * :f) + :g) / 3.0) - :f) + -@(:e))), :e)), 50), :e))) + :b)"
    @calc.final.to_s(numeric: true, expand: true).should == \
      "(((100 + 1000) + self(max(ceil(pv(round(1.5, 1), 12, br((length(\"str\") > 4), to_i((((((3000 * 2) + 10000) / 3.0) - 2) + -@(3000))), 3000)), 50), 3000))) + 5000)"
  end

end
