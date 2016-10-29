module ActionView
  class Base
    DELEGATION_RESERVED_METHOD_NAMES = Set.new(
      %w(_ arg args alias and BEGIN begin block break case class def defined? do
      else elsif END end ensure false for if in module next nil not or redo
      rescue retry return self super then true undef unless until when while
      yield)
    ).freeze

    def local_codes(locals)
      locals = locals.to_set - DELEGATION_RESERVED_METHOD_NAMES
      locals = locals.grep(/\A(?![A-Z0-9])(?:[[:alnum:]_]|[^\0-\177])+\z/)
      locals.each_with_object("") { |key, code| code << "#{key} = #{key} = local_assigns[:#{key}];" }
    end
  end

  class Template
    prepend Zubot::Helpers

    def compile(mod) #:nodoc:
      encode!
      method_name = self.method_name
      code = @handler.call(self)
      # This ensure the code string remains didn't get transfered in the method's second definition process.
      # For example, assume we have code like
      # ```
      # "append='<script type=\\'text/javascript\\'></script>'
      # ```
      # Than interpolate it in the inner_source below will make it transfered to
      # ```
      # "append='<script type='text/javascript'></script>'
      # ```
      #
      # And we will get syntax error when we execute that code.
      Zubot.view_codes[method_name.to_sym] = code

      # Make sure that the resulting String to be eval'd is in the
      # encoding of the code
      source = <<-end_src
        def #{method_name}(local_assigns, output_buffer)
          # If we already has local codes defined, skip method recreation.
          if no_locals_required = (methods & local_assigns.keys) == local_assigns.keys
            _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer;#{code}
          else
            source = <<-inner_source
              def \#{__method__}(local_assigns, output_buffer)

                _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer
                # recreate the method with local codes.
                \#{local_codes(local_assigns.keys)}
                # retrieve the template code from Zubot's view_codes
                \#{Zubot.view_codes.delete(:#{method_name})}
              ensure
                @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer
              end
            inner_source
            #{mod}.module_eval(source)

            if block_given?
              # Capture the outter block
              p = Proc.new
              self.send(__method__, local_assigns, output_buffer, &p)
            else
              self.send(__method__, local_assigns, output_buffer)
            end
          end
        ensure
          @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer if no_locals_required
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
