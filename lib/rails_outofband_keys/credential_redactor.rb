# frozen_string_literal: true

module RailsOutofbandKeys
  module StringRedactor
    def self.tag(string)
      return string unless string.is_a?(String)
      # We use extend to apply behavior to this specific instance only
      string.extend(self) unless string.respond_to?(:from_credentials?)
      string
    end

    def from_credentials?
      true
    end

    def inspect
      "\"[REDACTED]\""
    end

    def to_s
      "[REDACTED]"
    end
  end

  module CredentialRedactor
    def inspect; redacted_string; end
    def to_s; redacted_string; end
    def pretty_print(q); q.text(redacted_string); end

    # Intercept access to keys
    def [](key)
      wrap_with_redactor(super)
    end

    # Intercept dot-syntax access
    def method_missing(name, *args, &block)
      result = super
      wrap_with_redactor(result)
    end

    def respond_to_missing?(name, include_private = false)
      super
    end

    private

    def wrap_with_redactor(value)
      case value
      when Hash, ActiveSupport::OrderedOptions
        value.extend(RailsOutofbandKeys::CredentialRedactor)
      when String
        RailsOutofbandKeys::StringRedactor.tag(value)
      else
        value
      end
    end

    def redacted_string
      "\"[REDACTED]\""
    end
  end
end
