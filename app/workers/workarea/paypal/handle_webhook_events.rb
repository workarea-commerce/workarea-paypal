module Workarea
  module Paypal
    class HandleWebhookEvents
      include Sidekiq::Worker

      def perform(event, payload)
        event_method = event.optionize
        return send(event_method, payload) if respond_to?(event_method)

        puts "#{event} webhook is not supported."
      end

      def payment_catpure_completed(resource)
        # cool, do not think we really _need_ to do anything here.
      end

      def payment_capture_denied(resource)
        # idk what to do here
      end
    end
  end
end
