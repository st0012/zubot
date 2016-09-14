module Zubot
  module Helpers
    def compile!(view)
      display_compile_result if Zubot.debug_mode
      super
    end

    def display_compile_result
      puts "Template: #{virtual_path}, formats: #{formats.to_s} compiled? #{@compiled}"
    end
  end
end
