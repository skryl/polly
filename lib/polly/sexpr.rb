class Polly::Sexpr
  include Polly::Common

  attr_reader :env, :name, :sexpr
  protected :sexpr

  def self.build(val, env, opts = {})
    return val if val.is_a?(Sexpr)

    val = \
      case val
      when Array
        val.map!.with_index do |arg, i| 
          (arg.is_a?(Sexpr) || i == 0) ? arg : Sexpr.build(arg, env)
        end
      when Symbol, Numeric
        Array(val)
      when NilClass
        UNDEFINED
      end

    Sexpr.new(val, env, opts)
  end

  def initialize(sexpr, env, opts = {})
    @name = opts[:name]
    @env = env
    @sexpr = sexpr
  end

  def op
    @sexpr[0]
  end

  def replace(val)
    @sexpr = self.class.build(val, self.env).sexpr
  end

  def value(opts = {})
    atomic? ? @sexpr.first : (self.defined? && self.send(:eval, opts))
  end

  def defined?
    if atomic?
      @sexpr != UNDEFINED
    else
      sexpr.cdr.all? { |s| s.defined? }
    end
  end

  def undefined_variables
    if atomic? && !self.defined?
      [@name]
    else
      sexpr.cdr.inject([]) { |a, s| a << s.undefined_variables }.flatten
    end
  end

  def atomic?
    @sexpr.size == 1 && ((@sexpr.first.is_a? Symbol) || (@sexpr.first.is_a? Numeric))
  end

  def inspect
    @sexpr.inspect
  end

  def print(opts = {})
    if atomic?
      (opts[:symbolic] ? (name || value) : value).inspect
    elsif BINARY_OPS.include?(op)
      "(#{@sexpr[1].print(opts)} #{sexpr[0]} #{sexpr[2].print(opts)})" 
    elsif UNARY_OPS.include?(op)
      "#{op}(#{@sexpr[1].print(opts)})" 
    else
      "#{op}(#{@sexpr.cdr.map { |a| a.print(opts) }.join(', ')})" 
    end
  end

  def method_missing(method, *args, &block)
    if !args.empty? && args.all? { |a| valid_expr?(a) }
      if BINARY_OPS.include?(method)
        Sexpr.build([method, self, *args], env)
      elsif UNARY_OPS.include?(method)
        Sexpr.build([method, self], env)
      else
        env.send(method, *args, &block)
      end
    else
     super
    end
  end

private

  # LISPY ;)

  def eval(opts = {})
    return(env[self.value] || self.value) if atomic?

    args = sexpr.cdr
    args = args.map { |a| a.send(:eval, opts) }
    apply(args, opts)
  end

  def apply(args, opts = {})
    result = \
      if @env[op].respond_to? :call
        @env[op].call(*args) 
      elsif BINARY_OPS.include?(op)
        args[0].send(op, args[1])
      elsif UNARY_OPS.include?(op)
        args.first.send(op)
      end

    puts " => #{op}(#{args.join(', ')}) = #{result}" if opts[:verbose]
    result
  end

end
