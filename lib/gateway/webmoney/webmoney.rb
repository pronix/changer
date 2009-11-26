=begin rdoc
Для работы с webmoney
=end
module LibGateway
  class Webmoney
    attr_accessor :errors
    def initialize
      @errors = { }
    end
    # валидация параметров option_purse для заявки
    def valid_params(options)
      # Проверяем чтоб кошелек был валидны
      @errors = { }
      @errors[:purse_dest] = "Неверный формат кошелька" unless !options["purse_dest"].blank? &&
        options["purse_dest"] =~ /^[R|Z]|E|U|D[0-9]{12}/
      @errors.blank?
    end

    # Перевод денег
    def transfert(claim)
      gateway = WebmoneyTransfert.new(claim)
      
      begin
        Rails.logger.info '~'*90
        Rails.logger.info "[ webmoney ] Посылаем запрос на перечесление денег" 
        response = gateway.transfert
        claim.response_transfert = response
        return true
      rescue
        return false
      end
    end

    
    
  end
  
  
  class WebmoneyTransfert
    include ::Webmoney
    attr_accessor :cert, :wmid, :pursesrc, :transid, :pursedest, :amount
  
    def initialize(claim)
      @cert = OpenSSL::X509::Certificate.new(File.read(
                       File.join(RAILS_ROOT,"lib", "gateway", "webmoney", "cert", "webmoney.cer")))
      paymethod = claim.payment_system_receiver
      @pursesrc = paymethod.parameters[:payee_purse]
      @wmid = paymethod.parameters[:wmid]
      @transid = claim.md5 # ид заявки
      @pursedest = claim.option_purse[:purse_dest] # кошелек пользователя
      @amount = claim.receivable_receive # сумма к перечеслению
      super(:wmid =>@wmid, :cert => @cert )
    
    end
  
    def bussines_level
      request(:bussines_level, :wmid => @wmid)
    end

    def transfert(options)
      request(:create_transaction, :wmid => @wmid,  
              :transid   => @transid, # номер заявки
              :pursesrc  => @pursesrc,
              :pursedest => @pursedest, # кошелек пользователя
              :amount    => @amount) # сумма

    end
    
  end
  
end
