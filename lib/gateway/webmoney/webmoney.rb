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
      gateway = WebmoneyTransfert.new(claim.payment_system_receiver)
      
      begin
        Rails.logger.info '~'*90
        Rails.logger.info "[ webmoney ] Посылаем запрос на перечесление денег" 
        response = gateway.transfert({ :transid => claim.id,
                                       :pursedest => claim.option_purse[:purse_dest],
                                       :amount => claim.receivable_receive  })

        claim.response_transfert = response
        return true
      rescue
        return false
      end
    end

    class << self
      # TODO test
      # Нужно вернуть баланс с кошелька нашего сервиса
      def get_balance(payment_params)
        gateway = WebmoneyTransfert.new(payment_params)
        gateway.get_balance 
      rescue 0
      end
    end
    
  end
  
  
  class WebmoneyTransfert
    include ::Webmoney
    attr_accessor :cert, :wmid, :pursesrc, :transid, :pursedest, :amount
  
    def initialize(payment_params)
      @cert = OpenSSL::X509::Certificate.new(File.read(
                       File.join(RAILS_ROOT,"lib", "gateway", "webmoney", "cert", "webmoney.cer")))
      paymethod = payment_params
      @pursesrc = paymethod.parameters[:payee_purse]
      @wmid = paymethod.parameters[:wmid]
      super(:wmid =>@wmid, :cert => @cert )
    end
  
    def bussines_level
      request(:bussines_level, :wmid => @wmid)
    end
    # получение баланса 
    def get_balance
      webmoney_response = request(:balance, :wmid => @wmid)
      webmoney_response[:purses][@wmid]
    end
    
    def transfert(options)
      request(:create_transaction, :wmid => @wmid,  
              :transid   => options[:transid], # номер заявки
              :pursesrc  => @pursesrc,
              :pursedest => options[:pursedest], # кошелек пользователя
              :amount    => options[:amount]) # сумма

    end
    
  end
  
end
