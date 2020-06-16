Workarea::Storefront::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    post 'paypal' => 'paypal#create'
    put 'paypal/:id/approved' => 'paypal#update', as: :paypal_approved
    post 'paypal/event' => 'paypal#event', as: :paypal_event
  end
end
