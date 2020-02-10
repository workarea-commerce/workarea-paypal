Workarea::Configuration.define_fields do
  fieldset 'PayPal', namespaced: false do
    # PayPal credentials can be configured via environment variables:
    #   WORKAREA_PAYPAL_CLIENT_ID
    #   WORKAREA_PAYPAL_CLIENT_SECRET
    #
    # via rails credentials:
    #   paypal:
    #     client_id: YOUR_CLIENT_ID
    #     client_secret: YOUR_CLIENT_SECRET
    #
    # Or through the workarea admin configuration. Setting credentials through
    # the configuration allows for dyanmically changing credentials if, for
    # example, you are using the multi-site plugin and wish to use different
    # PayPal accounts for some or all sites.
    #
    field 'Client ID',
      type: :string,
      id: 'paypal_client_id',
      description: 'Your Paypal Merchant Account Application Client ID'
    field 'Client Secret',
      type: :string,
      id: 'paypal_client_secret',
      encrypted: true,
      description: 'Your Paypal Merchant Account Application Client Secret'
  end
end
