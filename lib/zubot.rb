require "zubot/version"
require "zubot/engine"
require "zubot/config"
require "zubot/helpers"
require "zubot/actionview/template"

module Zubot
  class TemplatePrecompiler
    attr_reader :compiled_count

    def initialize
      @compiled_count = 0
    end

    def compile_templates!
      view_paths.each do |resolver|
        resolver_path = resolver.instance_variable_get(:@path)
        template_paths = Dir.glob("#{resolver_path}/**/*.*")
        template_paths.each do |template_path|
          name, prefix, partial, details, key, local = template_args(template_path)

          handler = get_handler(template_path)
          next unless handler.in?(details[:handlers])

          templates = resolver.find_all(name, prefix, partial, details, key, local)

          # Basically contains only one template.
          templates.each do |template|
            template.send(:compile!, view)
            @compiled_count += 1
          end if templates.present?
        end
      end

      display_compiled_status
    end

    private

    def display_compiled_status
      puts "Precompiled count #{@compiled_count}" if Zubot.debug_mode
    end

    def get_handler(template_path)
      template_path.split("/").last.split(".").last.to_sym
    end

    def template_args(template_path)
      splited_path = template_path.split("/")
      name = splited_path.last.split(".").first
      prefix = splited_path[-2]
      partial = name.start_with?("_")
      name.sub!(/\_/, "") if partial

      format = splited_path.last.split(".")[1].to_sym
      details = make_details(format)

      key = details_key.get(details)
      locals = []
      [name, prefix, partial, details, key, locals]
    end

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
  end
end
