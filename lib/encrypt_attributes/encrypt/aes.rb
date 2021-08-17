require 'securerandom'

module EncryptAttributes
  module Encrypt
    class AES
      def initialize(password)
        @password = password
        @cipher = OpenSSL::Cipher.new("aes-256-cbc")
      end

      def encrypt(data)
        @cipher.encrypt
        salt = generate_salt
        @cipher.pkcs5_keyivgen(@password, salt, 1)
        e = @cipher.update(data) + @cipher.final
        e = "Salted__#{salt}#{e}" #OpenSSL compatible
        Base64.encode64(e)
      end

      def decrypt(data)
        data = Base64.decode64(data)
        salt = data[8..15]
        data = data[16..-1]

        return nil if data.nil?

        @cipher.pkcs5_keyivgen(@password, salt, 1)
        @cipher.decrypt
        @cipher.update(data) + @cipher.final
      end

      private

      def generate_salt
        8.times.map { SecureRandom.rand(255).chr }.join
      end
    end
  end
end
