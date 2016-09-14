module Zubot
  class << self
    attr_accessor :debug_mode
  end

  self.debug_mode = Rails.env.development?
end
