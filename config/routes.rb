Spree::Core::Engine.add_routes do
  get '/payumoney', :to => "payumoney#index", :as => :payumoney_proceed
  post '/payumoney/confirm', :to => "payumoney#confirm", :as => :payumoney_confirm
  post '/payumoney/cancel', :to => "payumoney#cancel", :as => :payumoney_cancel
end
