require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'
require 'workarea/paypal/ext/active_merchant/paypal_express_gateway'

module Workarea
  module Paypal
    def self.gateway
      Workarea.config.gateways.paypal
    end

    def self.gateway=(gateway)
      Workarea.config.gateways.paypal = gateway
    end

    def self.auto_configure_gateway
      if Rails.application.secrets.paypal.present?
        self.gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(
          Rails.application.secrets.paypal.deep_symbolize_keys
        )
      elsif gateway.blank?
        self.gateway = ActiveMerchant::Billing::BogusGateway.new
      end

      if ENV['HTTP_PROXY'].present? && gateway.present?
        parsed = URI.parse(ENV['HTTP_PROXY'])
        gateway.proxy_address = parsed.host
        gateway.proxy_port = parsed.port
      end
    end
  end
end

require 'workarea/paypal/version'
require 'workarea/paypal/engine'
