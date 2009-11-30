class Gateway::PaypalController < ApplicationController
  include ActiveMerchant::Billing::Integrations
  require 'gateway/paypal/crypto42'
  require "gateway/paypal/paypal"
  require 'money'
  
  skip_before_filter :verify_authenticity_token, :only => [:done, :notify]  
  before_filter :fetch_claim, :only => [:show, :update, :confirmed, :pay ]  

  # Заполнение данных по заявки
  def show
    @claim.edit! if @claim.filled?    
  end
  
  # Проверка данных по заявке и сохранение
  def update
    @claim.attributes = params[:claim]
    @valid_paypal = LibGateway::Paypal.new 
    if @claim.valid? &&
        @valid_paypal.valid_params(@claim.option_purse) && @claim.fill!
      redirect_to confirmed_gateway_paypal_path 
    else
      flash[:error] = ["<ul>",@claim.errors.full_messages.collect{ |x| "<li>#{x}</li>"}, "</ul>"].join      
      render :action => :show
    end    
  end
  
  # Потдверждение пользователем данных
  def confirmed
    if !request.put? 
      # выводим форму потдверждения
      render :action => :confirmed
      
    else
      @claim.agree = params[:claim][:agree]
      if @claim.valid?
        # пользователь потдвердил данные и согласился с соглашением
        # сохраняем заявку и перенаправляем пользователя на оплату через Плат. систему источник
        @claim.confirm!
        redirect_to url_for(@claim.pay_action)  
      else
        render :action => :confirmed        
      end
      
    end    
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
        @claim =  Claim.confirmed.find_by_md5 @notify_paypal.invoice
        @claim.payment_options = params

        if @notify_paypal.complete?
          # Платеж успешно завершен
          @claim.fee = params[:payment_fee]
          @claim.payment!
        else
          # платеж не завершен
          @claim.canceled!
        end
        
      rescue => e
        # обработка ошибки
        @claim.canceled!
      ensure
        # что длеаеться в любом случае
      end
    end
    render :nothing => true
  end

  
  # PayPal сюда возвращает пользователя после оплаты
  def done
    redirect_to claims_path
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
      "invoice"       => claim.md5,
      "return"        => @gateway.parameters[:return_url]
   
    }    
    @encrypted_basic = Crypto42::Button.from_hash(decrypted).get_encrypted_text
  end

end
