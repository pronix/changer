ActionController::Routing::Routes.draw do |map|

  map.root :controller => :claims, :action => :index
  map.resource :claims
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
