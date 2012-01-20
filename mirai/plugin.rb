module Mirai
	class Plugin
		def initialize config, em, servername, pluginname, handler, settings
			@em, @config, @servername, @pluginname, @handler, @settings = em, config, servername, pluginname, handler, settings
		end

		def inspect
			"<##{self.object_id} #{@pluginname} on #{@servername}>"
		end


		private 
	
		def rawsend raw
			puts "< [#{@pluginname}] #{raw}"
			@em.send_data "#{raw}\r\n"
		end
	
		def privmsg channel, message
			rawsend "PRIVMSG #{channel} :#{message}"
		end
	
		alias :msg :privmsg
	
		def action target, message
			rawsend "PRIVMSG #{target} :\x01ACTION #{message}\x01"
		end

		def add_channel_handler handler, callback, opts={}
			trigger = opts[:trigger].nil? ? @config.preferredtrigger : opts[:trigger]
			trigger == :none && trigger = ""
			
			prefix = opts[:prefix].nil? ? "^" : opts[:prefix]
			prefix == :none && prefix = ""

			@handler.register_channel_handler(Regexp.new("#{prefix}#{trigger}#{handler}"), self, callback)
		end
	
		def add_web_handler handler, callback
			@handler.register_web_handler(handler, self, callback)
		end

		def reply message
			privmsg @channel, message
		end

		def settings value
			@settings["Settings"].nil? ? nil : @settings["Settings"][value]
		end

		def mirror_handle to, userhash, channel, matches
			@channel = channel
			userhash[:channel] = channel
			userhash[:chan] = channel
			userhash[:raw] = matches[0]
			userhash[:matches] = matches
			send to, userhash, *matches[1..-1]
		end
	end
end