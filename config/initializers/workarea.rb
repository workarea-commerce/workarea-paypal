Workarea.config.tender_types << :paypal

# Gateway application_id is sent as PayPal BN code for revenue sharing
# 'Workarea_SP' should be used for all WebLinc installations
ActiveMerchant::Billing::PaypalGateway.application_id = 'Workarea_SP'

Workarea::Paypal.auto_configure_gateway
