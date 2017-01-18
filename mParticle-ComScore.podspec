Pod::Spec.new do |s|
    s.name             = "mParticle-ComScore"
    s.version          = "6.11.0"
    s.summary          = "ComScore integration for mParticle"

    s.description      = <<-DESC
                       This is the ComScore integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-comscore.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-ComScore/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 6.11.0'
    s.ios.dependency 'ComScore', '5.1.10'
    s.frameworks = 'SystemConfiguration'

end
