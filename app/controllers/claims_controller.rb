class ClaimsController < ApplicationController
  # Выводим главную страницу на которой есть формы для заполнения заявки
  def index
    @claim = Claim.new
  end

  
  def create
  end
  

end
