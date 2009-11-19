class Gateway::PaypalController < ApplicationController
  before_filter :fetch_claim  
  
  def show
  end

  # После потдверждения введеных данных и принятия пользовательского соглашения
  # Перенаправляем на оплату платежа
  def pay
  end
  
  private

  def fetch_claim
    @claim = Claim.find_claim session[:claim_id]        
  end
  

end
