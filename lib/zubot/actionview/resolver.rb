module ActionView
  # = Action View Resolver
  class Resolver
    def cached(key, path_info, details, locals) #:nodoc:
      name, prefix, partial = path_info
      locals = locals.map(&:to_s).sort!

      if key
        @cache.cache(key, name, prefix, partial, []) do
          decorate(yield, path_info, details, locals)
        end
      else
        decorate(yield, path_info, details, locals)
      end
    end
  end
end
