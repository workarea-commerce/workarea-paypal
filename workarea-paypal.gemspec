$:.push File.expand_path('../lib', __FILE__)

require 'workarea/paypal/version'

Gem::Specification.new do |s|
  s.name        = 'workarea-paypal'
  s.version     = Workarea::Paypal::VERSION
  s.authors     = ['bcrouse']
  s.email       = ['bcrouse@workarea.com']
  s.homepage    = 'https://github.com/workarea-commerce/workarea-paypal'
  s.summary     = 'PayPal integration for the Workarea Commerce Platform'
  s.description = 'Add PayPal as a payment method to the Workarea Commerce Platform.'

  s.files = `git ls-files`.split("\n")

  s.license = 'Business Software License'

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'workarea', '~> 3.x'
end
