# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'bundler/setup'
#Bundler.setup
Bundler.require

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dpn/client'

require 'httpclient'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: false)
WebMock.disable!