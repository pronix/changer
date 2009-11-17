class PathWaysController < ApplicationController
  def show
    # @currency = PathWay.
    case params[:currency]
    when /source/
      @currency = PathWay.get_currency_for_source(params[:id]).collect{ |x| x.currency_receiver}
    when /receiver/
      @currency = PathWay.get_currency_for_receiver(params[:id]).collect{ |x| x.currency_source}
    else
      @currency = []
    end
    respond_to do |format|
      format.html
      format.js { render :action => :show, :layout => false }
    end

  end
end
