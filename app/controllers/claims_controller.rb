class ClaimsController < ApplicationController
  # Выводим главную страницу на которой есть формы для заполнения заявки
  def index
    @claim = Claim.new
  end
  
  # просмотр статус заявки
  def show
  end
  
  # Создаем новую заявку а обмен
  def create
    @claim = Claim.new params[:claim]
    if @claim.save
      flash[:notice] = 'Создана новая заявка'
      session[:claim_id] = @claim.id
      # Отправляем на заполнение параметров куда надо переводить денежные средства
      redirect_to url_for(:controller => "gateway/#{@claim.currency_receiver.payment_system.controller.downcase}") 
    else

      flash[:error] = ["<ul>",@claim.errors.full_messages.collect{ |x| "<li>#{x}</li>"}, "</ul>"].join
      render :action => :index
    end
  end

end
