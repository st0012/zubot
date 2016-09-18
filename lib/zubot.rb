require "zubot/version"
require "zubot/engine"
require "zubot/config"
require "zubot/helpers"
require "action_view"
require "zubot/actionview/template"
require "zubot/actionview/resolver"

module Zubot
  class TemplatePrecompiler
    attr_reader :compiled_count

    def initialize
      @compiled_count = 0
    end

    def compile_templates!
      view_paths.each do |resolver|
        resolver_path = resolver.instance_variable_get(:@path)
        template_files = File.join("#{resolver_path}", "**", "**", "*.*")
        template_paths = Dir.glob(template_files)
        template_paths.each do |template_path|
          compile_template(template_path, resolver)
        end
      end

      display_compiled_status
    end

    def compile_template(template_path, resolver)
      resolver_path = resolver.instance_variable_get(:@path)
      name, prefix, partial, details, key, local = template_args(template_path, resolver_path)

      handler = get_handler(template_path)
      return unless handler.in?(details[:handlers])

      templates = resolver.find_all(name, prefix, partial, details, key, local)

      # Basically contains only one template.
      templates.each do |template|
        @compiled_count += 1 if template.send(:compile!, view)
      end if templates.present?
    end

    private

    def display_compiled_status
      puts "Precompiled count #{@compiled_count}" if Zubot.debug_mode
    end

    def get_handler(template_path)
      template_path.split("/").last.split(".").last.to_sym
    end

    def template_args(template_path, resolver_path)
      # This would be like ["", "posts", "show.html.erb"] for "/posts/show.html.erb"
      virtual_path = template_path.sub(resolver_path, "").split("/")
      filename = virtual_path[-1]
      name = filename.split(".").first
      prefix = virtual_path[1..-2].join("/")
      partial = name.start_with?("_")
      name.sub!(/\_/, "") if partial

      format = filename.split(".")[1].to_sym
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
