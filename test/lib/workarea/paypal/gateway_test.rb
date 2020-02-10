require 'test_helper'

module Workarea
  module Paypal
    class GatewayTest < TestCase
      include PaypalSetup

      def gateway
        Paypal::Gateway.new
      end

      def body
        {
          intent: 'CAPTURE',
          purchase_units: [{
            amount: {
              currency_code: 'USD',
              value: '100.00'
            }
          }]
        }
      end

      def order_id
        VCR.use_cassette('paypal_gateway_create_order') do
          gateway.create_order(body: body).id
        end
      end

      def test_generate_token
        response = VCR.use_cassette('paypal_gateway_generate_token') do
          gateway.generate_token
        end

        assert(response.result.client_token.present?)
      end

      def test_get_order
        response = VCR.use_cassette('paypal_gateway_get_order') do
          gateway.get_order(order_id)
        end

        assert_equal(200, response.status_code)
        assert_equal(order_id, response.result.id)
        assert(response.result.purchase_units.first.present?)
      end

      def test_create_order
        response = VCR.use_cassette('paypal_gateway_create_order') do
          gateway.create_order(body: body)
        end

        assert_equal('CREATED', response.status)
        assert(response.id.present?)
      end

      def test_update_order
        body = [
          {
            op: 'replace',
            path: "/purchase_units/@reference_id=='default'/amount",
            value: {
              currency_code: 'USD',
              value: '125.00'
            }
          }
        ]

        VCR.use_cassette('paypal_gateway_update_order') do
          response = gateway.update_order(order_id, body: body)

          response = gateway.get_order(order_id)
          assert_equal(200, response.status_code)
          assert_equal('125.00', response.result.purchase_units.first.amount.value)
        end
      end


      def test_capture
        stubbed_response = OpenStruct.new(
          status_code: 201,
          result: PayPalHttp::HttpClient.new(nil)._parse_values(
            purchase_units: [
              {
                payments: {
                  captures: [{ id: 'CAPTURE_0001', status: 'COMPLETED' }]
                }
              }
            ]
          )
        )

        PayPal::PayPalHttpClient.any_instance.expects(:execute).returns(stubbed_response)

        result = gateway.capture('1234')
        assert(result.success?)
        assert_equal('PayPal capture succeeded', result.message)
        assert_equal({ 'id' => 'CAPTURE_0001', 'status' => 'COMPLETED' }, result.params)

        stubbed_response.result.purchase_units.first.payments.captures.first.status = 'DECLINED'
        PayPal::PayPalHttpClient.any_instance.unstub
        PayPal::PayPalHttpClient.any_instance.expects(:execute).returns(stubbed_response)

        result = gateway.capture('1234')
        refute(result.success?)
        assert_equal('PayPal capture failed', result.message)

        stubbed_response.status_code = 422
        stubbed_response.result.purchase_units.first.payments.captures.first.status = 'COMPLETED'
        PayPal::PayPalHttpClient.any_instance.unstub
        PayPal::PayPalHttpClient.any_instance.expects(:execute).returns(stubbed_response)

        result = gateway.capture('1234')
        refute(result.success?)
        assert_equal('PayPal capture failed', result.message)
        assert_equal(
          { 'purchase_units' => [
              { payments: { captures: [{ id: "CAPTURE_0001", status: 'COMPLETED' }] } }
            ]
          },
          result.params
        )

        PayPal::PayPalHttpClient.any_instance.unstub
        PayPal::PayPalHttpClient.any_instance.expects(:execute).raises(
          PayPalHttp::HttpError.new(422, {}, { 'paypal-debug-id' => '123' })
        )

        result = gateway.capture('1234')
        refute(result.success?)
        assert_equal({ 'status_code' => 422, 'debug_id' => '123' }, result.params)

        PayPal::PayPalHttpClient.any_instance.unstub
        PayPal::PayPalHttpClient.any_instance.expects(:execute).raises(
          StandardError.new('failed')
        )

        result = gateway.capture('1234')
        refute(result.success?)
        assert_equal('failed', result.message)
        assert(result.params.blank?)
      end


      def test_refund
        stubbed_response = OpenStruct.new(
          status_code: 201,
          result: OpenStruct.new(
            id: 'REFUND_0001',
            status: 'COMPLETED',
            status_details: { reason: 'test test' }
          )
        )

        PayPal::PayPalHttpClient
          .any_instance
          .expects(:execute)
          .returns(stubbed_response)

        result = gateway.refund('1234')
        assert(result.success?)
        assert_equal('PayPal refund succeeded', result.message)
        assert_equal(
          {
            'id' => 'REFUND_0001',
            'status' => 'COMPLETED',
            'status_details' => { reason: 'test test' },
            'capture_id' => '1234',
            'amount' => ''
          },
          result.params
        )

        PayPal::PayPalHttpClient.any_instance.unstub
        PayPal::PayPalHttpClient
          .any_instance
          .expects(:execute)
          .with { |req| assert_equal('50.00', req.body[:amount][:value]) }
          .returns(stubbed_response)

        result = gateway.refund('1234', amount: 50.to_m)
        assert(result.success?)
        assert_equal('PayPal refund succeeded', result.message)
        assert_equal(
          {
            'id' => 'REFUND_0001',
            'status' => 'COMPLETED',
            'status_details' => { reason: 'test test' },
            'capture_id' => '1234',
            'amount' => '50.00'
          },
          result.params
        )
      end

      def test_webhooks
        VCR.use_cassette('paypal_gateway_webhooks') do
          webhook = gateway.create_webhook(
            url: 'https://example.com/my-webhooks',
            event_types: %w(
              PAYMENT.CAPTURE.COMPLETED
              PAYMENT.CAPTURE.DENIED
            )
          ).result

          assert(webhook.id.present?)
          assert_equal('https://example.com/my-webhooks', webhook.url)

          list = gateway.list_webhooks.result.webhooks

          assert_equal(1, list.length)
          assert_equal(webhook.id, list.first.id)

          gateway.delete_webhook(webhook.id)

          list = gateway.list_webhooks.result.webhooks
          assert_equal(0, list.length)
        end
      end

      def test_client_id
        ENV['WORKAREA_PAYPAL_CLIENT_ID'] = nil

        if Rails.application.credentials.paypal.present?
          assert(Rails.application.credentials.paypal[:client_id], gateway.client_id)
        elsif Workarea.config.paypal.try(:[], :client_id).present?
          assert(Workarea.config.paypal[:client_id], gateway.client_id)
        end

        ENV['WORKAREA_PAYPAL_CLIENT_ID'] = 'abc123'

        assert('abc123', gateway.client_id)
      end
    end
  end
end
