module Polly::Calculation

  def var(name, val = nil, opts = {}, &block)
    var_accessor Symbolic::Variable.new({ name: name, value: val }, block)
  end

  alias_method :const, :var
  alias_method :eq, :var

private

  def var_accessor(variable)
    instance_variable_set("@#{variable.name}", variable.value)
    meta_eval { attr_accessor variable.name }
  end

end
