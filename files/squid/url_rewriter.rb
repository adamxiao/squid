#!/usr/bin/ruby
# encoding: utf-8

require "rubygems"
require 'syslog'


def https2http(url)
	m = url.match(/^https:(.*)/)
	if m[1]
		return "http:" + m[1]
	else
		return nil
	end
end


def rewriter(request)
	case request
	# https://www.icourse163.org/
	# https://jdvodrvfb210d.vod.126.net/jdvodrvfb210d/nos/mp4/2019/05/12/1214664724_13eac21a9e9643589ce24669232e8951_sd.mp4
	when /^https:\/\/jdvodrvfb210d\.vod\.126\.net\/.*\.mp4(\?.*)?/
		return https2http(request)
	when /^quit.*/
		exit 0
	else
		return ""
	end
end

def log(msg)
	Syslog.log(Syslog::LOG_ERR, "%s", msg)
end

def eval
	request = gets
	if (request && (request.match(/^[0-9]+\ /)))
		conc(request)
		return true
	else
		noconc(request)
		return false
	end

end


def conc(request)
	return if !request
	request = request.split
	if request[0] && request[1]
		log("original request [#{request.join(" ")}].") if $debug
		result = rewriter(request[1])
		if result
			url = request[0] +" OK rewrite-url=\"" + result + "\""
		else
			url = request[0] +" ERR"
		end
		log("modified response [#{url}].") if $debug
		puts url
	else
		log("original request [had a problem].") if $debug
		url = request[0] + "ERR"
		log("modified response [#{url}].") if $debug
		puts url
	end

end

def noconc(request)
	return if !request
	request = request.split
	if request[0]
		log("Original request [#{request.join(" ")}].") if $debug
		result = rewriter(request[0])
		if result && (result.size > 10)
			url = "OK rewrite-url=\"" + rewriter(request[0]) + "\""
			#url = "OK rewrite-url=" + request[0] if ( ($empty % 2) == 0 )
		else
			url = "ERR"
		end
		log("modified response [#{url}].") if $debug
		puts url
	else
		log("Original request [had a problem].") if $debug
		url = "ERR"
		log("modified response [#{url}].") if $debug
		puts url
	end
end

def validr?(request)
	if (request.ascii_only? && request.valid_encoding?)
		return true
	else
		STDERR.puts("errorness line#{request}")
		return false
	end
end

def main
	Syslog.open('url_rewriter.rb', Syslog::LOG_PID)
	log("Started")

	c = eval

	if c
		while request = gets
			conc(request) if validr?(request)
		end
	else
		while request = gets
			noconc(request) if validr?(request)
		end
	end
end

$debug = true
STDOUT.sync = true
main
