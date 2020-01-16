module Workarea
  class Payment
    class Capture
      class Paypal
        include OperationImplementation

        def complete!
          # Capture can only happen if the initial capture was not completed
          # immediately. Since we cannot force a pending capture to complete,
          # this will only fail with an explanation that the capture will
          # complete via webhook or never be completed.
          #
          transaction.response = ActiveMerchant::Billing::Response.new(
            false,
            I18n.t('workarea.payment.paypal_capture')
          )
        end

        def cancel!
          # noop, nothing to cancel
        end
      end
    end
  end
end
