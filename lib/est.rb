module EST
  def self.build(root)
    names = %w(lib/jquery.history lib/mustache endpointme_resource filter toolkit setup development_configuration)
    JSFileConcatenator.concat root, 'est.min', *names
  end

  module JSFileConcatenator
    def self.concat(root, target_name, *source_names)
      require 'pathname'
      require 'uglifier'
      js_root = root.join('_site/assets/js')
      source = source_names.map do |name|
        js_root.join("#{name}.js").read
      end.join("\n")

      File.open(root.join("assets/js/#{target_name}.js"), 'w') do |f|
        f.puts '/*** AUTO GENERATED FILE - DO NOT EDIT ***/'
        f.puts Uglifier.compile source
      end
    end
  end
end
