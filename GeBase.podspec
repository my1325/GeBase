Pod::Spec.new do |s|
  s.name     = 'GeBase'
  s.version  = '0.0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A Useful Tools For iOS'
  s.homepage = 'https://github.com/my1325/GeBase'
  s.authors  = { 'My1325' => '1173962595@qq.com' }
  s.source   = { :git => 'https://github.com/my1325/GeBase.git', :tag => s.version, :submodules => true }
  s.requires_arc = true
  
  s.public_header_files = 'GeBase/GeBase/APP/G_BaseApp.h'
  s.source_files = 'GeBase/GeBase/APP/*.{h,m}'
  
  s.ios.deployment_target = '9.0'
  
  s.subspec 'GeBaseData' do |ss|
    ss.source_files = 'GeBase/GeBase/Data/*.{h,m}'
    ss.public_header_files = 'GeBase/GeBase/Data/G_Session.h'
    ss.dependency 'YYModel', '~> 1.0.4'
    ss.dependency 'GeKit'		
  end

  s.subspec 'GeBaseUI' do |ss|
    ss.source_files = 'GeBase/GeBase/UI/*.{h,m}'
    ss.public_header_files = 'GeBase/GeBase/UI/G_BaseHud.h'
    ss.dependency 'GeKit'		
    ss.dependency 'MJRefresh', '~> 3.1.15.1'
    ss.dependency 'MBProgressHUD', '~> 1.1.0'	
  end

  s.subspec 'GeRequest' do |ss|

    ss.source_files = 'GeBase/GeBase/Network/*.{h,m}'
    ss.public_header_files = 'GeBase/GeBase/Network/G_BaseRequest.h'
    ss.dependency 'AFNetworking', '~> 3.1.0'
    ss.dependency 'GeKit'		

  end
end