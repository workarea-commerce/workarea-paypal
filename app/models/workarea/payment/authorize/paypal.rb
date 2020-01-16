module Workarea
  class Payment
    module Authorize
      class Paypal
        include OperationImplementation

        def complete!
          response = Workarea::Paypal.gateway.capture(tender.paypal_id)

          if response.success? && response.params['status'] == 'PENDING'
            transaction.action = 'authorize'
          else
            transaction.action = 'purchase'
          end

          transaction.response = response
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
