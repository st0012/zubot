module Zubot
  class Engine < ::Rails::Engine
    config.after_initialize do
      if Zubot.enabled
        template_compiler = TemplatePrecompiler.new
        template_compiler.compile_templates!
      end
    end
  end
end
