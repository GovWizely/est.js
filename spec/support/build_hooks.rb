require_relative '../../lib/est'

puts 'Building est.min.js'
`bundle exec jekyll build`
EST.build Pathname.new(File.expand_path('../../../', __FILE__))
