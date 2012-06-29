module Polly::Math

class << self
  # Method placed here should not clash with Hash::methods since Context inherits from Hash

  def br(test, exp1, exp2)
    test ? exp1 : exp2
  end

  def ceil(val, ceil)
    (val.to_f / ceil.to_i).to_i * ceil.to_i 
  end

  def npv(apr, duration, pmt)
     duration.times.inject { |sum, p| sum += pmt/(1 + (apr/12.0))**p }
  end

  def minimum(*args)
    args.min
  end

  # Some binary operators are not methods but part of Ruby's syntax. Since
  # there is no way to latch on to them, they'll have to be redefined.

  def and(val1, val2)
    val1 && val2
  end
  alias_method :'&&', :and

  def or(val1, val2)
    val1 || val2
  end
  alias_method :'||', :or

  def not(val)
    !val
  end
  alias_method :!, :not

  def not_equal(val1, val2)
    !(val1 == val2)
  end
  alias_method :!=, :not_equal

end

end
