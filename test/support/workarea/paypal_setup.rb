module Workarea
  module PaypalSetup
    extend ActiveSupport::Concern

    included do
      setup :set_paypal_credentials
      teardown :reset_paypal_credentials
    end

    def set_paypal_credentials
      @env_paypal_client_id = ENV['WORKAREA_PAYPAL_CLIENT_ID']
      @env_paypal_client_secret = ENV['WORKAREA_PAYPAL_CLIENT_SECRET']

      # If you need to re-record any VCR cassettes, you will need to replace
      # these will real credentials, then update the OAuth request's
      # basic auth header to use these credentials, base64 encoded 'ID:SECRET',
      # in the recorded request to prevent committing real credentials.
      #
      ENV['WORKAREA_PAYPAL_CLIENT_ID'] = 'FAKE_PAYPAL_CLIENT_ID'
      ENV['WORKAREA_PAYPAL_CLIENT_SECRET'] = 'FAKE_PAYPAL_CLIENT_SECRET'
    end

    def reset_paypal_credentials
      ENV['WORKAREA_PAYPAL_CLIENT_ID'] = @env_paypal_client_id
      ENV['WORKAREA_PAYPAL_CLIENT_SECRET'] = @env_paypal_client_secret
    end

    def checkout
      @order ||= begin
        create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])
        create_tax_category(name: 'Sales Tax', code: '001')
        Pricing::Sku.find('SKU').update!(tax_code: '001')

        order = create_order(id: 'PAYPAL_TEST', email: 'test@workarea.com')
        order.add_item(
          { sku: 'SKU', quantity: 2 }.merge(OrderItemDetails.find('SKU').to_h)
        )

        Checkout.new(order).tap do |checkout|
          checkout.update(
            shipping_address: factory_defaults(:shipping_address),
            billing_address: factory_defaults(:billing_address),
            shipping_service: create_shipping_service(name: 'Ground').name
          )
        end
      end
    end
  end
end
