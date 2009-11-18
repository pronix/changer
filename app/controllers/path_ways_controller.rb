class PathWaysController < ApplicationController
  def show
    unless params[:currency].blank?
      @currency = PathWay.get_currency_for_source(params[:currency]).collect{ |x| x.currency_receiver}
    else
      @currency = Currency.all 
    end

    respond_to do |format|
      format.html
      format.js { render :action => :show, :layout => false }
    end

  end
end
