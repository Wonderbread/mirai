#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'eventmachine'

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative "mirai/config"
require_relative "mirai/core"
require_relative "mirai/plugin"
require_relative "mirai/pluginhandler"

module Mirai
	def initialize conf, servername
		@conf, @servername = conf, servername
		@core = Mirai::Core.new conf, servername, self
		@pluginhandler = Mirai::PluginHandler.new @conf, @servername, self, @core
		@buffer = ""
	end

	def post_init
		@core.on_connect
	end

	def receive_data(data)
		@buffer += data
		check_data
	end

	private
	def check_data
		tmp = @buffer.rindex(/\n/)
		lines = @buffer[0..tmp].split("\n").each do |line|
			@core.on_data(line.strip) if line.strip != ""
		end
		@buffer = @buffer[tmp..-1]
	end
end


conf = Mirai::Config.new "config.yml"
servername = conf.config["Servers"].first["Server"]

 EventMachine::run do
 	EventMachine.connect conf.hosts(servername).first[0], conf.hosts(servername).first[1], Mirai, conf, servername
 end
