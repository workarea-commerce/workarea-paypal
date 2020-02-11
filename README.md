Workarea PayPal
================================================================================

A Workarea Commerce plugin that adds support for PayPal payments. This plugin adds a new tender type in checkout, which allows users to pay for their items with PayPal.

As of v3.0, this plugin utilizes the [PayPal Commerce Platform](https://www.paypal.com/us/webapps/mpp/commerce-platform). By default this integrates PayPal's [Smart Payment Buttons](https://developer.paypal.com/docs/commerce-platform/payment/checkout/) into your Workarea Application to allow customer's to use any payment method supported in their area to complete checkout on your storefront.

Getting Started
--------------------------------------------------------------------------------

Add the gem to your application's Gemfile:

```ruby
# ...
gem 'workarea-paypal'
# ...
```

Update your application's bundle.

```bash
cd path/to/application
bundle
```

Then, add your client ID and secret to Workarea. See "Account Setup" below for more details.

For production environments, we recommend you run the webhooks rake task to register critical callbacks from PayPal to help keep the state of your orders on Workarea inline with the state of the PayPal transaction. See the `default_webhook_events` description under "Configuration Options" for more information.

```bash
bin/rails workarea:paypal:create_webhooks
```

Account Setup
--------------------------------------------------------------------------------

To begin using PayPal on your site, you will need to have a PayPal merchant account. For development, you can create an account on [developer.paypal.com](htttps://developer.paypal.com). From there you can create a sandbox REST API app, and use those credentials for any non-live environments.

Once you have a REST API application in your PayPal sandbox, you must add the client ID and secret to your Workarea application. This can be done through admin configuration, environment variables, Rails credentials, or hard-coded Workarea configuration.

### Admin configuration

The PayPal plugin adds admin configuration fields to allow admin user's to set credentials without the need for developer intervention. Log in as an admin user, navigate to the Configuration page, find the PayPal section and add the client ID and secret.

### Environment Variables

If the storing and setting of credentials needs to be more dynamic, you can utilize environment variables. Set the environment variables below to connect to PayPal.

`WORKAREA_PAYPAL_CLIENT_ID`   
`WORKAREA_PAYPAL_CLIENT_SECRET`

### Rails Credentials

This option can be used for any environment, but is most useful in development to store the sandbox credentials within the codebase securely, allowing anyone with the `master.key` of your application to have PayPal configured when they load their application in development.

To add your PayPal info to your Rails credentials, open your credentials file for editing:

```bash
EDITOR=vi bin/rails credentials:edit
```

Then, add a PayPal section:

```yaml
paypal:
  client_Id: YOUR_CLIENT_ID
  client_secret: YOUR_CLIENT_SECRET
```

### Hard-coded configuration

This option is not ideal, as it will prevent admin configuration from ever being used, but can be necessary if you need to automate the switching of PayPal accounts in a multi-site environment. It is **strongly** recommended that you store the credentials elsewhere and load them into your configuration dynamically if you need to use this option.

In your `config/initializers/workarea.rb`, add:

```ruby
Workarea.configure do |config|
  config.paypal_client_id = 'YOUR_CLIENT_ID'
  config.paypal_client_secret = 'YOUR_CLIENT_SECRET'
end
```

Configuration Options
--------------------------------------------------------------------------------

`config.paypal_environment`

The [PayPal Checkout SDK](https://github.com/paypal/Checkout-Ruby-SDK) gem uses different environment classes depending on whether you are interacting with sandbox or live environments. This config by default will point to the sandbox environment unless you are in production. If you need to customize which environment you wish to connect to you'll have to modify the value of this config. Accepted values are `'Paypal::LiveEnvironment'` or
`'PayPal::SandboxEnvironment'`.

`config.paypal_sdk_params`

This config holds a hash of values to be passed as query string arguments to the PayPal when fetching the javascript SDK. See the [PayPal documentation](https://developer.paypal.com/docs/checkout/reference/customize-sdk/) for options. By default, the plugin will pass the client_id, and `'commit' => false`. It will add `'debug' => true` if you are in development for easier troubleshooting.

`config.default_webhook_events`

PayPal offers a number of [webhook integration options](https://developer.paypal.com/docs/integration/direct/webhooks/rest-webhooks/) that will make calls to your application when something happens within PayPal. You can [create webhooks manually](https://developer.paypal.com/docs/integration/direct/webhooks/rest-webhooks/#to-use-the-dashboard-to-subscribe-to-events) within the PayPal dashboard, but Workarea provides a more automated way to subscribe to events through the `workarea:paypal:create_webhooks` rake task. When run, this rake task will clear any existing webhooks and create a webhook for each event in `config.default_webhook_events`. By default, `PAYMENT.CAPTURE.COMPLETED` and `PAYMENT.CAPTURE.DENIED` are the only events supported by the plugin. If you wish to add more supported events you will also have to provide logic within [`Workarea::Paypal::HandleWebhookEvent`](https://github.com/workarea-commerce/workarea-paypal/blob/master/app/workers/workarea/paypal/handle_webhook_event.rb) to update your application appropriately.


`config.use_paypal_hosted_fields`

This configuration toggles on [PayPal Custom Card Fields](https://developer.paypal.com/docs/limited-release/custom-card-fields/) which allows you to use PayPal as your primary credit card payment processor. See "Hosted Fields" below for more information.

### Javascript Configuration

Both Smart Payment Buttons and Hosted Fields provide configuration within the javascript `WORKAREA.config` object to customize options passed when initializing those behaviors.

`WORKAREA.config.paypalButtons`

Customize the Smart Payment Buttons options. See the [PayPal documentation](https://developer.paypal.com/docs/checkout/integration-features/customize-button/) for options.

`WORKAREA.config.paypalHostedFields`

Customize the Hosted Fields options. See the [PayPal documentation](https://developer.paypal.com/docs/limited-release/custom-card-fields/reference) for options.

Hosted Fields
--------------------------------------------------------------------------------

The PayPal Commerce Platform allows you to add unbranded, custom credit card fields to your checkout to accept payments directly on your site. When enabled via `config.use_paypal_hosted_fields`, the Workarea plugin integrates this directly into the existing checkout payment step by replacing the default credit card fields with fields rendered by PayPal. This enables you to accept credit card payments with no other payment processor except PayPal.

This does require providing additional information to PayPal through a Workarea-specific partner signup. For sandbox accounts, You can [complete this process](https://www.sandbox.paypal.com/bizsignup/partner/entry?channelId=partner&channel=marketplace&product=ppcp&partnerId=M3XMHZJKTFK88&integrationType=FO) without additional communication using your **sandbox business account login** (found in the PayPal developer dashboard under Sandbox > Accounts). For live environments, contact [Workarea](https://www.workarea.com/pages/contact-us) or reach out to PayPal for more information how you can enable this behavior for your site.

Additional Information
--------------------------------------------------------------------------------

See the [PayPal Documentation](https://developer.paypal.com/docs/commerce-platform/) for more information on the PayPal Commerce Platform.

### International Addresses

When working with international addresses, the data from PayPal regarding country and region codes is not guaranteed to match the identifiers used in Workarea (derived from our usage of the [countries](https://github.com/hexorx/countries) gem), because the 2-digit codes identifying countries and regions are not the same. Therefore, you may have some issues when accepting international payments through PayPal, and thus some changes will need to be applied to ensure a seamless checkout process for international PayPal users.


Workarea Commerce Documentation
--------------------------------------------------------------------------------

See [https://developer.workarea.com](https://developer.workarea.com) for Workarea Commerce documentation.

License
--------------------------------------------------------------------------------

Workarea Paypal is released under the [Business Software License](LICENSE)
