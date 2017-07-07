module EncryptAttributes
  class Attribute
    def initialize(value, secret_key, options)
      @value, @secret_key, @options = value, secret_key, options
    end

    def encrypt
      return nil if @value.nil?
      value = @value

      value = serialize(value) if @options[:serialize]
      value = encode(value)    if @options[:encode]

      # Gibberish's default encryption mode is aes-256-cbc
      # salt and iv(initialization vector) is automatically generated and embedded in encrypted @value
      Encrypt::AES.new(@secret_key).encrypt(value)
    end

    def decrypt
      return nil if @value.nil?

      decrypted = Encrypt::AES.new(@secret_key).decrypt(@value)
      decrypted = decode(decrypted)      if @options[:encode]
      decrypted = deserialize(decrypted) if @options[:serialize]

      decrypted
    end

    private

    def serialize(obj)
      YAML.dump(obj)
    end

    def deserialize(s)
      YAML.load(s)
    end

    def encode(s)
      Base64.encode64(s)
    end

    def decode(s)
      decoded = Base64.decode64(s)
      decoded.encode('UTF-8', 'UTF-8')
    end
  end
end
