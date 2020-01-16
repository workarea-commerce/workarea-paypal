require 'test_helper'

module Workarea
  class Payment
    class Refund
      class PaypalTest < Workarea::TestCase
        def payment
          @payment ||= create_payment
        end

        def tender
          @tender ||=
            begin
              payment.build_paypal(paypal_id: '1234', payer_id: 'pid')
              payment.paypal
            end
        end

        def transaction
          @transaction ||= tender.transactions.build(
            action: 'authorize',
            amount: 5.to_m,
            reference: tender.build_transaction(
              action: 'purchase',
              amount: 5.to_m,
              response: ActiveMerchant::Billing::Response.new(
                true,
                'PayPal capture succeeded',
                id: 'CAPTURE_0001'
              )
            )
          )
        end

        def stubbed_refund
          @stubbed_refund ||= OpenStruct.new(
            status_code: 201,
            result: OpenStruct.new(
              id: 'REFUND_0001',
              status: 'COMPLETED',
            )
          )
        end

        def test_complete_success
          PayPal::PayPalHttpClient.any_instance.expects(:execute).returns(stubbed_refund)

          operation = Paypal.new(tender, transaction)
          operation.complete!

          assert(transaction.response.success?)
          assert(transaction.response.message.present?)
          assert_equal('CAPTURE_0001', transaction.response.params['capture_id'])
        end

        def test_complete_failure
          stubbed_refund.status_code = 500
          PayPal::PayPalHttpClient.any_instance.expects(:execute).returns(stubbed_refund)

          operation = Paypal.new(tender, transaction)
          operation.complete!

          refute(transaction.response.success?)
          assert(transaction.response.message.present?)
          assert(transaction.response.params.present?)
        end
      end
    end
  end
end
