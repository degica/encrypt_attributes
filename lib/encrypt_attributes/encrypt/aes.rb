module EncryptAttributes
  module Encrypt
    class AES
      AUTH_TAG_LEN = 16

      def initialize(password)
        @password = password
      end

      def encrypt(plaintext)
        cipher = OpenSSL::Cipher.new('aes-256-gcm')
        cipher.encrypt

        iv = cipher.random_iv
        salt = OpenSSL::Random.random_bytes(cipher.key_len)
        cipher.key = v1_key(cipher, salt)

        ciphertext = cipher.update(plaintext) + cipher.final
        auth_tag = cipher.auth_tag
        'v1|' + Base64.encode64("#{iv}#{salt}#{auth_tag}#{ciphertext}")
      end

      def decrypt(value)
        case value.split('|')
        in ['v1', ciphertext] then decrypt_v1(ciphertext)
        in [ciphertext] then decrypt_legacy(ciphertext)
        else nil
        end
      end

      def decrypt_legacy(b64_ciphertext)
        raise 'Unsupported in Ruby >= 3.0' if RUBY_VERSION.to_f >= 3.0

        cipher = OpenSSL::Cipher.new('aes-256-cbc')
        data = Base64.decode64(b64_ciphertext)
        salt = data[8..15]
        data = data[16..-1]

        return nil if data.nil?

        cipher.pkcs5_keyivgen(@password, salt, 1)
        cipher.decrypt
        cipher.update(data) + cipher.final
      end

      def decrypt_v1(b64_ciphertext)
        cipher = OpenSSL::Cipher.new('aes-256-gcm')
        cipher.decrypt

        data = Base64.decode64(b64_ciphertext)
        iv         = data[0, cipher.iv_len]
        salt       = data[cipher.iv_len, cipher.key_len]
        auth_tag   = data[cipher.iv_len+cipher.key_len, AUTH_TAG_LEN]
        ciphertext = data[cipher.iv_len+cipher.key_len+AUTH_TAG_LEN..-1]

        return nil if [iv, salt, ciphertext].any?(&:nil?)

        cipher.iv = iv
        cipher.key = v1_key(cipher, salt)
        cipher.auth_tag = auth_tag
        cipher.update(ciphertext) + cipher.final
      end

      private

      def v1_key(cipher, salt)
        OpenSSL::KDF.pbkdf2_hmac(
          @password,
          salt: salt,
          iterations: 2000,
          length: cipher.key_len,
          hash: 'sha256'
        )
      end
    end
  end
end
