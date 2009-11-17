class Gateway::WebmoneyController < ApplicationController
  
  # выводим форму чтоб пользователь заполнил сумму и кошелек
  def show
    @claim = Claim.find session[:claim_id]
  end
  
  #
  def update
    @claim = Claim.find session[:claim_id]
    if @claim.update_attributes params[:claim]
      
    else
      render :action => :show
    end
  end
  
  # еще раз выводим пользователю его данные  по заявке, курс обмена, 
  # начальная сумма, конечная сумма, коммисиия
  def confirmed
    
  end
  
end
