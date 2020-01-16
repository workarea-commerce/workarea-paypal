Workarea::Plugin.append_partials(
  'storefront.document_head',
  'workarea/storefront/paypal/paypal_sdk'
)

Workarea::Plugin.append_partials(
  'storefront.cart_show',
  'workarea/storefront/carts/paypal_checkout'
)

Workarea::Plugin.append_partials(
  'storefront.payment_method',
  'workarea/storefront/checkouts/paypal_payment'
)

Workarea::Plugin.append_javascripts(
  'storefront.config',
  'workarea/storefront/paypal/config'
)

Workarea::Plugin.append_javascripts(
  'storefront.templates',
  'workarea/storefront/paypal/templates/paypal_fields'
)

Workarea::Plugin.append_javascripts(
  'storefront.modules',
  'workarea/storefront/paypal/modules/update_checkout_submit_text',
  'workarea/storefront/paypal/modules/paypal_buttons',
  'workarea/storefront/paypal/modules/paypal_hosted_fields'
)
