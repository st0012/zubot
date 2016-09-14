require "zubot/version"
require "zubot/engine"
require "zubot/config"
require "zubot/helpers"
require "zubot/actionview/template"

module Zubot
  class TemplatePrecompiler
   attr_reader :app, :finder

    def initialize(app)
      @app = app
    end

    def compile_templates!
      precompiled_count = 0

      view_paths.each do |resolver|
        resolver_path = resolver.instance_variable_get(:@path)
        paths = Dir.glob("#{resolver_path}/**/*.*")
        paths.map do |template_path|
          name = get_name(template_path)
          prefix = get_prefix(template_path)
          partial = name.start_with?("_")
          format = get_format(template_path)
          locals = []

          name.sub!(/\_/, "") if partial
          details = make_details(format)
          key = details_key.get(details)
          templates = resolver.find_all(name, prefix, partial, details, key, locals)

          # Basically contains only one template.
          templates.each do |template|
            template.send(:compile!, view)
            precompiled_count += 1
          end if templates.present?
        end
      end

      puts "Precompiled count #{precompiled_count}"
    end

    private

    def view_paths
      ActionController::Base._view_paths
    end

    def view
      @view ||= ActionView::Base.new(view_paths, {})
    end

    def details_key
      ActionView::LookupContext::DetailsKey
    end

    def raw_details
      @raw_details ||= view.lookup_context.instance_variable_get(:@details)
    end

    def make_details(format)
      details = raw_details
      details[:formats] = [format]
      details
    end

    def get_name(template_path)
      template_path.split("/").last.split(".").first
    end

    def get_prefix(template_path)
      template_path.split("/")[-2]
    end

    def get_format(template_path)
      template_path.split("/").last.split(".").second.to_sym
    end
  end
end
