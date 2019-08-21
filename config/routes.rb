Workarea::Storefront::Engine.routes.draw do
  get 'paypal/start' => 'paypal#start', as: :start_paypal
  get 'paypal/complete/:order_id' => 'paypal#complete', as: :complete_paypal
end
