module Workarea
  module Paypal
    class UpdateOrder
      delegate :order, :user, :payment, :shippings, :shipping, to: :@checkout
      delegate :paypal_id, to: :payment, allow_nil: true

      def initialize(checkout)
        @checkout = checkout
      end

      def create
        @create ||= Paypal::CreateOrder.new(@checkout)
      end

      def perform
        return false unless payment.paypal?

        Paypal.gateway.update_order(paypal_id, body: request_body)
      end

      def request_body
        shipping = create.shipping_info

        [
          {
            op: 'replace',
            path: "/purchase_units/@reference_id=='default'/shipping/name",
            value: shipping[:name]
          },
          {
            op: 'replace',
            path: "/purchase_units/@reference_id=='default'/shipping/address",
            value: shipping[:address]
          },
          {
            op: 'replace',
            path: "/purchase_units/@reference_id=='default'/amount",
            value: create.amount
          }
        ]
      end
    end
  end
end
