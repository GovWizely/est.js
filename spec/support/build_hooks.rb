require_relative '../../lib/est'

RSpec.configure do |config|
  config.before(:suite) do
    EST.build Pathname.new(File.expand_path('../../../', __FILE__))
  end
end
