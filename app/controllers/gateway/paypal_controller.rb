class Gateway::PaypalController < ApplicationController

  def show
    @claim = Claim.find session[:claim_id]
  end
  

end
