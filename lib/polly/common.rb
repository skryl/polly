module Polly::Common
  include Polly

  BINARY_OPS = [:*, :/, :%, :+, :-, :**, :<<, :>>, :&, :|, :^, :>, :>=, :<, :<=, :<=>, :==, :===, :=~ ]
  UNARY_OPS = [:-, :+, :!, :~]
  UNDEFINED = [:nil]

  ATOMIC_TYPES = [Numeric, Symbol, String, TrueClass, FalseClass]

private

  def valid_expr?(expr)
    expr.is_a?(Sexpr) || valid_type?(expr)
  end

  def valid_type?(val)
    ATOMIC_TYPES.any? { |t| val.is_a?(t) } 
  end

end
