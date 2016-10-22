require "pry"

module Bar
end

class Foo
  include Bar

  def local_codes(locals)
    locals.each_with_object("") { |key, code| code << "#{key} = #{key} = local_assigns[:#{key}];" }
  end

  def code
    "foo = '\\'bar\\''; puts bar;"
  end

  def compile(mod)
    method_name = :foo
    mod.instance_variable_set(:@foo_code, code)
    source = <<-source
      def method_body(local_assigns)
        <<-body
          \#{local_codes(local_assigns.keys)}
          \#{#{mod}.instance_variable_get(:@foo_code)}
        body
      end

      def #{method_name}(local_assigns)
        inner_source = <<-inner_source
          def \#{__method__}(local_assigns)
            \#{method_body(local_assigns)}
          end
        inner_source
        Bar.module_eval(inner_source)
        send(__method__, local_assigns)
      end
    source
    Bar.module_eval(source)
  end
end

h = { bar: "test" }
f = Foo.new
f.compile(Bar)
f.foo(h)
