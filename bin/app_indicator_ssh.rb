#!/usr/bin/env ruby
$:.unshift(File.dirname(__FILE__) + '/../lib') unless $:.include?(File.dirname(__FILE__) + '/../lib')

require 'app_indicator_ssh/app_indicator_ssh'
begin
  ais=AppIndicatorSSH::AppUi.new
  ais.build_menu
  ais.run
rescue AppIndicatorSSHError => e
  p e
rescue Interrupt => e
  p e
  exit 1
end

