require 'test_helper'

module Workarea
  class Payment
    class Capture
      class PaypalTest < Workarea::TestCase
        delegate :gateway, to: Workarea::Paypal

        def authorization
          @authorization ||= ActiveMerchant::Billing::BogusGateway::AUTHORIZATION
        end

        def payment
          @payment ||=
            begin
              result = create_payment
              result.set_paypal(token: '1234', payer_id: 'pid')
              result
            end
        end

        def reference
          @reference ||= Transaction.new(
            amount: 5.to_m,
            response: ActiveMerchant::Billing::Response.new(
              true,
              'Message',
              'transaction_id' => authorization
            )
          )
        end

        def transaction
          @transaction ||= payment.paypal.transactions.build(
            amount: 5.to_m,
            reference: reference
          )
        end

        def test_complate_raises_if_the_reference_transaction_is_blank
          transaction.reference = nil
          operation = Paypal.new(payment.paypal, transaction)

          assert_raises(Payment::MissingReference) { operation.complete! }
        end

        def test_complete_captures_on_the_credit_card_gateway
          operation = Paypal.new(payment.paypal, transaction)

          gateway
            .expects(:capture)
            .with(500, authorization, currency: 'USD')

          operation.complete!
        end

        def test_complete_sets_the_response_on_the_transaction
          operation = Paypal.new(payment.paypal, transaction)
          operation.complete!

          assert_instance_of(
            ActiveMerchant::Billing::Response,
            transaction.response
          )
        end
      end
    end
  end
end
