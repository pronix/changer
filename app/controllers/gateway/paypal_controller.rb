class Gateway::PaypalController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  require 'gateway/paypal/crypto42'
  require 'money'
  
  skip_before_filter :verify_authenticity_token, :only => [:done, :notify]  
  before_filter :fetch_claim  
  
  def show
  end

  
  
  # ========================= Оплата по системе PayPal ===========
  # После потдверждения введеных данных и принятия пользовательского соглашения
  # Перенаправляем на оплату платежа
  def pay
    fetch_decrypted(@claim)  
  end
  
  # Уведомление от PayPal о статусе платежа
  def notify 
    @notify_paypal = Paypal::Notification.new(request.raw_post)
    
    if @notify_paypal.acknowledge
      begin
        @claim =  Claim.confirmed.find @notify_paypal.invoice
        # @transaction.payment_params = params

        if @notify_paypal.complete?
          # Платеж успешно завершен
          # @transaction.fee = params[:payment_fee]
          # @transaction.comment =  @transaction.comment + ", "+t('paypal.flash.success_payment')
          # @transaction.complete!
        else
          # платеж не завершен
          # @transaction.comment =  @transaction.comment +", "+ t('paypal.flash.fail_payment')
          # @transaction.failure!
        end
        
      rescue => e
        # обработка ошибки
      ensure
        # что длеаеться в любом случае
      end
    end
    render :nothing => true
  end

  
  # PayPal сюда возвращает пользователя после оплаты
  def done
  end
  
  private

  def fetch_claim
    @claim = Claim.find_claim session[:claim_id]        
  end
  
  def fetch_decrypted(claim)
    @gateway = claim.payment_system_source


    decrypted = {
      "cert_id"       => @gateway.parameters[:cert_id],
      "cmd"           => @gateway.parameters[:cmd],
      "business"      => @gateway.parameters[:business],
      "item_name"     => "Обмен ",
      "item_number"   => "1",
      "amount"        => claim.summa,
      "currency_code" => claim.currency_source.code,
      "country"       => "RU",
      "no_note"       => "1",
      "no_shipping"   => "1",
      "invoice"       => claim.id,
      "return"        => @gateway.parameters[:return_url]
   
    }    
    @encrypted_basic = Crypto42::Button.from_hash(decrypted).get_encrypted_text
  end

end
