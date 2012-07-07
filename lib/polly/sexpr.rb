class Polly::Sexpr
  include Polly::Common
  include Enumerable

  # instance accessors
  attr_reader :name, :op, :args, :sexpr
  protected :sexpr

  # class accessors
  meta_eval { protected :new }

  def self.build(val, opts = {})
    val = \
      case val
      when Sexpr
        val
      when Array
        sexpr = val.cdr.map { |arg| arg.is_a?(Sexpr) ? arg : Sexpr.build(arg, opts) }
        sexpr.unshift(val.first)
      when NilClass
        UNDEFINED
      else
        Array(val)
      end

    Sexpr.new(val, opts)
  end

  def initialize(sexpr, opts = {})
    @sexpr = (sexpr.is_a?(Sexpr) ? sexpr.sexpr : sexpr)
    @op = @sexpr[0]
    @args = @sexpr.cdr
    @name = opts[:name]
    @env = opts[:env] || Env.new
  end

  # use cached values unless some part of expression tree is dirty
  #
  def value(env = @env)
    @value = \
      (clean? && @value) || 
      (self.defined? ? (atomic? ? @sexpr.first : self.send(:eval)) : nil)
    @dirty = false
    @value
  end

  # force a recalc of all sub-expressions
  #
  def value!(env = @env) 
    each { |a| a.instance_variable_set("@dirty", true) }
    value(env)
  end

  def replace(val)
    @dirty = true
    @sexpr = self.class.build(val, env: @env).sexpr
  end

  def atomic?
    @sexpr.size == 1
  end

  def defined?; !undefined? end
  def undefined?; any? { |s| s.sexpr == UNDEFINED } end
  def undefined_variables; select { |s| s.atomic? && s.undefined? && s.name }.map(&:name) end

  def clean?; !dirty? end
  def dirty?; any? { |s| s.instance_variable_get("@dirty") } end
  def dirty_variables; select { |s| s.atomic? && s.dirty? && s.name }.map(&:name) end

  def ==(val)
    case val
    when Sexpr, Array
      @sexpr == val
    else
      self.value == val
    end
  end

  def each(&block)
    return to_enum unless block_given?

    yield self
    args.each { |s| s.each(&block) }
  end

# magix

  # convert any method call to an s-expression
  #
  def method_missing(method, *args, &block)
    Sexpr.build([method, self, *args], env: @env)
  end

# printing and conversion
  
  def print(opts = {}); puts to_s(opts) end
  def inspect(opts = {}); @sexpr.inspect end
  def to_s(opts = {}); _to_s(opts) end
  def to_ary(opts = {}); _to_ary(opts) end

protected

  def _to_s(opts = {}, depth = 0)
    evaled_args = args.map do |a| 
      if a.atomic? || (!opts[:expand] && a.name)
        (opts[:numeric] ? a.value : (a.name || a.value)).inspect
      else
        a._to_s(opts,depth+1)
      end
    end

    if BINARY_OPS.include?(op)
      "(#{evaled_args[0]} #{op} #{evaled_args[1]})" 
    else
      "#{op}(#{evaled_args.join(', ')})" 
    end
  end

  def _to_ary(opts = {}, depth = 0)
    evaled_args = args.map do |a| 
      if a.atomic? || (!opts[:expand] && a.name)
        Array(opts[:numeric] ? a.value : (a.name || a.value))
      else
        a._to_ary(opts,depth+1)
      end
    end

    evaled_args.unshift(op)
  end

private

  # Wizard hats on ;)

  def eval
    atomic? ? value : apply
  end

  def apply
    result = \
      if @env[op].respond_to?(:call)
        @env[op].call(*arg_values) 
      else
        arg_values[0].send(op, *arg_values.cdr)
      end

    puts " -> #{op}(#{arg_values.join(', ')}) = #{result}" if Calculation.verbose
    result
  end

  def arg_values
    args.map { |a| a.value }
  end

end
