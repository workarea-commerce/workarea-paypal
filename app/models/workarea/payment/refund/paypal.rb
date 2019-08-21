module Workarea
  class Payment
    class Refund
      class Paypal
        include OperationImplementation
        include CreditCardOperation

        def complete!
          validate_reference!

          transaction.response = handle_active_merchant_errors do
            Workarea::Paypal.gateway.refund(
              transaction.amount.cents,
              transaction.reference.response.params['transaction_id'],
              currency: transaction.amount.currency
            )
          end
        end

        def cancel!
          # noop
        end
      end
    end
  end
end
