Pod::Spec.new do |s|
  s.name     = 'GeBase'
  s.version  = '0.0.1.1'
  s.license  = 'MIT'
  s.summary  = 'Some Useful Tools For iOS'
  s.homepage = 'https://github.com/my1325/GeBase'
  s.authors  = { 'My1325' => '1173962595@qq.com' }
  s.source   = { :git => 'https://github.com/my1325/GeBase.git', :tag => s.version, :submodules => true }
  s.requires_arc = true
  
  s.public_header_files = 'GeBase/GeBase/GeBase.h'
  s.source_files = 'GeBase/GeBase/GeBase.h'
  
  s.ios.deployment_target = '9.0'

  s.dependency 'GeKit'
  
  s.subspec 'GeBaseData' do |ss|
    ss.source_files = 'GeBase/GeBase/Data/*.{h,m}'
    ss.dependency 'YYModel', '~> 1.0.4'
  end

  s.subspec 'GeBaseUI' do |ss|
    ss.source_files = 'GeBase/GeBase/UI/*.{h,m}'
    ss.dependency 'MBProgressHUD', '~> 1.1.0'	
  end

  s.subspec 'GeRequest' do |ss|
    ss.source_files = 'GeBase/GeBase/Network/*.{h,m}'
    ss.dependency 'AFNetworking'
  end
  
  s.subspec 'GeDatabase' do |ss|
    ss.source_files = 'GeBase/GeBase/Database/*.{h,m}'	
    ss.dependency 'YYModel', '~> 1.0.4'
    ss.dependency 'FMDB'
  end
end