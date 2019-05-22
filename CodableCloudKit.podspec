Pod::Spec.new do |s|
  s.name                      = "CodableCloudKit"
  s.version                   = "1.0.2"
  s.summary                   = "CodableCloudKit"
  s.homepage                  = "https://github.com/RpX974/CodableCloudKit"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Laurent Grondin" => "laurent.grondin@epitech.eu" }
  s.source                    = { :git => "https://github.com/RpX974/CodableCloudKit.git", :tag => s.version.to_s }
  s.ios.deployment_target     = "9.0"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"
end
