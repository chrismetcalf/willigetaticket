require 'bundler/setup'
require 'logger'

require './willigetaticket'

$stdout.sync = true

use Rack::CommonLogger

run WillIGetATicket
