module Workarea
  class Payment
    class Capture
      class Paypal
        include OperationImplementation
        include CreditCardOperation

        delegate :gateway, to: Workarea::Paypal

        def complete!
          validate_reference!

          transaction.response = handle_active_merchant_errors do
            gateway.capture(
              transaction.amount.cents,
              transaction.reference.response.params['transaction_id'],
              currency: transaction.amount.currency
            )
          end
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation = handle_active_merchant_errors do
            gateway.refund(
              transaction.amount.cents,
              transaction.response.params['transaction_id']
            )
          end
        end
      end
    end
  end
end
