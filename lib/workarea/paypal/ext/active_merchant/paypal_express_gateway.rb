module ActiveMerchant
  module Billing
    decorate PaypalExpressGateway, with: :workarea do
      def add_button_source(xml)
        xml.tag! 'n2:ButtonSource', 'Workarea_SP'
      end
    end
  end
end
