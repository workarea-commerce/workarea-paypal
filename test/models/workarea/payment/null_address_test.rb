require 'test_helper'

module Workarea
  class Payment
    class NullAddressTest < TestCase
      def test_responding_as_address
        address = NullAddress.new

        assert(address.save)

        address.street = '123 Street Rd.'
        assert_nil(address.street)
        assert(address.valid?)
        assert_equal('123 Street Rd.', address.reference.street)

        address.country = 'US'
        assert_nil(address.country.alpha2)
        assert_equal('US', address.reference.country.alpha2)

        assert(address.save!)

        assert(
          address.update!(
            first_name: 'Robert',
            last_name: 'Clams',
            street: '22 South 3rd St.',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106'
          )
        )

        refute(address.persisted?)
        assert_nil(address.first_name)
        assert_nil(address.last_name)
        assert_nil(address.street)
        assert_nil(address.city)
        assert_nil(address.region)
        assert_nil(address.postal_code)
        assert(address.valid?)

        refute(address.reference.persisted?)
        assert_equal('Robert', address.reference.first_name)
        assert_equal('Clams', address.reference.last_name)
        assert_equal('22 South 3rd St.', address.reference.street)
        assert_equal('Philadelphia', address.reference.city)
        assert_equal('PA', address.reference.region)
        assert_equal('19106', address.reference.postal_code)
        assert(address.reference.valid?)
      end
    end
  end
end
