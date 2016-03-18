Pod::Spec.new do |s|
  s.name             = "mParticle-ComScore"
  s.version          = "6.0.0"
  s.summary          = "ComScore integration for mParticle"

  s.description      = <<-DESC
                       This is the ComScore integration for mParticle.
                       DESC

  s.homepage         = "https://www.mparticle.com"
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { "mParticle" => "support@mparticle.com" }
  s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-comscore.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/mparticles"

  s.source_files = 'mParticle-ComScore/*.{h,m,mm}'

  s.dependency 'mParticle-Apple-SDK', '6.0.0'
  s.dependency 'ComScore-iOS', '3.1510.23'
end
