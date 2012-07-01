require 'spec_helper'

describe Polly::Env do

  let(:math_class) { Polly::Math }
  let(:env_class) { Polly::Env }
  let(:sexpr_class) { Polly::Sexpr }

  before :each do
    @env = env_class.new
    @env[:foo] = sexpr_class.build(0)
    @env[:bar] = sexpr_class.build(:a)
    @env[:buz] = sexpr_class.build('a')
    @env[:him] = sexpr_class.build(true)
    @env[:her] = sexpr_class.build(false)
    @env[:it] = sexpr_class.build([:*,1,2])
    @env[:nil] = sexpr_class.build([:nil])
  end

  it 'should include all functions included in the Math module' do
    math_class.singleton_methods.all? { |m| @env[m] }.should == true
  end

  it 'should return only the s-expressions' do
    @env.clean.should be_a(env_class)
    @env.clean.size.should == 7
    @env.clean.all? { |k,v| [:foo, :bar, :buz, :him, :her, :it, :nil].include?(k) }.should == true
  end

  it 'should return only the atomic s-expressions' do
    @env.atomic_variables.size.should == 6
    @env.atomic_variables.all? { |k,v| [:foo, :bar, :buz, :him, :her, :nil].include?(k) }.should == true
  end

  it 'should return only atomic, defined s-expressions' do
    @env.defined_variables.size.should == 5
    @env.defined_variables.all? { |k,v| [:foo, :bar, :buz, :him, :her].include?(k) }.should == true
  end

  it 'should return the names of the atomic, undefined s-expressions' do
    @env.undefined_variables.size.should == 1
    @env.undefined_variables.should include(:nil)
  end

end
