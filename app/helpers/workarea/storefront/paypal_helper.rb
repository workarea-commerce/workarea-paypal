module Workarea
  module Storefront
    module PaypalHelper
      def set_paypal_client_token
        return unless Workarea::Paypal.gateway.configured?

        @paypal_client_token =
          if Workarea.config.use_paypal_hosted_fields
            request = Workarea::Paypal.gateway.generate_token #(user: current_user)
            request.result.client_token
          end
      end

      def include_paypal_javascript_tag(params: {}, data: {})
        return unless Workarea::Paypal.gateway.configured?

        params =
          Workarea.config.paypal_sdk_params
            .merge('client-id' => Workarea::Paypal.gateway.client_id)
            .merge(params)
            .compact

        components = params['components'].to_s.split(',')
        components << 'buttons'
        components << 'hosted-fields' if Workarea.config.use_paypal_hosted_fields
        params['components'] = components.compact.uniq.join(',')

        javascript_include_tag(
          "https://www.paypal.com/sdk/js?#{params.to_query}",
          data: {
            partner_attribution_id: 'Workarea_SP', # Do not change this
            client_token: @paypal_client_token
          }.merge(data)
        )
      end
    end
  end
end
