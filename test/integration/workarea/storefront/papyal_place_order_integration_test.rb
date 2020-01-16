require 'test_helper'

module Workarea
  module Storefront
    class PaypalPlaceOrderIntegrationTest < Workarea::IntegrationTest
      def test_place_order_with_paypal
        product = create_product(variants: [{ sku: 'SKU1', regular: 5.to_m }])

        post storefront.cart_items_path, params: {
          product_id: product.id,
          sku: product.skus.first,
          quantity: 2
        }

        patch storefront.checkout_addresses_path,
          params: {
            email: 'test@workarea.com',
            billing_address: factory_defaults(:billing_address),
            shipping_address: factory_defaults(:shipping_address)
          }

        patch storefront.checkout_place_order_path, params: { payment: 'paypal' }
        assert_redirected_to(storefront.checkout_payment_path)
        assert_equal(t('workarea.storefront.paypal.errors.place_order'), flash[:info])

        Paypal::UpdateOrder.any_instance.expects(:perform).returns(true)
        Workarea::Checkout.any_instance.stubs(:place_order).returns(true)

        jar = ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
        payment = Workarea::Payment.find_or_create_by(id: jar.signed[:order_id])
        payment.set_paypal(
          paypal_id: '123',
          payer_id: 'abc',
          approved: true
        )

        patch storefront.checkout_place_order_path, params: { payment: 'paypal' }
        assert_redirected_to(storefront.checkout_confirmation_path)
      end
    end
  end
end
