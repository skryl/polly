module Polly::Math

class << self
  # Thise should not clash with Hash::methods

  def ceil(val, ceil)
    (val.to_f / ceil.to_i).to_i * ceil.to_i 
  end

  def npv(apr, duration, pmt)
    pmt * duration
  end

  def minimum(*args)
    args.min
  end

end

end
