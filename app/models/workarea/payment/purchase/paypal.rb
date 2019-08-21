module Workarea
  class Payment
    module Purchase
      class Paypal
        include OperationImplementation
        include CreditCardOperation

        delegate :gateway, to: Workarea::Paypal

        def complete!
          transaction.response = handle_active_merchant_errors do
            gateway.purchase(
              transaction.amount.cents,
              token: tender.token,
              payer_id: tender.payer_id,
              currency: transaction.amount.currency
            )
          end
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation = handle_active_merchant_errors do
            gateway.void(transaction.response.params['transaction_id'])
          end
        end
      end
    end
  end
end
