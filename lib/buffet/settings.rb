require 'yaml'

module Buffet
  # Stores configuration settings for Buffet.
  class Settings
    DEFAULT_LOG_FILE            = 'buffet.log'
    DEFAULT_SETTINGS_FILE       = 'buffet.yml'
    DEFAULT_PREPARE_COMMAND     = 'bin/before-buffet-run'
    DEFAULT_EXCLUDE_FILTER_FILE = '.buffet-exclude-filter'

    class << self
      def settings_file=(settings_file)
        @settings_file = settings_file
        reset!
      end

      def settings_file
        @settings_file || DEFAULT_SETTINGS_FILE
      end

      def [](name)
        @settings ||= load_file(settings_file)
        @settings[name]
      end

      def slaves
        @slaves ||= self['slaves'].map do |slave_hash|
          Slave.new slave_hash['user'], slave_hash['host'], project
        end
      end

      def allowed_slave_prepare_failures
        self['allowed_slave_prepare_failures'] || 0
      end

      def worker_command
        self['worker_command'] || '.buffet/buffet-worker'
      end

      def execution_environment
        {
          'BUFFET_MASTER' => Buffet.user,
          'BUFFET_PROJECT' => project.name,
        }.merge(self['execution_environment'] || {})
      end

      def log_file=(log)
        @log_file = log
      end

      def log_file
        @log_file || self['log_file'] || DEFAULT_LOG_FILE
      end

      def project_name=(project_name)
        project.name = project_name
      end

      def project
        @project ||= Project.new Dir.pwd
      end

      def prepare_command
        self['prepare_command'] || DEFAULT_PREPARE_COMMAND
      end

      def prepare_command?
        self['prepare_command'] || File.exist?(DEFAULT_PREPARE_COMMAND)
      end

      def exclude_filter_file
        self['exclude_filter_file'] || DEFAULT_EXCLUDE_FILTER_FILE
      end

      def has_exclude_filter_file?
        self['exclude_filter_file'] || File.exist?(DEFAULT_EXCLUDE_FILTER_FILE)
      end

      def failure_threshold
        self['failure_threshold'] || 3
      end

      def excludes=(exclusions)
        self['exclude'] = exclusions
      end

      def excludes
        self['exclude'] || []
      end

      def file_excluded?(file)
        excludes.any? do |exclude_prefix|
          file.start_with?(exclude_prefix)
        end
      end

      def reset!
        @settings = nil
      end

      def display_progress?
        @settings.fetch('display_progress', true)
      end

    private

      def load_file file
        @settings = YAML.load_file file
      end
    end
  end
end
