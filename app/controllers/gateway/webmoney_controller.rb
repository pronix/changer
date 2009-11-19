class Gateway::WebmoneyController < ApplicationController
  before_filter :fetch_claim  
  
  # выводим форму чтоб пользователь заполнил сумму и кошелек
  def show
  end
  
  # Сохраняем данные по заявке
  # и перенаправляем на потверждение данных
  def update

    @claim.attributes = params[:claim]
    if @claim.valid? && Webmoney.valid_params(@claim.option_purse)
      @claim.fill!
      redirect_to confirmed_gateway_webmoney_path 
    else
      flash[:error] = "Введенные данные не правельные"
      render :action => :show
    end
  end
  
  # еще раз выводим пользователю его данные  по заявке, курс обмена, 
  # начальная сумма, конечная сумма, коммисиия
  def confirmed
    if !request.put?
      # выводим форму потдверждения
      render :action => :confirmed
    elsif params[:claim][:agree] && params[:claim][:agree].to_i == 1
      # пользователь потдвердил данные и согласился с соглашением
      # сохраняем заявку и перенаправляем пользователя на оплату через Плат. систему источник
      @claim.confirm!
      redirect_to url_for(@claim.pay_action)
    end
  end
  
  
  private
  
  def fetch_claim
    @claim = Claim.find_claim(session[:claim_id]) 
  end
  

end
