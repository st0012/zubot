$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'zubot'
require "pry"
require "action_view"
require "support/template_helper"

RSpec.configure do |config|
  config.include TemplateHelper
end
