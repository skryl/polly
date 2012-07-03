require 'spec_helper'

describe Polly::Context do

  let(:env_class) { Polly::Env}
  let(:sexpr_class) { Polly::Sexpr}
  let(:context_class) { Polly::Context }

  before :each do
    @c = context_class.new(env_class.new)
    @c.instance_eval do
      name :my_context
      version 1

      var :a
      const :b, 2
      const :c, 3

      eq :calc, c * (a + b)
      eq :complex, min(10, 15, max(1,2,3), a, b, c)
    end
  end

  it 'should define aliases for specifying variables' do
    [:const, :var, :eq].all? { |m| @c.should respond_to(m) }
  end

  it 'should define a variable as an s-expression' do
    [:d, :e, :f].all? { |m| @c.should_not respond_to(m) }
    [:a, :b, :c, :calc, :complex].all? { |m| @c.should respond_to(m) }
    [:a, :b, :c, :calc, :complex].all? { |m| @c.send(m).should be_a(sexpr_class) }
    @c.a.should == :nil
    @c.b.should == 2
    @c.c.should == 3
    @c.calc.should == nil
  end

  it 'should re-define a variable' do
    @c.var(:a, 1)
    @c.var(:calc, 2)
    @c.a.should == 1
    @c.calc.should == 2
  end

  it 'should respond to any unknown method by converting it to an s-expression' do
    @c.foo.should be_a(sexpr_class)
    @c.bar.should be_a(sexpr_class)
  end

  it 'should cast a literal to an s-expression' do
    @c.instance_eval { Sexpr(5) }.should be_a(sexpr_class)
    @c.instance_eval { 5.to_sexpr }.should be_a(sexpr_class)
  end

end
