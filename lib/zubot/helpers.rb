module Zubot
  module Helpers
    def compile!(view)
      display_compile_result(@compiled)
      super
    end

    def display_compile_result(compiled)
      puts "Template: #{virtual_path}, formats: #{formats.to_s} compiled? #{compiled}"
    end
  end
end
