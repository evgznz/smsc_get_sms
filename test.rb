#!/usr/bin/env ruby
#coding: utf-8
require "./smsc_api"
sms = SMSC.new()
p sms.get_sms("Reboot",1200)
	
