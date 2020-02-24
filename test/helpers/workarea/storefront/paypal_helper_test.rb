require 'test_helper'

module Workarea
  module Storefront
    class PaypalHelperTest < ViewTest
      include PaypalSetup

      def test_include_paypal_javascript_tag
        Workarea.config.paypal_sdk_params = {
          commit: false,
          debug: true
        }

        result = include_paypal_javascript_tag
        assert_includes(result, 'commit=false')
        assert_includes(result, 'debug=true')
        assert_includes(result, "client-id=#{Workarea::Paypal.gateway.client_id}")
        assert_includes(result, 'components=buttons')
        assert_includes(result, 'data-partner-attribution-id="Workarea_SP_PCP"')
        refute_includes(result, 'hosted-fields')
        refute_includes(result, 'data-client-token')

        Workarea.config.use_paypal_hosted_fields = true
        result = include_paypal_javascript_tag(
          params: { foo: 'bar' },
          data: { baz: 'qux' }
        )

        assert_includes(result, 'foo=bar')
        assert_includes(result, 'data-baz="qux"')
        assert_includes(result, 'components=buttons%2Chosted-fields')
      end
    end
  end
end
