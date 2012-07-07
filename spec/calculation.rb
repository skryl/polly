require 'spec_helper'

describe Polly::Calculation do

  let(:calc_class) { Polly::Calculation }

  before :each do
    @calc = calc_class.new do
      var :a, 1
      var :b, 2
      var :c, 3
    end
  end

  it 'should be able to toggle calculation options' do
    @calc.verbose_toggle
    calc_class.verbose.should be_true
    @calc.verbose_toggle
    calc_class.verbose.should be_false
  end

  it 'should eval the initialization block inside the context' do
    @calc.context.should_not respond_to(:d, :e, :f)
    @calc.context.should respond_to(:a, :b, :c)
  end

  it 'should get and set variables in the context' do
    @calc.a.should == 1
    @calc.a = 2
    @calc.a.should == 2
  end

  it 'should respond to delegated methods' do
    @calc.should respond_to(:atomic_variables)
    @calc.should respond_to(:defined_variables)
    @calc.should respond_to(:undefined_variables)
    @calc.should respond_to(:evaluate)
    @calc.should respond_to(:to_yaml)
  end

  it 'should initialize from a yaml dump' do
    dump = { foo: 1, bar: 2 }.to_yaml
    c = calc_class.from_yaml(dump)
    c.context.should respond_to(:foo, :bar)
    c.foo.should == 1
    c.bar.should == 2
  end

end
