require 'buffet'
require 'optparse'

module Buffet
  class CLI
    def initialize args
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: buffet [options] [spec-files]"

        opts.on('-c', '--config CONFIG',
                'Use the specified CONFIG file') do |config_file|
          Settings.load_file File.expand_path(config_file)
        end

        opts.on('-p', '--project PROJECT',
                'Use the specified PROJECT name') do |project_name|
          Settings.project_name = project_name
        end
      end.parse!(args)

      specs = Buffet.extract_specs_from(opts.empty? ? 'spec' : opts)

      runner = Runner.new
      runner.run specs

      exit 1 if runner.failures?
    end
  end
end
