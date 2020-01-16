require 'test_helper'

module Workarea
  class PaypalPaymentTest < TestCase
    def payment
      @payment ||= Payment.create!
    end

    def test_paypal?
      refute(payment.paypal?)

      payment.build_paypal
      refute(payment.paypal?)

      payment.paypal.approved = true
      assert(payment.paypal?)
    end

    def test_set_paypal_creates_paypal_tender
      payment.set_paypal(
        paypal_id: '12345',
        payer_id: 'payer_id',
        details: { 'foo' => 'bar' }
      )

      assert_equal('12345', payment.paypal.paypal_id)
      assert_equal('payer_id', payment.paypal.payer_id)
      assert_equal({ 'foo' => 'bar' }, payment.paypal.details)
    end

    def test_set_credit_card_removes_paypal_tender
      payment.set_paypal(
        paypal_id: '12345',
        payer_id: 'payer_id',
        details: { 'foo' => 'bar' }
      )

      payment.set_credit_card({})
      assert(payment.paypal.blank?)
    end

    def test_address
      refute(payment.address.present?)

      payment.build_paypal(approved: true)
      assert(payment.address.present?)

      assert(payment.address.valid?)
      assert(payment.address.street.blank?)

      payment.set_address(factory_defaults(:billing_address))
      assert(payment.address.valid?)
      assert(payment.address.street.present?)

      payment.paypal = nil
      assert(payment.address.valid?)

      payment.address = nil
      refute(payment.address.present?)

      payment.build_address
      refute(payment.address.valid?)
    end
  end
end
