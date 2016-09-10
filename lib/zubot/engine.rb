require "rails"

module Zubot
  class Engine < ::Rails::Engine
    config.after_initialize do |app|
      template_compiler = TemplatePrecompiler.new(app)
      template_compiler.compile_templates!
    end
  end
end
