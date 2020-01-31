module Workarea
  class Storefront::PaypalController < Storefront::ApplicationController
    include Storefront::CurrentCheckout

    before_action :validate_checkout
    skip_before_action :verify_authenticity_token

    def create
      unless current_order.checking_out?
        if logged_in?
          current_checkout.start_as(current_user)
        else
          current_checkout.start_as(:guest)
        end
      end

      self.current_order = current_checkout.order
      Pricing.perform(current_order, current_shippings)
      check_inventory || (return)

      response = Paypal::CreateOrder.new(current_checkout).perform
      render json: { id: response.id }

    rescue Paypal::Gateway::RequestError => e
      Rails.logger.error(e)
      flash[:error] = t('workarea.storefront.paypal.errors.request_failed')
      head :internal_server_error
    end

    def update
      check_inventory || (return)

      Paypal::ApproveOrder.new(current_checkout, params[:id]).perform

      complete = current_checkout.complete?
      flash[:error] = t('workarea.storefront.paypal.errors.order_incomplete') unless complete

      render json: {
        success: complete,
        redirect_url: checkout_payment_path
      }
    end

    def event
      Paypal::HandleWebhookEvent.perform_async(
        params[:event_type],
        params[:resource]
      )

      head :ok
    end
  end
end
