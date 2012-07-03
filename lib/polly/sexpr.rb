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
        val.map!.with_index do |arg, i| 
          (arg.is_a?(Sexpr) || i == 0) ? arg : Sexpr.build(arg, opts)
        end
      when *ATOMIC_TYPES
        Array(val)
      when NilClass
        UNDEFINED
      end

    Sexpr.new(val, opts)
  end

  def initialize(sexpr, opts = {})
    @sexpr = (sexpr.is_a?(Sexpr) ? sexpr.sexpr : sexpr)
    @op = @sexpr[0]
    @args = @sexpr.cdr
    @name = opts[:name]
  end

  # use cached values unless some part of expression tree is dirty
  #
  def value(ctx = Env.new)
    @value = (clean? && @value) || 
      (atomic? ? @sexpr.first : (self.defined? && self.send(:eval, ctx) || nil))
    @dirty = false
    @value
  end

  # force a recalc of all sub-expressions
  #
  def value!(ctx = Env.new) 
    each_atomic { |a| a.instance_variable_set("@dirty", true) }
    value(ctx)
  end

  def replace(val)
    @dirty = true
    @sexpr = self.class.build(val).sexpr
  end

  def atomic?
    @sexpr.size == 1 && valid_type?(@sexpr.first)
  end

  def defined?; !undefined? end
  def undefined?; any? { |s| s.sexpr == UNDEFINED } end
  def undefined_variables; select { |s| s.atomic? && s.undefined? } end

  def clean?; !dirty? end
  def dirty?; any? { |s| s.instance_variable_get("@dirty") } end
  def dirty_variables; select { |s| s.atomic? && s.dirty? } end

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

  def each_atomic(&block)
    select { |s| s.atomic? }
  end

# magix

  # convert any method call to an s-expression
  #
  def method_missing(method, *args, &block)
    if args.all? { |a| valid_expr?(a) }
      Sexpr.build([method, self, *args])
    else
     super
    end
  end

# printing and conversion
  
  def print(opts = {}); puts to_s(opts) end
  def inspect(opts = {}); @sexpr.inspect end
  def to_s(opts = {}); _to_s(opts) end
  def to_ary(opts = {}); _to_ary(opts) end

protected

  def _to_s(opts = {}, depth = 0)
    if atomic? || (!opts[:expand] && depth > 0 && name)
      (opts[:numeric] ? value : (name || value)).inspect
    elsif BINARY_OPS.include?(op)
      "(#{@sexpr[1]._to_s(opts,depth+1)} #{@sexpr[0]} #{@sexpr[2]._to_s(opts,depth+1)})" 
    else
      "#{op}(#{args.map { |a| a._to_s(opts,depth+1) }.join(', ')})" 
    end
  end

  def _to_ary(opts = {}, depth = 0)
    if atomic? || (!opts[:expand] && depth > 0 && name)
      (opts[:numeric] ? value : (name || value))
    else
      [op, args.map { |a| a._to_ary(opts,depth+1) }]
    end
  end

private

  # Wizard hats on ;)

  def eval(ctx)
    atomic? ? (ctx[value] || value) : apply(ctx)
  end

  def apply(ctx)
    result = \
      if ctx[op].respond_to?(:call)
        ctx[op].call(*arg_values) 
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
