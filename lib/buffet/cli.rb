require 'buffet'
require 'buffet/version'
require 'optparse'

module Buffet
  class CLI
    def initialize args
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: buffet [options] [spec-files]"

        opts.on('-c', '--config CONFIG',
                'Use the specified CONFIG file') do |config_file|
          Settings.settings_file = File.expand_path(config_file)
        end

        opts.on('-p', '--project PROJECT',
                'Use the specified PROJECT name') do |project_name|
          Settings.project_name = project_name
        end

        opts.on('-x', '--exclude path,...', Array,
                'Exclude the given set of files') do |excludes|
          Settings.excludes = excludes
        end

        opts.on('-l', '--log LOGFILE',
                'Write to log to LOGFILE, instead of default buffet.log') do |log|
          Settings.log_file = log
        end

        opts.on('-v', '--version', 'Show version') do
          puts "#{opts.program_name} #{Buffet::VERSION}"
          exit
        end
      end.parse!(args)

      specs = Buffet.extract_specs_from(opts.empty? ? ['spec'] : opts)

      runner = Runner.new
      runner.run specs

      exit 1 if runner.failed?
    end
  end
end
