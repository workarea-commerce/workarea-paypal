Workarea::Plugin.append_partials(
  'storefront.cart_checkout_actions',
  'workarea/storefront/carts/paypal_checkout'
)

Workarea::Plugin.append_partials(
  'storefront.payment_error',
  'workarea/storefront/checkouts/paypal_error'
)

Workarea::Plugin.append_partials(
  'storefront.payment_method',
  'workarea/storefront/checkouts/paypal_payment'
)

Workarea::Plugin.append_javascripts(
  'storefront.modules',
  'workarea/storefront/paypal/modules/update_checkout_submit_text'
)
