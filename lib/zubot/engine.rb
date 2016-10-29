module Zubot
  class Engine < ::Rails::Engine
    config.after_initialize do
      template_compiler = TemplatePrecompiler.new
      template_compiler.compile_templates!
    end if Zubot.enabled
  end
end
