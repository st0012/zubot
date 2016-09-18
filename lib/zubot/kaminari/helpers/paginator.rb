module Kaminari
  module Helpers
    class Paginator
      # For some reason the old way doesn't work.
      # You can use some methods (:current_page) on @template, but #respond_to? would still return false.
      # I think this is caused by the monkey-patching I used to solve local variable issues.
      #
      # def method_missing(name, *args, &block)
      #   @template.respond_to?(name) ? @template.send(name, *args, &block) : super
      # end
      def method_missing(name, *args, &block)
        @template.send(name, *args, &block)
      end
    end
  end
end
