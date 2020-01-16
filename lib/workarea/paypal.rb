require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

require 'paypal-checkout-sdk'
require 'workarea/paypal/requests/generate_token'
require 'workarea/paypal/gateway'

module Workarea
  module Paypal
    class << self
      delegate :client, to: :gateway

      def gateway
        Workarea::Paypal::Gateway.new
      end

      def transform_values(value)
        case value
        when OpenStruct
          transform_values(value.to_h)
        when Hash
          value.transform_values(&method(:transform_values))
        when Array
          value.map(&method(:transform_values))
        else
          value
        end
      end
    end
  end
end

require 'workarea/paypal/version'
require 'workarea/paypal/engine'
