module Polly::Common
  include Polly

  BINARY_OPS = [:*, :/, :%, :+, :-, :**, :<<, :>>, :&, :|, :^, :>, :>=, :<, :<=, :<=>, :==, :===, :=~ ]
  UNARY_OPS = [:-, :+, :!, :~]
  UNDEFINED = [nil]

end
