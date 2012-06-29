class Polly::Context < Hash
  include Polly::Common

  def version(v)
    @version = v
  end

  def var(name, val = nil, opts = {})
    if self[name]  
      self[name].replace(val) 
    else
      self[name] = Sexpr.build(val, self, name: name)
    end
    var_reader name
  end

  alias_method :const, :var
  alias_method :eq, :var

  def method_missing(method, *args, &block)
    if !args.empty? && args.all? { |a| valid_expr?(a) }
      Sexpr.build([method, *args], self)
    else
     super
    end
  end

  def print(opts = {})
    vals = \
      self.map do |(k,v)|
        "#{k.inspect} => #{v.print(opts)}"
      end.join("\n")
    "{ #{vals} }"
  end

private

  def var_reader(name)
    instance_variable_set("@#{name}", self[name])
    meta_eval { attr_reader name }
  end

end
