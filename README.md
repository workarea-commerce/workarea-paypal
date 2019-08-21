Workarea PayPal
================================================================================

A Workarea Commerce plugin that adds support for PayPal payments. This plugin adds a new tender type in checkout, which allows users to pay for their items with PayPal.

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

Then, configure your secrets.

```yaml
paypal:
  login:
  password:
  signature:
```

These credentials will be sent to you by your client, who should have a PayPal merchant account set up already. If not, or you wish to develop locally, [sign up for a sandbox account](https://developer.paypal.com/developer/accounts/).

## International Addresses

When working with international addresses, the data from PayPal regarding country and region codes is not guaranteed to match the identifiers used in Workarea (derived from our usage of the [countries](https://github.com/hexorx/countries) gem), because the 2-digit codes identifying countries and regions are not the same. Therefore, you may have some issues when accepting international payments through PayPal, and thus some changes will need to be applied to ensure a seamless checkout process for international PayPal users.

Workarea Commerce Documentation
--------------------------------------------------------------------------------

See [https://developer.workarea.com](https://developer.workarea.com) for Workarea Commerce documentation.

License
--------------------------------------------------------------------------------

Workarea Paypal is released under the [Business Software License](LICENSE)
