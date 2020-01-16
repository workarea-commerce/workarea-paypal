Workarea::Storefront::Engine.routes.draw do
  post 'paypal' => 'paypal#create'
  put 'paypal/:id/approved' => 'paypal#update', as: :paypal_approved
end
