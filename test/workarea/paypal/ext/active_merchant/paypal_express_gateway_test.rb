require 'test_helper'

module ActiveMerchant
  module Billing
    class PaypalExpressGatewayTest < Workarea::TestCase
      def test_add_button_source
        xml = Builder::XmlMarkup.new
        gateway = PaypalExpressGateway.new(login: 'w', password: 'a', signature: 'p')

        assert_equal(
          '<n2:ButtonSource>Workarea_SP</n2:ButtonSource>',
          gateway.add_button_source(xml)
        )
      end
    end
  end
end
