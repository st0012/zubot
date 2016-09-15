require "rails"

module Zubot
  class Engine < ::Rails::Engine
    config.after_initialize do
      template_compiler = TemplatePrecompiler.new
      template_compiler.compile_templates!
    end
  end
end
