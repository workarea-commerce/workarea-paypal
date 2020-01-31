Workarea::Storefront::Engine.routes.draw do
  post 'paypal' => 'paypal#create'
  put 'paypal/:id/approved' => 'paypal#update', as: :paypal_approved
  post 'paypal/event' => 'paypal#event', as: :paypal_event
end
