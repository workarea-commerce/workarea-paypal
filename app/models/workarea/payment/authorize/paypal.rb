module Workarea
  class Payment
    module Authorize
      class Paypal
        include OperationImplementation

        def complete!
          transaction.action = 'purchase'
          transaction.response =
            Workarea::Paypal.gateway.capture(tender.paypal_id)
        end

        def cancel!
          return unless transaction.success?

          transaction.cancellation =
            Workarea::Paypal.gateway.refund(
              transaction.response.params['id'],
              amount: transaction.amount
            )
        end
      end
    end
  end
end
