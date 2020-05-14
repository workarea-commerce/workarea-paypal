Workarea Paypal 3.0.2 (2020-05-14)
--------------------------------------------------------------------------------

*   Fix wrong protocol when using SSL

    Fixes #11

    Ben Crouse

*   Fix field name on #refund


    Alejandro Babio



Workarea Paypal 3.0.1 (2020-03-17)
--------------------------------------------------------------------------------

*   Add upgrade guide

    PAYPAL-6
    Matt Duffy



Workarea Paypal 3.0.0 (2020-03-03)
--------------------------------------------------------------------------------

*   Improve handling of failed captures

    PAYPAL-5
    Matt Duffy

*   Clean up NullAddress display, add partner id to all PayPal requests

    PAYPAL-5
    Matt Duffy

*   Update README

    PAYPAL-4
    Matt Duffy

*   Update PayPal integration for PayPal Commerce Platform API

    PAYPAL-3
    Matt Duffy



Workarea Paypal 2.0.9 (2019-10-30)
--------------------------------------------------------------------------------

*   Fix Integration Test Failure When PO Box Config Changes

    When `config.allow_shipping_address_po_box` is set to `true`, an
    integration test in the PayPal plugin failed due to the shipping step
    raising an error since no shipping option is available for the address.
    To ensure the test is configured correctly, it's now wrapped in a
    `Workarea.with_config` block, with `config.allow_shipping_address_po_box`
    set to `false`. This allows the test to ensure that the proper redirect
    occurs when a shipping address coming back from PayPal is invalid.

    PAYPAL-83
    Tom Scott



Workarea Paypal 2.0.8 (2019-08-21)
--------------------------------------------------------------------------------

*   Open Source!



Workarea Paypal 2.0.7 (2019-06-11)
--------------------------------------------------------------------------------

*   Improve Accuracy Of `Paypal::Setup` Tests

    The test cases for `Paypal::Setup` mock out an `Order` without
    necessarily going through the entire pricing system to do so. Reading
    this code therefore doesn't make sense, because the price adjustments
    added to the mocked order don't accurately reflect what would happen in
    the real world. To remedy this, Workarea now creates an actual order in
    the database and uses the `#add_item` and `#adjust_pricing` methods to
    add items and price adjustments, respectively, so that not only will
    this test fail if any breaking changes in our orders system would cause
    a production-level problem in PayPal, but also reading the test code is
    a bit more straightforward, leading to better developer
    understandability.

    PAYPAL-78
    Tom Scott



Workarea Paypal 2.0.6 (2019-05-14)
--------------------------------------------------------------------------------

*   Update README to Include Relevant Documentation

    The README for this gem has been rewritten to include relevant
    information on how to set the plugin up. All non-essential information
    has been removed, assuming that if you're reading this page, you already
    have https://gems.weblinc.com set up with Bundler, and you already know to
    contact sales@workarea.com if you want to use the platform. Information
    on how to get the plugin up and running has been added in addition to
    the existing configuration example.

    PAYPAL-79
    Tom Scott

*   Update for workarea v3.4 compatibility

    PAYPAL-77
    Matt Duffy



Workarea Paypal 2.0.5 (2018-05-01)
--------------------------------------------------------------------------------

*   Release version 2.0.5

    Curt Howard

*   Specify currency during PayPal payment operations

    When using PayPal as a payment tender in checkout, specify the currency
    as a 3-character uppercase String. If this is not done, all amounts are
    defaulted to USD. Supports sites that allow checkout from multiple
    different currencies.

    PAYPAL-75
    Tom Scott

*   Factor in shipping when pricing order for PayPal

    Shipping was being excluded from the order subtotal, resulting in an
    erroneous redirect back to the addresses step of checkout. We're now
    factoring in the shipping records for an order when pricing the order in
    `Paypal::Update` to remedy this.

    PAYPAL-48
    Tom Scott

*   Leverage Workarea Changelog task

    ECOMMERCE-5355
    Curt Howard



WebLinc PayPal 2.0.4 (2018-02-20)
--------------------------------------------------------------------------------

*   Fix test class name

    The `Workarea::Payment::Capture::PaypalTest` was named incorrectly, and
    thus impossible to decorate in case tests failed.

    PAYPAL-74
    Tom Scott


WebLinc PayPal 2.0.3 (2017-10-17)
--------------------------------------------------------------------------------

*   Fix duplicate IDs

    PAYPAL-72
    Curt Howard

WebLinc PayPal 2.0.2 (2017-07-07)
--------------------------------------------------------------------------------

*   Add proxy to gateway autoconfiguration

    PAYPAL-69
    Ben Crouse

*   Remove jshint and replace with eslint

    PAYPAL-68
    Dave Barnow


WebLinc PayPal 2.0.1 (2017-05-26)
--------------------------------------------------------------------------------

* Update README

WebLinc PayPal 2.0.0 (2017-05-17)
--------------------------------------------------------------------------------

*   Autoconfigure Paypal gateway based on secrets

    PAYPAL-60
    Eric Pigeon

*   Prevent saved credit cards being selected when returning from paypal

    PAYPAL-62
    Beresford, Jake

*   Removed paypal from credit_card_issuers configuration, render icon using inline_svg instead

    PAYPAL-59
    Beresford, Jake

*   Adds PayPal payment type to credit card issuers config and adds icon to be rendered.

    * Moved append points into initializer

    PAYPAL-59
    Beresford, Jake

*   Upgrade paypal for Workarea 3

    PAYPAL-56
    Eric Pigeon


WebLinc PayPal 1.1.0 (2017-03-28)
--------------------------------------------------------------------------------

*   PAYPAL-57: Only use the PayPal e-mail address if the order does not already have an e-mail address
    Stephanie Staub

*   Change payment method messaging when paypal auth is complete.

    PAYPAL-50
    Beresford, Jake

*   Update checkout payment submit button when user selects paypal as payment method.

    PAYPAL-50
    Beresford, Jake


WebLinc PayPal 1.0.3 (2016-06-13)
--------------------------------------------------------------------------------

*   Refactor store front spec

    Start with valid payment details and replace with
    invalid data as needed

    PAYPAL-39
    Kristen Ward

*   Fix paypal checkout after failed credit card

    After a user enters an invalid credit card, paypal
    checkout does not complete. instead users are brought
    through an infinite loop of going through the paypal gateway
    and returning to workarea checkout to try again.

    When setting the payment method to paypal, also clear any credit
    cards that might still exist.

    Add unit and request test

    PAYPAL-39
    Kristen Ward

*   Ensure correct order total on paypal completion

    Upon return from paypal gateway, users are given an error
    message due to the current checkout failing `purchasable?`
    at the payment step.

    Order.total_price is not matching the payment tendered amount
    due to shipping and tax being ignored.

    Run Pricing.perform at this step to include the shipping total
    and tax in order.total_price

    PAYPAL-39
    Kristen Ward


WebLinc PayPal 1.0.2 (2016-05-09)
--------------------------------------------------------------------------------

*   Handle invalid address from paypal.

    PAYPAL-38
    Jeff Yucis


WebLinc PayPal 1.0.1 (2016-04-05)
--------------------------------------------------------------------------------


WebLinc PayPal 1.0.0 (January 13, 2016)
--------------------------------------------------------------------------------

*   Update for compatibility with WebLinc 2.0

*   Replace absolute URLs with relative paths

*   Send item level discounts as separate items to paypal

    Reference Jeffers commit 30a4a7c99e2

    Change order level adjustments included in subtotal to discounts only.
    All order level price adjustments were previously being applied.

    PAYPAL-35

*   Rename order_decorator to payment_decorator

    Update file path

    PAYPAL-36

*   Do not reset checkout when paypal start called from checkout

    PAYPAL-34


WebLinc PayPal 0.8.0 (October 6, 2015)
--------------------------------------------------------------------------------

*   Update for compatibility with the WebLinc v0.12 Ruby API.

    ECOMMERCE-1543

*   Clear PayPal tender when credit card tender is selected.

    PAYPAL-29

    2d8c8376cf6f7102538b0deae7fd2af00c59e876


WebLinc PayPal 0.7.0 (July 12, 2015)
--------------------------------------------------------------------------------

*   Fix checkout validation to not require an additional payment method with
    PayPal.

    PAYPAL-22

    3890b2daa02e81b2426a5b9618143b8b31014042

*   Update for compatibility with workarea 0.10.0.

    8b5969eb875469f28ce323f9b53669ba8d4889ab
    6df7380f85e41c1b2d7ecf42e943690489ddb12f
    eca72df11fe466a11ae150347aff384d1412e17e
    358d737374cdc647c75c6a798783343069e64184

*   Send BN code to PayPal for revenue sharing on all PayPal transactions.

    ActiveMerchant sends the `Gateway.application_id` as the BN code. Set
    PayPal gateway `application_id` to WebLinc's affiliate code (BN code).

    PAYPAL-20


WebLinc PayPal 0.6.0 (June 1, 2015)
--------------------------------------------------------------------------------

*   Update for compatibility and consistency with workarea 0.9.0.

*   Fix typos in paypal.rb.

    PAYPAL-17


WebLinc PayPal 0.5.0 (April 10, 2015)
--------------------------------------------------------------------------------

*   Update testing environment for compatibility with WebLinc 0.8.0.

*   Use new decorator style for consistency with WebLinc 0.8.0.

*   Remove gems server secrets for consistency with WebLinc 0.8.0.

*   Update assets for compatibility with WebLinc 0.8.0.
