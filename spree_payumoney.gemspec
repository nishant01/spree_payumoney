Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_payumoney'
  s.version     = '0.1'
  s.summary     = 'Spree integration with PayUmoney.'
  s.description = 'Spree integration with PayUmoney.'

  s.author    = 'Nishant Sinha'
  s.email     = 'nishant01@gmail.com'
  s.homepage  = 'https://github.com/nishant01/spree_payumoney'

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'solidus_core', '~> 1.4'
  s.add_dependency 'offsite_payments'
end
