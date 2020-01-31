module Workarea
  module Paypal
    class Gateway
      class RequestError < StandardError; end

      def environment
        @environment =
          Workarea.config.paypal_environment.constantize.new(
            client_id,
            client_secret
          )
      end

      def client
        PayPal::PayPalHttpClient.new(environment)
      end

      # This gets a token required to render hosted fields. Not used for
      # smart payment buttons.
      def generate_token(user: nil)
        request = Workarea::Paypal::Requests::GenerateToken.new
        request.request_body(customer_id: user.id.to_s) if user.present?

        client.execute(request)
      end

      def get_order(order_id)
        request = PayPalCheckoutSdk::Orders::OrdersGetRequest.new(order_id)
        handle_connection_errors { client.execute(request) }
      end

      def create_order(body:)
        request = PayPalCheckoutSdk::Orders::OrdersCreateRequest.new
        request.request_body(body)

        # Do not change this
        request.headers["PayPal-Partner-Attribution-Id"] = 'Workarea_SP'

        handle_connection_errors do
          response = client.execute(request)
          response.result
        end
      end

      def update_order(order_id, body: {})
        request = PayPalCheckoutSdk::Orders::OrdersPatchRequest.new(order_id)
        request.request_body(body)

        handle_connection_errors do
          response = client.execute(request)
          response.result
        end
      end

      def capture(order_id)
        request = PayPalCheckoutSdk::Orders::OrdersCaptureRequest.new(order_id)
        request.prefer("return=representation")

        handle_transaction_errors do
          response = client.execute(request)
          capture = response.result
          success = response.status_code == 201

          ActiveMerchant::Billing::Response.new(
            success,
            "PayPal capture #{success ? 'succeeded' : 'failed'}",
            if success
              Paypal.transform_values(
                capture&.purchase_units&.first&.payments&.captures&.last
              )
            else
              Paypal.transform_values(capture)
            end
          )
        end
      end

      # No body means refunding the entire captured amount, otherwise an amount
      # object needs to be supplied.
      #
      def refund(capture_id, amount: nil)
        request = PayPalCheckoutSdk::Payments::CapturesRefundRequest.new(capture_id)
        request.prefer("return=representation")

        if amount.present?
          request.request_body(
            amount: {
              value: amount.to_s,
              currency: amount.currency.iso_code
            }
          )
        end

        handle_transaction_errors do
          response = client.execute(request)
          refund = response.result
          success = response.status_code == 201 && refund.status != 'CANCELLED'

          ActiveMerchant::Billing::Response.new(
            success,
            "PayPal refund #{success ? 'succeeded' : 'failed'}",
            {
              id: refund.id,
              status: refund.status,
              status_details: refund.status_details.to_h,
              capture_id: capture_id,
              amount: amount.to_s
            }
          )
        end
      end

      def create_webhook(url:, event_types:)
        request = Workarea::Paypal::Requests::CreateWebhook.new
        request.request_body(
          url: url,
          event_types: Array.wrap(event_types).map { |type| { name: type } }
        )

        response = handle_connection_errors { client.execute(request) }

        throw_request_error(response) unless response.status_code == 201
        response
      end

      def delete_webhook(webhook_id)
        request = Workarea::Paypal::Requests::DeleteWebhook.new(webhook_id)
        response = handle_connection_errors { client.execute(request) }

        throw_request_error(response) unless response.status_code == 204
        response
      end

      def list_webhooks
        request = Workarea::Paypal::Requests::ListWebhooks.new
        response = handle_connection_errors { client.execute(request) }

        throw_request_error(response) unless response.status_code == 200
        response
      end

      def configured?
        client_id.present? && client_secret.present?
      end

      def client_id
        ENV['WORKAREA_PAYPAL_CLIENT_ID'].presence ||
          Rails.application.credentials.paypal.try(:[], :client_id) ||
          Workarea.config.paypal[:client_id]
      end

      private

      def client_secret
        ENV['WORKAREA_PAYPAL_CLIENT_SECRET'].presence ||
          Rails.application.credentials.paypal.try(:[], :client_secret) ||
          Workarea.config.paypal[:client_secret]
      end

      def throw_request_error(error)
        raise RequestError.new(
          I18n.t(
            'workarea.paypal.gateway.http_error',
            status: error.status_code,
            debug_id: error.headers['paypal-debug-id']
          )
        )
      end

      def handle_connection_errors
        begin
          yield
        rescue PayPalHttp::HttpError => error
          Rails.logger.error(error.message)
          Rails.logger.error(error.result)
          throw_request_error(error)
        end
      end

      def handle_transaction_errors
        begin
          yield
        rescue PayPalHttp::HttpError => error
          ActiveMerchant::Billing::Response.new(
            false,
            error.message,
            status_code: error.status_code,
            debug_id: error.headers['paypal-debug-id']
          )
        rescue StandardError => error
          ActiveMerchant::Billing::Response.new(false, error.message, {})
        end
      end
    end
  end
end
