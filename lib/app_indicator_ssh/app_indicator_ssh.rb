require 'rubygems'
require 'ruby-libappindicator'
require 'yaml'
require 'app_indicator_ssh/system_calls'
require 'app_indicator_ssh/config'
require 'app_indicator_ssh/error'
require 'app_indicator_ssh/log'

#TODO add ruby libnotify to display errors, info to user
#TODO needs own icon in tray
module AppIndicatorSSH

  class AppUi
    attr_accessor :top_menu
		LABEL = 'SSH'
		def initialize(args={})
			@ai = AppIndicator::AppIndicator.new("AppSSH", "gnome-netstatus-tx", AppIndicator::Category::APPLICATION_STATUS);
      @window = Gtk::Window.new
      @window.set_title 'foobar'
      @main_menu = Gtk::Menu.new
      @sub_menu = Gtk::Menu.new
      @top_level=nil
      @sItems=nil
		  @menu_sep = Gtk::SeparatorMenuItem.new
			@config=HostsConfig.new
			@log=Log.new
		end
	  
	  #called when user selects host from menu
		def host_select(widget, host)
			begin
			  system_call=SystemCall.new('gnome-terminal -x ssh ' + host) 
			  system_call.run
				@log.write('info', "Launched: #{host}")
			rescue AppIndicatorSSHError => e
				puts "Command Error: #{e} "
				@log.write('error', "Error ocurred in system call: #{e}")
			end
			raise AppIndicatorSSHError, "There was a problem calling ssh command" unless system_call.success?
			#p :dbg => system_call.output
    end

	  def quit_menu(menu)
			 ex=Gtk::MenuItem.new("_Quit")
			 menu.append ex
			 ex.signal_connect "activate" do
			   Gtk.main_quit
			 end
		end

    def build_menu
			#@config.get_hosts.each do |host, value|
      #  @item = Gtk::MenuItem.new(host)
      #  @item.signal_connect('activate') { |widget|
      #    self.host_select(widget,value)
      #  }
      #  @menu.append(@item)
			#end
			@config.get_hosts.each do |host, value|
				@sub_menu=Gtk::Menu.new
				@top_level = Gtk::MenuItem.new("_#{host}")
				@main_menu.append @top_level
				value.each do |v|
					@sItems = Gtk::MenuItem.new(v['title'])
					@sItems.signal_connect('activate') { |widget|
						self.host_select(widget,v['sshparams'])
					}
					@sub_menu.append(@sItems)
				end
				@main_menu.append @menu_sep
				@top_level.set_submenu(@sub_menu)
			end
      self.quit_menu(@main_menu)
		end

		def run
			@main_menu.show_all
      @ai.set_menu(@main_menu)
			#XXX Not sure why libappindicator.set_label requires two strings?
			@ai.set_label(LABEL, LABEL)
			@ai.set_status(AppIndicator::Status::ACTIVE)
      Gtk.main
		end
	end



end

#a=AppIndicatorSSH::AppUi.new
#a.build_menu
#a.run
