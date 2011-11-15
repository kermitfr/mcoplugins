#!/usr/bin/ruby
require 'base64'
require 'optparse'

# This hash will hold all of the options
 # parsed from the command-line by
 # OptionParser.
 options = {}
optparse = OptionParser.new do|opts|
    # Set a banner, displayed at the top
    # of the help screen.
    opts.banner = "Usage: base64encode.rb [options] string-to-encode [string2] [string3] ..."
 
    # Define the options, and what they do
    options[:verbose] = false
    opts.on( '-v', '--verbose', 'Output more information' ) do
        options[:verbose] = true
    end 
 
    # This displays the help screen, all programs are
    # assumed to have this option.
    opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
    end
end
 
 # Parse the command-line. Remember there are two forms
 # of the parse method. The 'parse' method simply parses
 # ARGV, while the 'parse!' method parses ARGV and removes
 # any options found there, as well as any parameters for
 # the options. What's left is the list of files to resize.
 optparse.parse!
 
 puts "Being verbose" if options[:verbose]
 
 ARGV.each do|s|
    puts s + ": " + Base64.encode64(s)
 end
