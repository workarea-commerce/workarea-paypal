require 'test_helper'

module Workarea
  class Payment
    module Authorize
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
            amount: 5.to_m
          )
        end

        def stubbed_capture
          @stubbed_capture ||= OpenStruct.new(
            status_code: 201,
            result: PayPalHttp::HttpClient.new(nil)._parse_values(
              purchase_units: [{ payments: { captures: [{ id: 'CAPTURE_0001' }] } }]
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
          PayPal::PayPalHttpClient.any_instance.expects(:execute).returns(stubbed_capture)

          operation = Paypal.new(tender, transaction)
          operation.complete!

          assert_equal('purchase', transaction.action)
          assert(transaction.response.success?)
          assert(transaction.response.message.present?)
          assert(transaction.response.params.present?)

          PayPal::PayPalHttpClient.any_instance.unstub
          PayPal::PayPalHttpClient.any_instance.expects(:execute).returns(stubbed_refund)

          operation.cancel!
          assert(transaction.cancellation.success?)
          assert(transaction.cancellation.message.present?)
          assert_equal('CAPTURE_0001', transaction.cancellation.params['capture_id'])
        end

        def test_complete_failure
          stubbed_capture.status_code = 500
          PayPal::PayPalHttpClient.any_instance.expects(:execute).returns(stubbed_capture)

          operation = Paypal.new(tender, transaction)
          operation.complete!

          assert_equal('purchase', transaction.action)
          refute(transaction.response.success?)
          assert(transaction.response.message.present?)
          assert(transaction.response.params.present?)

          PayPal::PayPalHttpClient.any_instance.unstub
          PayPal::PayPalHttpClient.any_instance.expects(:execute).never

          operation.cancel!
          assert_nil(transaction.cancellation)
        end
      end
    end
  end
end
