module Workarea
  module Paypal
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Paypal

      config.to_prepare do
        Storefront::ApplicationController.helper(Storefront::PaypalHelper)
      end
    end
  end
end
