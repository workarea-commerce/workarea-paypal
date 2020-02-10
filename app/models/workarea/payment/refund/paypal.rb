module Workarea
  class Payment
    class Refund
      class Paypal
        include OperationImplementation

        def complete!
          validate_reference!

          transaction.response =
            Workarea::Paypal.gateway.refund(
              transaction.reference.response.params['id'],
              amount: transaction.amount
            )
        end

        def cancel!
          # noop
        end
      end
    end
  end
end
