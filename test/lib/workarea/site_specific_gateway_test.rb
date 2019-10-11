require 'test_helper'

module Workarea
  if Plugin.installed?(:multi_site)
    class MultiSiteGatewayTest < TestCase
      def test_switch_gateway_every_request
        site1 = Site.add_site do |config|
          config.site_name = 'Site 1'
          config.gateways.paypal =
            ActiveMerchant::Billing::BogusGateway.new(
              login: 'site1',
              password: 'foo'
            )
        end
        site2 = Site.add_site do |config|
          config.site_name = 'Site 2'
          config.gateways.paypal =
            ActiveMerchant::Billing::BogusGateway.new(
              login: 'site2',
              password: 'foo'
            )
        end

        site1.as_current do
          assert_equal('site1', Workarea.config.gateways.paypal.options[:login])
        end

        site2.as_current do
          assert_equal('site2', Workarea.config.gateways.paypal.options[:login])
        end
      end
    end
  end
end
