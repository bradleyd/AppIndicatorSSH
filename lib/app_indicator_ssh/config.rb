require 'yaml'
require 'pathname'

class HostsConfig
	attr_accessor :filename, :config
	def initialize(args={})
		args.each { |key, value| send("#{key}=", value) if respond_to?(key) }
		@home_dir=nil
		if args[:filename]
			@filename = args[:filename]
		else
			@filename = self.home_dir + 'hosts.yml'
		end

	end

	def home_dir
		return @home_dir unless @home_dir.nil?
		if ENV['HOME']
			return @home_dir = Pathname.new(ENV['HOME'])
		else
			raise "$HOME is not defined"
		end
	end

	def load_config
		begin
			@config=YAML.load_file(@filename)
		rescue AppIndicatorSSHError => e
			puts "Error: #{e}"
		end
		return @config
	end
	#TODO: this need to be more robust, only returns the host ssh params...there is title, type, etc..
	def get_hosts
		all_hosts={}
		config=self.load_config
		config['hosts'].each do |section|
			section.each do |host_section, host_values|
				host_values.each do |host|
					all_hosts[host['title']] = host['sshparams'] unless host['sshparams'].nil?
				end
			end
		end
		return all_hosts
	end
end

