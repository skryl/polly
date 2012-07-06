require 'spec_helper'

describe Polly::Sexpr do
  
  let(:env_class) { Polly::Env }
  let(:sexpr_class) { Polly::Sexpr }

  before :each do
    @env = env_class.new

    @s = []
    @s[0] = sexpr_class.build(nil, name: 'a')
    @s[1] = sexpr_class.build(0)
    @s[2] = sexpr_class.build(:a)
    @s[3] = sexpr_class.build('a')
    @s[4] = sexpr_class.build(true)
    @s[5] = sexpr_class.build(false)
    @s[6] = sexpr_class.build([:+, 1, 2])
    @s[7] = sexpr_class.build([:*, [:+, 1, 2], 3])
    @s[8] = sexpr_class.build([:*, [:+, 1, 2], @s[0]])
  end

  it 'should recursively build an s-expression from a supported native type' do
    @s.all? { |s| s.should be_a(sexpr_class) }
  end

  it 'should save the s-expressions name if provided' do
    @s[0].name.should == 'a'
  end

  it 'should determine the operation and arguments of any s-expression' do
    @s[0].op.should == :nil 
    @s[0].args.should be_empty
    @s[6].op.should == :+
    @s[6].args.should == [1,2]
    @s[7].op.should == :*
    @s[7].args.should == [@s[6], 3]
    @s[8].op.should == :*
    @s[8].args.should == [@s[6], @s[0]]
  end

  it 'should compare an s-expression to another s-expression, an array, or a value' do
    sexpr = [:*, [:+, 1, 2], 3]
    @s[7].should == sexpr_class.build(sexpr, @env)
    @s[7].should == sexpr
    @s[7].should == 9
  end

  it 'should evaluate a valid s-expression' do
    @s[0].should == nil
    @s[1].should == 0
    @s[2].should == :a
    @s[3].should == 'a'
    @s[4].should == true
    @s[5].should == false
    @s[6].should == 3
    @s[7].should == 9
    @s[8].should == nil
  end

  it 'should replace an s-expression value in place' do
    old_oid = @s[0].object_id
    @s[0].replace(1)
    @s[0].should == 1
    @s[0].object_id.should == old_oid
  end

  it 'should be able to tell if an s-expression is atomic' do
    @s.values_at(0,1,2,3,4,5).all? { |s| s.atomic?.should be_true }
    @s.values_at(6,7,8).all? { |s| s.atomic?.should be_false }
  end

  it 'should be able to tell if an s-expression is defined' do
    @s.values_at(1,2,3,4,5,6,7).all? { |s| s.defined?.should be_true }
    @s.values_at(0,8).all? { |s| s.defined?.should be_false }
    @s.values_at(0,8).all? { |s| s.undefined?.should be_true}
    @s[0].undefined_variables.should == ['a']
    @s[8].undefined_variables.should == ['a']
  end

  it 'should mark a modified s-expression as dirty' do
    @s[0].replace(1)
    @s[0].should be_dirty
    @s[8].should be_dirty
    @s[7].should be_clean
    @s[7].should_not be_dirty
    @s[0].dirty_variables.should == ['a']
    @s[8].dirty_variables.should == ['a']
  end

  it 'should convert all method calls to an s-expression' do
    (@s[1] + 5).should be_a(sexpr_class)
    @s[1].foo.should be_a(sexpr_class)
    @s[1].bar(1,2).should be_a(sexpr_class)

    (@s[1] + 5).should == [:+, 0, 5]
    @s[1].foo.should == [:foo, 0]
    @s[1].bar(1,2).should == [:bar, 0, 1, 2]
    @s[1].foo.bar(1,2).should == [:bar, [:foo, 0],  1, 2]
  end

end

