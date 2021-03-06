ActionController::Routing::Routes.draw do |map|

  map.root :controller => :claims, :action => :index
  map.resource :claims, :only => [:new, :create, :index]
  map.resource :path_ways, :only => [:show]
  
  map.namespace :gateway  do |gateway|
    { 
      :webmoney => { :payment_result => :any, :payment_success => :any, :payment_fail => :any },
      :paypal =>   { :notify => :any, :done => :any }
    }.each do |payment, opt|
      gateway.resource payment, :controller => payment,
      :collection => { :confirmed => :any , :pay => :any }.merge!(opt)
    end
  end
  
  map.namespace :admin do |admin| 
    admin.resources :payment_systems, :only => [:new, :create, :edit, :update, :index]
    admin.resources :system_settings, :only => [:new, :create, :edit, :update, :index]
    admin.resources :currencies, :only => [:new, :create, :edit, :update, :index]    
    admin.resources :claims, :only => [ :index]        
  end  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
