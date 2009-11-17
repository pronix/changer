ActionController::Routing::Routes.draw do |map|

  map.root :controller => :claims, :action => :index
  map.resource :claims, :only => [:new, :create, :show, :index]
  map.resources :path_ways
  
  map.namespace :gateway  do |gateway|
    gateway.resource :webmoney, :controller => "webmoney", :collection => { :confirmed => :any }
    gateway.resource :paypal, :controller => "paypal"
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
