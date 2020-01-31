
Workarea.configure do |config|
  config.tender_types << :paypal

  # Determines which environment class to use. The PayPal SDK requires the
  # use of different classes depending on the type of environment you are
  # interacting with. By default, sandbox will be used unless in production.
  # This behavior can be changed within your application by redefining this
  # configuration.
  #
  config.paypal_environment =
    if Rails.env.production?
      'Paypal::LiveEnvironment'
    else
      'PayPal::SandboxEnvironment'
    end

  # PayPal credentials can be configured via environment variables:
  #   WORKAREA_PAYPAL_CLIENT_ID
  #   WORKAREA_PAYPAL_CLIENT_SECRET
  #
  # via rails credentials:
  #   paypal:
  #     client_id: YOUR_CLIENT_ID
  #     client_secret: YOUR_CLIENT_SECRET
  #
  # Or through the workarea configuration object. Setting credentials through
  # the configuration allows for dyanmically changing credentials if, for
  # example, you are using the multi-site plugin and wish to use different
  # PayPal accounts for some or all sites.
  #
  config.paypal = {
    # client_id: YOUR_CLIENT_ID,
    # client_secret: YOUR_CLIENT_SECRET
  }

  # Parameters passed as a query string to the paypal javascript sdk script
  # when loaded on the storefront. This can be used to customize settings and
  # display options.
  # See https://developer.paypal.com/docs/checkout/reference/customize-sdk/
  # for more information.
  #
  config.paypal_sdk_params = {
    commit: false,
    debug: Rails.env.development?
  }

  # Enable/Disable paypal as your credit card processor. This will enable
  # code that takes over the credit card fields during checkout and submits
  # payment info directly to paypal. You will need to enable unbranded credit
  # cards through PayPal. Contact PayPal directly for more information.
  #
  config.use_paypal_hosted_fields = false

  # Events to register a webhook for when running the rake tasks to setup
  # webhooks, workarea:payal:create_webhooks.
  #
  config.default_webhook_events = %w(
    PAYMENT.CAPTURE.COMPLETED
    PAYMENT.CAPTURE.DENIED
  )
end
