ActionController::Routing::Routes.draw do |map|

  map.root :controller => :claims, :action => :index
  map.resource :claims, :only => [:new, :create, :show, :index]
  map.resource :path_ways
  
  map.namespace :gateway  do |gateway|
    { 
      :webmoney => { }, :paypal =>   { }
    }.each do |payment, opt|
      gateway.resource payment, :controller => payment,
      :collection => { :confirmed => :any , :pay => :any }.merge!(opt)
    end
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
