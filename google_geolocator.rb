#!/usr/bin/env ruby

require 'json'
require 'httparty'

module HTTParty
  class Response
    def to_string
      location = parsed_response['location']
      address = location['address']
      <<-EOS
#{address['country']} #{address['region']} #{address['city']} #{address['street']} #{address['street_number']}
(latitude: #{location['latitude']} latitude: #{location['longitude']})
      EOS
    end
  end
end

class GoogleGeolocator
  include HTTParty

  base_uri 'http://www.google.com'
  format :json

  def self.where_i_am
    options = { version: '1.1.0',
      host: 'maps.google.com',
      request_address: true,
      address_language: 'ja_JP',
      wifi_towers: wifi_aps.map{|ap| {:mac_address => ap[0], :signal_strength => ap[1], :age => 0} }
    }

    post('/loc/json', body: JSON.dump(options)).to_string
  end

  def self.wifi_aps
    raw = `/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -s`
    raw.scan(/^\s*(\S+)\s+([\h:]+)\s+([-\d]+)/).select{|line| line[0] !~ /_nomap$/ }.map{|line|
      line[1..2]
    }
  end
  private_class_method :wifi_aps
end


#
# main
#

puts GoogleGeoLocator.where_i_am
