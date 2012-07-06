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

        # eq can nest other equations or vars
        eq :eq1, (e * f + g) / 3.0 - f + -e
        eq :eq2, br(h.length > 4, eq1.to_i, e)
        eq :eq3, max(ceil(npv(a.round(1), c, eq2), 50), e)

        eq :final, 100.to_sexpr + Sexpr(1000) + eq3
      end

    @calc.h = "str"
    @calc.e = 3000
    @calc.f = 2
    @calc.g = 10000
  end

  it 'should perform a complex calculation' do
    @calc.final.should == 18500
  end

  it 'should perform a complex calculation' do
    @calc.h = "string"
    @calc.final.should == 14600
  end

  it 'should perform a complex calculation' do
    @calc.e = 20000
    @calc.final.should == 117300
  end

end
