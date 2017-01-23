require "encrypt_attributes/version"
require "encrypt_attributes/attribute"
require 'yaml'
require 'base64'
require 'gibberish'
require 'active_support'

module EncryptAttributes
  extend ActiveSupport::Concern

  module ClassMethods
    def encryption_targets
      @encryption_targets ||= {}
    end

    def default_encryption_options
      {
        encode: false,
        serialize: false
      }
    end

    def encrypted_attribute(name, options={})
      encryption_targets[name.to_sym] = default_encryption_options.merge options

      define_method(name) do
        encrypted = send("encrypted_#{name}")
        secret_key = options[:secret_key].is_a?(Symbol) ? self.send(options[:secret_key]) : options[:secret_key]
        Attribute.new(encrypted, secret_key, encryption_options_for(name)).decrypt
      end

      define_method("#{name}=") do |val|
        secret_key = options[:secret_key].is_a?(Symbol) ? self.send(options[:secret_key]) : options[:secret_key]
        encrypted = Attribute.new(val, secret_key, encryption_options_for(name)).encrypt
        send("encrypted_#{name}=", encrypted)
      end

      define_method("#{name}?") do
        value = send(name)
        value.respond_to?(:empty?) ? !value.empty? : !!value
      end
    end
  end

  private

  def encryption_targets
    self.class.encryption_targets
  end

  def encryption_options_for(attr_name)
    encryption_targets[attr_name.to_sym]
  end
end
