class Gateway::WebmoneyController < ApplicationController
  before_filter :fetch_claim  
  # выводим форму чтоб пользователь заполнил сумму и кошелек
  def show
  end
  
  # Сохраняем данные по заявке
  # и перенаправляем на потверждение данных
  def update
    @claim.attributes = params[:claim]
    if !@claim.new?  
      flash[:notice] = "Заявка уже заполнена. <a href=#{confirmed_gateway_webmoney_path}>Потдвертить заявку</a>"
      render :action => :show
    elsif Webmoney.valid_params(@claim.option_purse) && @claim.fill!
      redirect_to confirmed_gateway_webmoney_path 
    else
      flash[:notice] = 'Ошибка'
      render :action => :show
    end
  end
  
  # еще раз выводим пользователю его данные  по заявке, курс обмена, 
  # начальная сумма, конечная сумма, коммисиия
  def confirmed
    unless request.post?
      # выводим форму потдверждения
      render :action => :confirmed
    else
      # пользователь потдвердил данные и согласился с соглашением
    end
  end
  
  private
  
  def fetch_claim
    @claim = Claim.find_claim session[:claim_id]        
  end
  
end
