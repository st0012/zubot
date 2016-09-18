module ActionView
  module MethodMissing
    def method_missing(name, *args, &block)
      if @local_assigns && local = @local_assigns[name]
        local
      else
        super
      end
    end
  end

  class Base
    include MethodMissing
  end
end
