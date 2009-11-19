module Crypto42
  class Button
    def initialize(data)
      place_cert = [RAILS_ROOT, "lib", "gateway", "paypal", "cert"]
      
      my_cert_file =     File.join(place_cert.dup << "my-pubcert.pem")
      my_key_file =      File.join(place_cert.dup << "my-prvkey.pem")
      paypal_cert_file = File.join(place_cert.dup << "paypal_cert.pem")

      IO.popen("/usr/bin/openssl smime -sign -signer #{my_cert_file} -inkey #{my_key_file} -outform der -nodetach -binary | /usr/bin/openssl smime -encrypt -des3 -binary -outform pem #{paypal_cert_file}", 'r+') do |pipe|
        data.each { |x,y| pipe << "#{x}=#{y}\n" }
        pipe.close_write
        @data = pipe.read
      end
    end

    def self.from_hash(hs)
      self.new hs
    end

    def get_encrypted_text
      return @data
    end

  end #end button
end #end module
