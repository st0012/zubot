module ActionView
  class Base
    def local_codes(locals)
      locals = locals.to_set - Module::DELEGATION_RESERVED_METHOD_NAMES
      locals = locals.grep(/\A(?![A-Z0-9])(?:[[:alnum:]_]|[^\0-\177])+\z/)
      locals.each_with_object("") { |key, code| code << "#{key} = #{key} = local_assigns[:#{key}];" }
    end
  end

  class Template
    prepend Zubot::Helpers

    def view_method_body(code)
      <<-src
        _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer;#{code}
        ensure
          @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer
      src
    end

    def compile(mod) #:nodoc:
      encode!
      method_name = self.method_name
      code = @handler.call(self)
      mod.instance_variable_set("@#{method_name}_code", code)

      # Make sure that the resulting String to be eval'd is in the
      # encoding of the code
      source = <<-end_src
        def #{method_name}(local_assigns, output_buffer)
          if (methods & local_assigns.keys) == local_assigns.keys
            _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer;#{code}
          else
            source = <<-inner_source
              def \#{__method__}(local_assigns, output_buffer)

                _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer;\#{local_codes(local_assigns.keys)};\#{#{mod}.instance_variable_get("@#{method_name}_code")}
              ensure
                @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer
              end
            inner_source
            self.instance_eval(source)
            self.send(__method__, local_assigns, output_buffer)
          end
        ensure
          @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer if _old_virtual_path || _old_output_buffer
        end
      end_src

      # Make sure the source is in the encoding of the returned code
      source.force_encoding(code.encoding)

      # In case we get back a String from a handler that is not in
      # BINARY or the default_internal, encode it to the default_internal
      source.encode!

      # Now, validate that the source we got back from the template
      # handler is valid in the default_internal. This is for handlers
      # that handle encoding but screw up
      unless source.valid_encoding?
        raise WrongEncodingError.new(@source, Encoding.default_internal)
      end

      mod.module_eval(source, identifier, 0)
      ObjectSpace.define_finalizer(self, Finalizer[method_name, mod])
    end
  end
end
