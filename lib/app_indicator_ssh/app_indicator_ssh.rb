require 'rubygems'
require "ruby-libappindicator"
require 'yaml'
require 'app_indicator_ssh/system_calls'
require 'app_indicator_ssh/config'
require 'app_indicator_ssh/error'

#TODO add ruby libnotify to display errors, info to user
#TODO needs logging 
#TODO needs own icon in tray
module AppIndicatorSSH

  class AppUi
    attr_accessor :top_menu
		def initialize(args={})
			@ai = AppIndicator::AppIndicator.new("AppSSH", "gnome-netstatus-tx", AppIndicator::Category::APPLICATION_STATUS);
      @window = Gtk::Window.new
      @window.set_title 'foobar'
      @menu = Gtk::Menu.new
      @item=nil
			@config=HostsConfig.new
		end
	  
	  #called when user selects host from menu
		def host_select(widget, host)
			begin
			  system_call=SystemCall.new('gnome-terminal -x ssh ' + host) 
			  system_call.run
			rescue AppIndicatorSSHError => e
				puts "Command Error: #{e} "
			end
			raise AppIndicatorSSHError, "There was a problem calling " unless system_call.success?
			p :dbg => system_call.output
    end
    #TODO needs labels?, sub-menus? for each host category--this does not scale for large hosts lists
	  def build_menu
			@config.get_hosts.each do |host, value|
        @item = Gtk::MenuItem.new(host)
        @item.signal_connect('activate') { |widget|
          self.host_select(widget,value)
        }
        @menu.append(@item)
			end
		end

		def run
			@menu.show_all
      @ai.set_menu(@menu)
      @ai.set_status(AppIndicator::Status::ACTIVE)
      Gtk.main
		end
	end



end

#a=AppIndicatorSSH::AppUi.new
#a.build_menu
#a.run
