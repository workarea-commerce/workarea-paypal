Upgrading This Gem from v2.x to v3.0.0
================================================================================

As of this gem's v3.0 version, this plugin utilizes the [PayPal Commerce Platform](https://www.paypal.com/us/webapps/mpp/commerce-platform). By default this integrates PayPal's [Smart Payment Buttons](https://developer.paypal.com/docs/commerce-platform/payment/checkout/) into your Workarea Application to allow customers to use any payment method supported in their area to complete checkout on your storefront.

Upgrading will require approximately the following steps:

1. New PayPal Account Setup (see [README](https://github.com/workarea-commerce/workarea-paypal#account-setup))
    *  Create a new [PayPal business account](https://www.paypal.com/signin/client?flow=provisionUser) to generate sandbox credentials.
    *  Add credentials to your application.   


2. Update your application Gemfile

   `gem 'workarea-paypal', '~> 3.0.0'`

3. Rework any customizations your application made around PayPal. Information around what change is provided below to give you an idea of areas you might need to address.

4. Test locally and/or staging to ensure your application is communicating with PayPal.

5. Generate a live REST API app within PayPal to get production credentials.

6. Add production credentials and deploy.

Plugin Changes
---------------

This represents a completely new integration that will require any customizations your application has made to PayPal behavior to be updated to be compatible with v3 of this plugin. As with any change, you should follow the setup steps for the plugin and test extensively to ensure everything is working properly before deploying to production.

This upgrade will require a new PayPal merchant account and updating credentials for both your sandbox and live environments. Contact Workarea Support or PayPal directly with any questions regarding transitioning your application.

### Storefront Changes

Previous versions of this plugin rendered a static PayPal button on the top and bottom of the cart page, and provided a text-based payment option on the payment step of checkout.

The PayPal Commerce Platform integration is more dynamic. The cart page and the step both render a single instance of the [Smart Payment Buttons](https://developer.paypal.com/docs/commerce-platform/payment/checkout/). This generates a dynamic set of PayPal payment options that can vary based on device, customer location, and more. You will need to take this change into consideration and update your views to accommodate the visual change.

These buttons are rendered within an iframe controlled by PayPal. This iframe can change height for certain payment options, so its container should be flexible to account for that potential behavior. There is set of configuration options you can pass to the `paypal.Buttons` javascript method to customize how these buttons are rendered. Workarea provides a javascript configuration object, `WORKAREA.config.paypalButtons` to modify options passed. See the [PayPal documentation](https://developer.paypal.com/docs/checkout/integration-features/customize-button/) for valid options.

Smart Payment Buttons are entirely javascript-based. Part of this behavior eliminates a full redirect away from your site to PayPal, in favor of a separate window that allows the customer to interact with PayPal, and the PayPal javascript SDK to communicate back to your application without leaving the page.

### Payment Processing Changes

Previously, this plugin relied on the ActiveMerchant PayPal implementation to process payments with PayPal. As of v3, this is no longer the case, and instead utilizes PayPal's own [Checkout Ruby SDK](https://github.com/paypal/Checkout-Ruby-SDK). This provides the environment and client logic to securely communicate with PayPal.

With this new gateway, PayPal payments are captured immediately at the time a customer places an order. This is a change from the authorization behavior of the old API that allowed for captures at a later time. You will want to make sure your OMS and other payment related behaviors work with this change. If you need to continue doing authorizations when an order is placed, contact PayPal or Workarea Support to discuss options. As of this writing, the PayPal Commerce Platform has some features that do not yet support authorizations.
