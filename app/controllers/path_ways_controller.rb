=begin rdoc
Только для вывода списка валют, на которые можно делать обмен.
=end
class PathWaysController < ApplicationController
  def show
    
    unless params[:currency].blank?
      @currency = PathWay.get_currency_for_source(params[:currency]).collect{ |x| [x.currency_receiver.name, x.currency_receiver.id, x.rate] }
      @reserv = Currency.find(params[:currency]).payment_system.reserve rescue 0
    else
      @currency = [] 
    end

    respond_to do |format|
      format.html
      format.js { render :action => :show, :layout => false }
    end

  end
end
