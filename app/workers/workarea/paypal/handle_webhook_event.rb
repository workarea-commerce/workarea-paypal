module Workarea
  module Paypal
    class HandleWebhookEvent
      include Sidekiq::Worker

      def perform(event, resource)
        event_method = event.optionize
        return send(event_method, resource) if respond_to?(event_method)

        logger.error("FAILED: #{event} webhook is not supported.")
      end

      def payment_capture_completed(resource)
        transaction = Payment::Transaction.where(
          'response.params.id' => resource['id']
        ).first

        if transaction.nil?
          logger.error("FAILED: Transaction with capture ID of #{resource['id']} does not exist.")
          return
        end

        tender = transaction.payment.tenders.detect do |t|
          t.id.to_s == transaction.tender_id
        end
        return unless tender.present?

        amount = resource['amount']
        txn = tender.build_transaction(
          action: 'capture',
          success: true,
          reference: transaction,
          amount: amount['value'].to_m(amount['currency_code']),
          response: ActiveMerchant::Billing::Response.new(
            true,
            'Paypal capture was confirmed.',
            resource
          )
        )

        txn.save!
      end

      def payment_capture_denied(resource)
        transaction = Payment::Transaction.where(
          'response.params.id' => resource['id']
        ).first

        if transaction.nil?
          logger.error("FAILED: Transaction with capture ID of #{resource['id']} does not exist.")
          return
        end

        transaction.cancellation = ActiveMerchant::Billing::Response.new(
          true,
          "PayPal capture was denied",
          resource
        )
        transaction.canceled_at = Time.current
        transaction.save!
      end
    end
  end
end
