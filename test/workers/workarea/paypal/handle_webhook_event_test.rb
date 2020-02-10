require 'test_helper'

module Workarea
  module Paypal
    class HandleWebhookEventTest < TestCase
      setup :payment

      def payment
        @payment ||=
          create_payment(paypal: { paypal_id: '123', approved: true }).tap do |p|
            p.paypal.build_transaction(
              action: 'authorize',
              amount: 5.to_m,
              response: ActiveMerchant::Billing::Response.new(
                true,
                'PayPal capture succeeded',
                id: 'CAPTURE001',
                status: 'PENDING'
              )
            ).save!
          end
      end

      def test_payment_capture_completed
        payload = webhook_capture_completed_payload

        HandleWebhookEvent.new.perform(
          payload['event_type'],
          payload['resource']
        )

        payment.reload

        assert_equal(2, payment.paypal.transactions.count)

        txn = payment.paypal.transactions.captures.first
        assert(txn.success?)
        assert_equal(5.to_m, txn.amount)
      end

      def test_payment_capture_denied
        payload = webhook_capture_denied_payload

        HandleWebhookEvent.new.perform(
          payload['event_type'],
          payload['resource']
        )

        payment.reload

        assert_equal(1, payment.paypal.transactions.count)

        txn = payment.paypal.transactions.first
        assert(txn.success?)
        assert(txn.canceled?)
        assert(txn.cancellation.success?)
      end
    end
  end
end
