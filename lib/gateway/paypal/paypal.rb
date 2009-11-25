=begin rdoc
Для работы с webmoney
=end
module LibGateway
  class Paypal
    attr_accessor :errors
    
    def initialize
      @errors = { }
    end
    # валидация параметров option_purse для заявки
    def valid_params(options)
      # Проверяем чтоб кошелек был валидны
      @errors = { }
      @errors[:purse_dest] = "Неверный формат кошелька" unless !options["purse_dest"].blank? &&
        options["purse_dest"] =~ /\A[A-Z0-9_\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4})\z/i
      @errors.blank?
    end

   
  # Перевод денег
    def transfert(claim)
      @errors = { }
      paymethod = claim.payment_system_receiver
      gateway_options = {
        :login => paymethod.parameters[:login],
        :password => paymethod.parameters[:password],
        :pem => nil, 
        :signature => paymethod.parameters[:signature] 
      }
    
      gateway = ActiveMerchant::Billing::PaypalGateway.new(gateway_options)
      logger.info '~'*90
      logger.info "[ paypal ] Посылаем запрос на перечесление денег"
      response =  gateway.transfer(claim.receivable_receive,
                                   claim.option_purse[:purse_dest],
                                   :subject => "Перечесление с обменика",
                                   :note => "") 
      claim.response_transfert = { 
        :params => response.params, 
        :avs_result => response.avs_result,
        :message => response.message }
      
      if response.success?
        # Перечисление денег успечшно
        logger.info '~'*90
        logger.info "[ paypal ] Запрос выполнен успешно"
        return true
      else
        # Перечисление денег не успечшно
        @errors[:messages] = response.messages
        logger.error "[ paypal ] Запрос выполнен с ошибкой #{response.message}"
        return false
      end
        
    end
  end  
end
