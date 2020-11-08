# frozen_string_literal: true

require_relative 'log_repository_console'
require_relative 'log_repository_file'
require_relative 'log_repository_udp'
require_relative 'log_repository_fluent'

module RTALogger
  # this module generates object instance
  module LogFactory
    def self.new_log_repository_console
      LogRepositoryConsole.new
    end

    def self.new_log_repository_file(file_path = 'log.txt', period = 'daily', shift_size = 1_048_576)
      LogRepositoryFile.new(file_path, period, shift_size)
    end

    def self.load_log_repository_file(config_json)
      file_path = config_json['File_Path'].to_s
      period = config_json['Roll_Period'].to_s
      shift_size = config_json['Roll_Size'].nil? ? 1_048_576 : config_json['Roll_Size'].to_i
      ::RTALogger::LogFactory.new_log_repository_file(file_path, period, shift_size)
    end

    def self.new_log_repository_udp(host = '127.0.0.1', port = 4913)
      LogRepositoryUDP.new(host, port)
    end

    def self.load_log_repository_udp(config_json)
      host = config_json['Host'].to_s
      port = config_json['Port'].nil? ? 4913 : config_json['Port'].to_i
      ::RTALogger::LogFactory.new_log_repository_udp(host, port)
    end

    def self.new_log_repository_fluent(host = 'localhost', port = '24224', tls_options = nil)
      LogRepositoryFluent.new(host, port, tls_options)
    end

    def self.load_log_repository_fluent(config_json)
      host = config_json['Host'].to_s
      port = config_json['Port'].to_s
      tls_options = config_json['TLS_Options']
      ::RTALogger::LogFactory.new_log_repository_fluent(host, port, tls_options)
    end

    def self.create_repository(type, config_json)
      result = nil
      result = new_log_repository_console if type.to_s.casecmp('Console').zero?
      result = load_log_repository_file(config_json) if type.to_s.casecmp('File').zero?
      result = load_log_repository_udp(config_json) if type.to_s.casecmp('UDP').zero?
      result = load_log_repository_fluent(config_json) if type.to_s.casecmp('Fluentd').zero?
      result
    end
  end
end
