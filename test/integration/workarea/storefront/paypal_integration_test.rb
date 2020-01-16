require 'test_helper'

module Workarea
  module Storefront
    class PaypalIntengrationTest < Workarea::IntegrationTest
      def assert_paypal_create_order
        Paypal::CreateOrder.any_instance.expects(:perform)
          .returns(OpenStruct.new(id: 'test123'))
      end

      def assert_paypal_approve_order
        Paypal::ApproveOrder.any_instance.expects(:perform).returns(true)
      end

      def order
        @order ||= create_order
      end

      def product
        @product ||= create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )
      end

      def add_item_to_cart
        post storefront.cart_items_path, params: {
          product_id: product.id,
          sku: product.skus.first,
          quantity: 2
        }
      end

      def test_create_starts_checkout_when_guest
        add_item_to_cart
        Workarea::Checkout.any_instance.expects(:start_as).with(:guest)
        assert_paypal_create_order

        post storefront.paypal_path, xhr: true
      end

      def test_create_starts_checkout_when_logged_in
        add_item_to_cart

        user = create_user(email: 'test@workarea.com')
        set_current_user(user)

        Workarea::Checkout.any_instance.expects(:start_as).with(user)
        assert_paypal_create_order

        post storefront.paypal_path, xhr: true
      end

      def test_create_does_not_start_checkout_from_checkout
        add_item_to_cart
        Workarea::Order.last.touch_checkout!

        Workarea::Checkout.any_instance.expects(:start_as).never
        assert_paypal_create_order

        post storefront.paypal_path, xhr: true
      end

      def test_create_success
        add_item_to_cart

        Workarea::Pricing.expects(:perform)
        assert_paypal_create_order

        post storefront.paypal_path, xhr: true

        json = JSON.parse(response.body)
        assert(json['id'].present?)
      end

      def test_create_failure
        add_item_to_cart

        Paypal::CreateOrder.any_instance.expects(:perform).raises(
          Paypal::Gateway::RequestError.new('failed')
        )

        post storefront.paypal_path, xhr: true

        assert_equal(500, response.status)
        assert(flash[:error].present?)
      end

      def test_update_success
        add_item_to_cart

        PaypalController.any_instance.expects(:check_inventory).returns(true)
        Paypal::ApproveOrder.any_instance.expects(:perform).returns(true)
        Workarea::Checkout.any_instance.expects(:complete?).returns(true)

        put storefront.paypal_approved_path('1234'), xhr: true

        json = JSON.parse(response.body)
        assert(json['success'])
        assert_equal(storefront.checkout_payment_path, json['redirect_url'])
      end

      def test_update_failure
        add_item_to_cart

        PaypalController.any_instance.expects(:check_inventory).returns(true)
        Paypal::ApproveOrder.any_instance.expects(:perform).returns(true)
        Workarea::Checkout.any_instance.expects(:complete?).returns(false)

        put storefront.paypal_approved_path('1234'), xhr: true

        json = JSON.parse(response.body)
        refute(json['success'])
        assert(flash[:error].present?)
      end

      def test_events
        payment = create_payment(paypal: { paypal_id: '123', approved: true }).tap do |p|
          p.paypal.build_transaction(
            action: 'authorize',
            amount: 5.to_m,
            response: ActiveMerchant::Billing::Response.new(
              true,
              'PayPal capture succeeded',
              id: 'CAPTURE001',
              status: 'PENDING'
            )
          ).save!
        end

        post storefront.paypal_event_path,
             params: webhook_capture_completed_payload

        assert(response.ok?)

        payment.reload

        assert_equal(2, payment.paypal.transactions.count)

        txn = payment.paypal.transactions.captures.first
        assert(txn.success?)
        assert_equal(5.to_m, txn.amount)
      end
    end
  end
end
