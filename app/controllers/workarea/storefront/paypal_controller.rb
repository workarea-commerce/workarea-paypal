module Workarea
  class Storefront::PaypalController < Storefront::ApplicationController
    include Storefront::CurrentCheckout

    before_action :validate_checkout

    def start
      unless params[:from_checkout].present?
        if logged_in?
          current_checkout.start_as(current_user)
        else
          current_checkout.start_as(:guest)
        end
      end

      self.current_order = current_checkout.order
      Pricing.perform(current_order, current_shipping)
      check_inventory || (return)

      setup = Paypal::Setup.new(
        current_order,
        current_user,
        current_shipping,
        self
      )

      redirect_to setup.redirect_url
    end

    def complete
      self.current_order = Order.find(params[:order_id])
      current_order.user_id = current_user.try(:id)
      Pricing.perform(current_order, current_shipping)
      check_inventory || (return)

      Paypal::Update.new(
        current_order,
        current_checkout.payment,
        current_shipping,
        params[:token]
      ).apply

      unless current_checkout.complete?
        flash[:error] = t('workarea.storefront.paypal.address_error')
        redirect_to(checkout_addresses_path) && (return)
      end

      redirect_to checkout_payment_path
    end
  end
end
