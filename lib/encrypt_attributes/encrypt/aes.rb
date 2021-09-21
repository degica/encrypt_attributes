module EncryptAttributes
  module Encrypt
    class AES
      def initialize(password)
        @password = password
        @cipher = OpenSSL::Cipher.new("aes-256-cbc")
      end

      def encrypt(plaintext)
        @cipher.encrypt
        salt = generate_salt
        @cipher.pkcs5_keyivgen(@password, salt, 1)
        e = @cipher.update(plaintext) + @cipher.final
        e = "Salted__#{salt}#{e}" # OpenSSL compatible
        Base64.encode64(e)
      end

      def decrypt(ciphertext)
        data = Base64.decode64(ciphertext)
        salt = data[8..15]
        data = data[16..-1]

        return nil if data.nil?

        @cipher.pkcs5_keyivgen(@password, salt, 1)
        @cipher.decrypt
        @cipher.update(data) + @cipher.final
      end

      private

      def generate_salt
        8.times.map { rand(255).chr }.join
      end
    end
  end
end
