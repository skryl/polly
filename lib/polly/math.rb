module Polly::Math

class << self

  def min(*args)
    args.min
  end

  def max(*args)
    args.max
  end

  def ceil(val, ceil)
    (val.to_f / ceil.to_i).to_i * ceil.to_i 
  end

  def pv(i, length, pmt)
     pmt / i * (1 - (1 + i) ** -length)
  end

  # Some binary operators are not methods but part of Ruby's syntax. Since
  # there is no way to latch on to them, they'll have to be redefined.
  
  def br(test, exp1, exp2)
    test ? exp1 : exp2
  end

  def and(val1, val2)
    val1 && val2
  end

  def or(val1, val2)
    val1 || val2
  end

  def not(val)
    !val
  end
  alias_method :!, :not

  def not_eq(val1, val2)
    !(val1 == val2)
  end
  alias_method :!=, :not_eq

  # NOOP
  def self(obj)
    obj
  end

end

end
