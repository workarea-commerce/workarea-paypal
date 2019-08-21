require 'test_helper'

module Workarea
  class Payment
    module Purchase
      class PaypalTest < Workarea::TestCase
        delegate :gateway, to: Workarea::Paypal

        def payment
          @payment ||= create_payment
        end

        def authorization
          @authorization ||= ActiveMerchant::Billing::BogusGateway::AUTHORIZATION
        end

        def tender
          @tender ||=
            begin
              payment.set_address(first_name: 'Ben', last_name: 'Crouse')
              payment.build_paypal(token: '1234', payer_id: 'pid')
              payment.paypal
            end
        end

        def transaction
          @transaction ||= tender.transactions.build(
            action: 'purchase',
            amount: 5.to_m
          )
        end

        def test_complete_purchases_on_the_gateway
          operation = Paypal.new(tender, transaction)

          gateway.expects(:purchase)

          operation.complete!
        end

        def test_complete_sets_the_response_on_the_transaction
          operation = Paypal.new(tender, transaction)
          operation.complete!

          assert_instance_of(
            ActiveMerchant::Billing::Response,
            transaction.response
          )
        end

        def test_cancel_does_nothing_if_the_transaction_was_a_failure
          transaction.success = false
          operation = Paypal.new(tender, transaction)

          operation.gateway.expects(:void).never
          operation.cancel!
        end

        def test_cancel_voids_with_the_authorization_from_the_transaction
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            'Message',
            'transaction_id' => authorization
          )

          operation = Paypal.new(tender, transaction)

          operation
            .gateway
            .expects(:void)
            .with(authorization)

          operation.cancel!
        end

        def test_cancel_sets_cancellation_params_on_the_transaction
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            'Message',
            'transaction_id' => authorization
          )

          operation = Paypal.new(tender, transaction)
          operation.cancel!

          assert_instance_of(
            ActiveMerchant::Billing::Response,
            transaction.cancellation
          )
        end
      end
    end
  end
end
