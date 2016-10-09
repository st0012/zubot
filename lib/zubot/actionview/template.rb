module ActionView
  class Template
    prepend Zubot::Helpers

    def local_bindings(local_assigns)

    end

    def compile(mod) #:nodoc:
      encode!
      method_name = self.method_name
      code = @handler.call(self)

      # Make sure that the resulting String to be eval'd is in the
      # encoding of the code
      source = <<-end_src
        def #{method_name}(local_assigns, output_buffer)
          @local_assigns = local_assigns

          local_assigns.each_key do |key|
            unless methods.include?(key)
              source = <<-inner_source
                def \#{key}
                  @local_assigns[:\#{key}]
                end
              inner_source
              self.instance_eval(source)
            end
          end
          _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer;#{locals_code};#{code}
        ensure
          @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer
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
