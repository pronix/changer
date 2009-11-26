class Gateway::WebmoneyController < ApplicationController
  require "gateway/webmoney/webmoney"
  require "digest/md5"
  
  skip_before_filter :verify_authenticity_token, :only => [:payment_result, :payment_success, :payment_fail]  
  
  before_filter :fetch_claim, :only => [:show, :update, :confirmed, :pay ]
  before_filter :parse_payment_params, :only => [:payment_result, :payment_success, :payment_fail]
  before_filter :valid_payment, :only => [:payment_result]
  
  # Заполнение данных для заявки
  # выводим форму чтоб пользователь заполнил сумму и кошелек
  def show
    @claim.edit! if @claim.filled?    
  end
  
  # Сохраняем данные по заявке
  # и перенаправляем на потверждение данных
  def update
    @claim.attributes = params[:claim]
    @valid_webmoney = LibGateway::Webmoney.new 
    if @claim.valid? && @valid_webmoney.valid_params(@claim.option_purse)
      @claim.fill!
      redirect_to confirmed_gateway_webmoney_path 
    else
      flash[:error] = "Введенные данные не правельные"
      render :action => :show
    end
  end
  
  # еще раз выводим пользователю его данные  по заявке, курс обмена, 
  # начальная сумма, конечная сумма, коммисионные сборы
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
  
  
  # Оплата заявки через webmoney
  
  def pay
  end
  
  # Результат платежа 
  # Получаем данные об оплате, проверяем их, 
  # записываем данные платежа в транзакцию и закрываем оплаченную транзакцию 
  def payment_result
    @claim.payment_options = @payment_params
    if @claim.payment!
      render :text => "Success"
    else
      render :text => "No"
    end
  end
  
  # Подтвержение успешной оплаты
  # Проверяем что нужная транзакция уже закрыта и проведена
  def payment_success
    @claim = Claim.find @payment_params[:payment_no]
    if @claim && @claim.pay?
      flash[:notice] = 'Платеж выполнен'
    else
      flash[:error] = 'Платеж не зачислен'
    end
    
    redirect_to claims_path    
  end
  
  # Платеж отменен
  # закрываем транзакцию со статусом error (не удачное завершение транзакции)
  def payment_fail
    @claim = Claim.confirmed.find @payment_params[:payment_no]
    @claim.payment_options = params    
    @claim.comment =  @claim.comment + " Платеже завершен с ошибкой."
    @claim.erroneous!
    redirect_to claims_path    
  end

  
  private
  
  def fetch_claim
    @claim = Claim.find_claim(session[:claim_id]) 
  end
  
  # разбираем параметры
  def parse_payment_params
    @payment_params = HashWithIndifferentAccess.new
    params.each do |key, value|
      if key.starts_with?('LMI_')
        @payment_params[key.gsub(/^LMI_/, "").downcase] = value
      end
    end
  end
  
  # Проверяем верен ли платеж
  def valid_payment
    @claim =  Claim.confirmed.find @payment_params[:payment_no]
    @gateway = @claim.payment_system_source 
    if @payment_params[:prerequest] == "1" # предварительный запрос
      render :text => "YES"
    elsif  @gateway.parameters[:secret].blank?  # если не указан секретный ключ
      raise ArgumentError.new("WebMoney secret key is not provided") 
    elsif ! @payment_params[:hash] ==  # если мд5 не совпает
        Digest::MD5.hexdigest([
                               @payment_params[:payee_purse],    @payment_params[:payment_amount],
                               @payment_params[:payment_no],     @payment_params[:mode],
                               @payment_params[:sys_invs_no],    @payment_params[:sys_trans_no],
                               @payment_params[:sys_trans_date], @gateway.parameters[:secret],
                               @payment_params[:payer_purse],    @payment_params[:payer_wm]
                              ].join("")).upcase
      @claim.errors_claim ||= { }
      @claim.errors_claim[:valid_response] = { :messages => "Неверный ответ от Платежной системы"}
      @claim.errors_claim[:error_params] = params
      @claim.erroneous!
      render :text => "not valid payment"
    end
  rescue
    @claim.errors_claim ||= { }
    @claim.errors_claim[:valid_response] = { :messages => "Ошибка при проверке правельности ответа от Плаежной системы"}
    @claim.errors_claim[:error_params] = params
    @claim.erroneous!
  end
  
end
