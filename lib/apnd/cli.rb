require 'daemons'
require 'optparse'

module APND
  class CLI
    def self.push(argv)
      help = <<-HELP
Usage:
  apnd push [OPTIONS] --token <token>

      HELP

      options = {}

      opts = OptionParser.new do |opt|
        opt.banner = help

        opt.separator "Required Arguments:\n"

        opt.on('--token  [TOKEN]', "Set Notification's iPhone token to TOKEN") do |token|
          options[:token] = token
        end

        opt.separator "\nOptional Arguments:\n"

        opt.on('--alert  [MESSAGE]', "Set Notification's alert to MESSAGE") do |alert|
          options[:alert] = alert
        end

        opt.on('--sound  [SOUND]', "Set Notification's sound to SOUND") do |sound|
          options[:sound] = sound
        end

        opt.on('--badge  [NUMBER]', "Set Notification's badge number to NUMBER") do |badge|
          options[:badge] = badge.to_i
        end

        opt.on('--custom [JSON]', "Set Notification's custom data to JSON") do |custom|
          begin
            options[:custom] = JSON.parse(custom)
          rescue JSON::ParserError => e
            puts "Invalid JSON: #{e}"
            exit -1
          end
        end

        opt.on('--host   [HOST]', "Send Notification to HOST, usually the one running APND (default is 'localhost')") do |host|
          options[:host] = host
        end

        opt.on('--port   [PORT]', 'Send Notification on PORT (default is 22195)') do |port|
          options[:port] = port.to_i
        end

        opt.separator "\nHelp:\n"

        opt.on('--help', 'Show this message') do
          puts opt
          exit
        end
      end

      begin
        opts.parse!
        if options.empty?
          puts opts
          exit
        end

        unless options[:token]
          raise OptionParser::MissingArgument, "must specify --token"
        end
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        puts "#{$0}: #{$!.message}"
        puts "#{$0}: try '#{$0} --help' for more information"
        exit
      end

      # Configure Notification upstream host/port
      APND::Notification.upstream_host = options.delete(:host) if options[:host]
      APND::Notification.upstream_port = options.delete(:port) if options[:port]

      APND::Notification.create(options)
    end

    def self.daemon(argv)
      help = <<-HELP
Usage:
  apnd daemon --apple-cert </path/to/cert>

      HELP

      options = {}

      opts = OptionParser.new do |opt|
        opt.banner = help

        opt.separator "Required Arguments:\n"

        opt.on('--apple-cert      [PATH]', 'PATH to APN certificate from Apple') do |cert|
          options[:apple_cert] = cert
        end

        opt.separator "\nOptional Arguments:\n"

        opt.on('--apple-host      [HOST]', "Connect to Apple at HOST (default is gateway.sandbox.push.apple.com)") do |host|
          options[:apple_host] = host
        end

        opt.on('--apple-port      [PORT]', 'Connect to Apple on PORT (default is 2195)') do |port|
          options[:apple_port] = port.to_i
        end

        opt.on('--apple-cert-pass [PASSWORD]', 'PASSWORD for APN certificate from Apple') do |pass|
          options[:apple_cert_pass] = pass
        end

        opt.on('--daemon-port     [PORT]', 'Run APND on PORT (default is 22195)') do |port|
          options[:daemon_port] = port.to_i
        end

        opt.on('--daemon-bind     [ADDRESS]', 'Bind APND to ADDRESS (default is 0.0.0.0)') do |bind|
          options[:daemon_bind] = bind
        end

        opt.on('--daemon-log-file [PATH]', 'PATH to APND log file (default is /var/log/apnd.log)') do |log|
          options[:daemon_log_file] = log
        end

        opt.on('--daemon-timer    [SECONDS]', 'Set APND queue refresh time to SECONDS (default is 30)') do |seconds|
          options[:daemon_timer] = seconds.to_i
        end

        opt.on('--foreground', 'Run APND in foreground without daemonizing') do
          options[:foreground] = true
        end

        opt.separator "\nHelp:\n"

        opt.on('--help', 'Show this message') do
          puts opt
          exit
        end
      end

      begin
        opts.parse!
        if options.empty?
          puts opts
          exit
        end

        unless options[:apple_cert]
          raise OptionParser::MissingArgument, "must specify --apple-cert"
        end
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument
        puts "#{$0}: #{$!.message}"
        puts "#{$0}: try '#{$0} --help' for more information"
        exit
      end

      APND.configure do |config|
        # Setup AppleConnection
        config.apple.cert      = options[:apple_cert]      if options[:apple_cert]
        config.apple.cert_pass = options[:apple_cert_pass] if options[:apple_cert_pass]
        config.apple.host      = options[:apple_host]      if options[:apple_host]
        config.apple.port      = options[:apple_port]      if options[:apple_port]

        # Setup Daemon
        config.daemon.bind     = options[:daemon_bind]     if options[:daemon_bind]
        config.daemon.port     = options[:daemon_port]     if options[:daemon_port]
        config.daemon.log_file = options[:daemon_log_file] if options[:daemon_log_file]
        config.daemon.timer    = options[:daemon_timer]    if options[:daemon_timer]
      end

      if APND.settings.apple.cert.nil?
        puts opts
        exit
      else
        unless options[:foreground]
          Daemonize.daemonize(APND.settings.daemon.log_file, 'apnd')
        end
        APND::Daemon.run!
      end

    end
  end
end
