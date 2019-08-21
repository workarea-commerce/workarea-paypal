module Workarea
  module Paypal
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Paypal
    end
  end
end
