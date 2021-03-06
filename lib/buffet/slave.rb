module Buffet
  class Slave
    attr_reader :user, :host, :project

    def initialize user, host, project
      @user = user
      @host = host
      @project = project
    end

    def rsync src, dest
      Buffet.run! 'rsync', '-aqz', '--delete',
                  '--delete-excluded', rsync_exclude_flags,
                  '-e', 'ssh', src, "#{user_at_host}:#{dest}"
    end

    def scp src, dest, options = {}
      args = [src, "#{user_at_host}:#{dest}"]
      args.unshift '-r' if options[:recurse]
      Buffet.run! 'scp', *args
    end

    def execute_in_project command
      execute "cd #{@project.directory_on_slave} && #{command}"
    end

    def execute command
      Buffet.run! 'ssh', "#{user_at_host}", command
    end

    def name
      user_at_host
    end

    def user_at_host
      "#{@user}@#{@host}"
    end

    private

    def rsync_exclude_flags
      if Settings.has_exclude_filter_file?
        exclude_flags = "--exclude-from=#{Settings.exclude_filter_file}"
      end
      exclude_flags || ''
    end
  end
end
