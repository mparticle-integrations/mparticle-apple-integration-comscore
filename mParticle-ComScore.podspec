Pod::Spec.new do |s|
    s.name             = "mParticle-ComScore"
    s.version          = "8.1.0"
    s.summary          = "ComScore integration for mParticle"

    s.description      = <<-DESC
                       This is the ComScore integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-comscore.git", :tag => "v" +s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"

    s.ios.deployment_target = "11.0"
    s.tvos.deployment_target = "11.0"

    s.source_files     = 'mParticle-ComScore/*.{h,m,mm}'

    s.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.0'
    s.dependency 'ComScore', '~> 6.12'

    s.frameworks = 'SystemConfiguration'

end
