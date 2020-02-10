
module Workarea
  module Factories
    module Paypal
      Factories.add(self)

      def webhook_capture_completed_payload
        JSON.parse(File.read(webhook_capture_completed_path))
      end

      def webhook_capture_completed_path
        Workarea::Paypal::Engine.root.join(
          'test',
          'factories',
          'workarea',
          'capture_completed_webhook.json'
        )
      end

      def webhook_capture_denied_payload
        JSON.parse(File.read(webhook_capture_denied_path))
      end

      def webhook_capture_denied_path
        Workarea::Paypal::Engine.root.join(
          'test',
          'factories',
          'workarea',
          'capture_denied_webhook.json'
        )
      end
    end
  end
end
