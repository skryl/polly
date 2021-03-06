require 'spec_helper'


describe Polly::Math do
  let(:math_class) { Polly::Math }

  describe 'mathematical functions' do

    it 'should perform a min function' do
      nums = [34, 893, 12, 1234, 17]
      math_class.min(0).should == 0
      math_class.min(15,10).should == 10
      math_class.min(*nums).should == 12
    end

    it 'should perform a max function' do
      nums = [34, 893, 12, 1234, 17]
      math_class.max(0).should == 0
      math_class.max(15,10).should == 15
      math_class.max(*nums).should == 1234
    end

    it 'should perform a ceiling function' do
      math_class.ceil(153,10).should == 150
      math_class.ceil(153,20).should == 140
      math_class.ceil(153,30).should == 150
      math_class.ceil(153,40).should == 120
      math_class.ceil(153,50).should == 150
      math_class.ceil(153,100).should == 100
    end

    it 'should perform a net present value function' do
      math_class.pv(0.100, 12, 50).round(2).should == 340.68
      math_class.pv(0.100, 12, 75).round(2).should == 511.03
      math_class.pv(0.100, 12, 100).round(2).should == 681.37

      math_class.pv(0.150, 1, 100).round(2).should == 86.96
      math_class.pv(0.150, 6, 100).round(2).should == 378.45
      math_class.pv(0.150, 12, 100).round(2).should == 542.06

      math_class.pv(0.200, 12, 100).round(2).should == 443.92
      math_class.pv(0.300, 12, 100).round(2).should == 319.03
      math_class.pv(0.400, 12, 100).round(2).should == 245.59
    end

  end

  describe 'ruby replacement functions' do

    it 'should perform a branch function' do
      math_class.br(true, 0, 1).should == 0
      math_class.br(false, 0, 1).should == 1
    end

    it 'should perform an and function' do
      math_class.and(true, true).should == true
      math_class.and(true, false).should == false
      math_class.and(false, true).should == false
      math_class.and(false, false).should == false
    end

    it 'should perform an or function' do
      math_class.or(true, true).should == true
      math_class.or(true, false).should == true
      math_class.or(false, true).should == true
      math_class.or(false, false).should == false
    end

    it 'should perform a not function' do
      math_class.not(true).should == false
      math_class.not(false).should == true

      math_class.!(true).should == false
      math_class.!(false).should == true
    end

    it 'should perform a not equal function' do
      math_class.not_eq(true, true).should == false
      math_class.not_eq(true, false).should == true

      math_class.!=(true, true).should == false
      math_class.!=(true, false).should == true
    end

  end

end
