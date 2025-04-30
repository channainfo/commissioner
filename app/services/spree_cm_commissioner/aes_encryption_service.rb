require 'base64'
require 'openssl'

module SpreeCmCommissioner
  class AesEncryptionService
    ALGORITHM = 'aes-256-gcm'.freeze
    KEY_LENGTH = 32
    IV_LENGTH = 12
    TAG_LENGTH = 16

    def self.encrypt(plaintext, base64_key)
      key = Base64.decode64(base64_key)
      validate_key!(key)

      cipher = OpenSSL::Cipher.new(ALGORITHM)
      cipher.encrypt
      cipher.key = key[0, KEY_LENGTH]
      iv = cipher.random_iv
      cipher.iv = iv

      ciphertext = cipher.update(plaintext) + cipher.final
      tag = cipher.auth_tag

      combined = iv + ciphertext + tag
      Base64.strict_encode64(combined)
    end

    def self.decrypt(encrypted_text, base64_key)
      key = Base64.decode64(base64_key)
      validate_key!(key)

      combined = Base64.decode64(encrypted_text)
      iv = combined[0, IV_LENGTH]
      tag = combined[-TAG_LENGTH..]
      ciphertext = combined[IV_LENGTH...-TAG_LENGTH]

      cipher = OpenSSL::Cipher.new(ALGORITHM)
      cipher.decrypt
      cipher.key = key[0, KEY_LENGTH]
      cipher.iv = iv
      cipher.auth_tag = tag

      cipher.update(ciphertext) + cipher.final
    rescue OpenSSL::Cipher::CipherError => e
      raise "Decryption failed: #{e.message}"
    end

    def self.validate_key!(key)
      return if key.is_a?(String) && key.bytesize >= KEY_LENGTH

      raise ArgumentError, "Key must be a string of at least #{KEY_LENGTH} bytes"
    end
  end
end
