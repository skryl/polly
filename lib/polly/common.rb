module Polly::Common
  include Polly

  BINARY_OPS = [:*, :/, :%, :+, :-]
  UNARY_OPS = [:-]
  UNDEFINED = [:nil]

private

  def valid_expr?(expr)
    (expr.is_a? Sexpr) || (expr.is_a? Numeric) || (expr.is_a? Symbol)
  end

end


