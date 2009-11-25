class ClaimsController < ApplicationController
  # Выводим главную страницу на которой есть формы для заполнения заявки
  def index
    @claim = Claim.new
  end
  
  # просмотр статус заявки
  def show
    @claim = Claim.find_claim session[:claim_id] 
    respond_to do |format|
      format.html { }
      format.js { render :action => :show, :layout => false }
    end
  end
  
  # Создаем новую заявку а обмен
  def create
    @claim = Claim.new params[:claim]
    @claim.request_options = parse_request
    
    if @claim.save
      flash[:notice] = 'Создана новая заявка'
      session[:claim_id] = @claim.id
      # Отправляем на заполнение параметров куда 
      # надо переводить денежные средства
      redirect_to url_for(@claim.filling_action)
    else
      flash[:error] = ["<ul>",@claim.errors.full_messages.collect{ |x| "<li>#{x}</li>"}, "</ul>"].join
      render :action => :index
    end
  end

  
  private
  
  # Параметры запроса
  def parse_request
    { 
      :ip => request.remote_ip,
      :params => request.params,
      :host => request.host,
      :format => request.format,
      :domain => request.domain
      
    }
  end
end
