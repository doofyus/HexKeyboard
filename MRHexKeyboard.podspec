Pod::Spec.new do |s|
  s.name                    = 'MRHexKeyboard'
  s.version                 = '1.0.0'
  s.platform                = :ios, '9.0'
  s.summary                 = 'An iOS keyboard, that supports entering hex-values to the UITextField.'
  s.homepage                = 'https://github.com/doofyus/HexKeyboard'
  s.authors                 = { 'Mikk Rätsep' => 'https://github.com/doofyus' }
  s.source                  = { :git => 'https://github.com/doofyus/HexKeyboard.git', :tag => s.version.to_s}
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }
  s.source_files            = '*.{m,h}'
  s.resource                = '*.png'
end
