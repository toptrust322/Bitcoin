#events.rb set site.conferences and site.meetups arrays based
#on events in _events/ and meetups on bitcoin.meetups.com .
#This is later used to populate the events map and display the
#list in chronological order, in the RSS file and events pages.

require 'open-uri'
require 'json'
require 'date'
require 'yaml'
require 'cgi'

module Jekyll

  class EventPageGenerator < Generator

    def meetups
      meetups = []
      # Call Meetup API with a key-signed request
      begin
        data = JSON.parse(open("http://api.meetup.com/2/open_events?omit=description&status=upcoming&radius=25.0&topic=bitcoin&and_text=False&limited_events=False&desc=False&offset=0&format=json&page=500&time=0m%2C3m&sig_id=133622112&sig=cd874bc2c84f96d989f823880889bda2f5e4cdc5","User-Agent"=>"Ruby/#{RUBY_VERSION}").read)
      # Prevent any error to stop the build process, return an empty array instead
      rescue
        print 'Meetup API Call Failed!'
        return meetups
      end
      if !data.is_a?(Hash) or !data.has_key?('results') or !data['results'].is_a?(Array)
        print 'Meetup API Call Failed!'
        return meetups
      end
      if data['results'].length > 1000
        print 'Meetup API exceeding the 1000 results limit!'
        return meetups
      end
      # Loop in returned results array
      for m in data['results']
        # Skip meetups with incomplete data
        next if !m.has_key?('time') or ( !m['time'].is_a?(String) and !m['time'].is_a?(Integer) and !m['time'].is_a?(Float) )
        next if !m.has_key?('group') or !m['group'].is_a?(Hash)
        next if !m['group'].has_key?('name') or ( !m['group']['name'].is_a?(String) and !m['group']['name'].is_a?(Integer) and !m['group']['name'].is_a?(Float) )
        next if !m.has_key?('venue') or !m['venue'].is_a?(Hash)
        next if !m['venue'].has_key?('name') or ( !m['venue']['name'].is_a?(String) and !m['venue']['name'].is_a?(Integer) and !m['venue']['name'].is_a?(Float) )
        next if !m['venue'].has_key?('address_1') or ( !m['venue']['address_1'].is_a?(String) and !m['venue']['address_1'].is_a?(Integer) and !m['venue']['address_1'].is_a?(Float) )
        next if !m['venue'].has_key?('city') or ( !m['venue']['city'].is_a?(String) and !m['venue']['city'].is_a?(Integer) and !m['venue']['city'].is_a?(Float) )
        next if !m['venue'].has_key?('country') or ( !m['venue']['country'].is_a?(String) and !m['venue']['country'].is_a?(Integer) and !m['venue']['country'].is_a?(Float) )
        next if !m['venue'].has_key?('lat') or ( !m['venue']['lat'].is_a?(String) and !m['venue']['lat'].is_a?(Integer) and !m['venue']['lat'].is_a?(Float) )
        next if !m['venue'].has_key?('lon') or ( !m['venue']['lon'].is_a?(String) and !m['venue']['lon'].is_a?(Integer) and !m['venue']['lon'].is_a?(Float) )
        next if !m.has_key?('event_url') or ( !m['event_url'].is_a?(String) and !m['event_url'].is_a?(Integer) and !m['event_url'].is_a?(Float) )
        # Assign variables
        time = m['time'].to_s
        title = m['group']['name'].to_s
        venue = m['venue']['name'].to_s
        address = m['venue']['address_1'].to_s
        city = m['venue']['city'].to_s
        country = m['venue']['country'].to_s
        link = m['event_url'].to_s
        lat = m['venue']['lat'].to_s
        lon = m['venue']['lon'].to_s
        # Skip meetups with malformed data
        next if !/^[0-9]{1,15}$/.match(time)
        next if !/^.{1,150}$/.match(title)
        next if !/^.{1,150}$/.match(venue)
        next if !/^.{1,150}$/.match(address)
        next if !/^.{1,150}$/.match(city)
        next if !/^[a-zA-Z]{2}$/.match(country)
        next if !/^http:\/\/www.meetup.com\/.{1,150}$/.match(link)
        next if !/^-?[0-9]{1,2}(\.[0-9]{1,15})?$/.match(lat) or ( lat.to_f < -90 and lat.to_f > 90 )
        next if !/^-?[0-9]{1,3}(\.[0-9]{1,15})?$/.match(lon) or ( lon.to_f < -180 and lon.to_f > 180 )
        next if lon.to_f == 0 and lat.to_f == 0
        # Format variables
        time = Time.at(time.to_i/1000)
        date = time.year.to_s + '-' + time.month.to_s.rjust(2,'0') + '-' + time.day.to_s.rjust(2,'0')
        country = country.upcase
        geoloc = lat + ', ' + lon
        # Use address_2 and state when available
        if m['venue'].has_key?('address_2') and ( m['venue']['address_2'].is_a?(String) and m['venue']['address_2'].is_a?(Integer) and m['venue']['address_2'].is_a?(Float) ) and /^.{1,150}$/.match(m['venue']['address_2'].to_s)
          address = address + ' ' + m['venue']['address_2'].to_s
        end
        if m['venue'].has_key?('state') and ( m['venue']['state'].is_a?(String) and m['venue']['state'].is_a?(Integer) and m['venue']['state'].is_a?(Float) ) and /^.{1,150}$/.match(m['venue']['state'].to_s)
          city = city + ', ' + m['venue']['state'].to_s
        end
        # Populate meetups array
        meetups.push({'date' => date, 'title' => title, 'venue' => venue, 'address' => address, 'city' => city, 'country' => country, 'link' => link, 'geoloc' => geoloc})
      end
      return meetups
    end

    def conferences
      conferences = []
      # Loop in _events/ files
      Dir.foreach('_events') do |file|
        # Skip events with malformed name
        next if file == '.' or file == '..'
        date = file.split('-')
        next if date.length < 4
        next if !/^[0-9]{4}$/.match(date[0])
        next if !/^[0-9]{2}$/.match(date[1])
        next if !/^[0-9]{2}$/.match(date[2])
        # Skip event if not in the future
        next if Time.new.to_i > Time.new(date[0].to_i,date[1].to_i,date[2].to_i).to_i
        # Assign variables
        data = YAML.load_file('_events/'+file)
        data['date'] = date[0] + '-' + date[1] + '-' + date[2]
        # Get geolocalisation data from Google Maps
        begin
          geoloc = JSON.parse(open("https://maps.googleapis.com/maps/api/geocode/json?address=" + CGI::escape(data['address'] + ', ' + data['city'] + ', ' + data['country']) + "&sensor=false","User-Agent"=>"Ruby/#{RUBY_VERSION}").read)
          if geoloc['status'] == 'OK'
            data['geoloc'] = geoloc['results'][0]['geometry']['location']['lat'].to_s + ", " + geoloc['results'][0]['geometry']['location']['lng'].to_s
          end
        rescue
          print 'Google Maps API Call Failed!'
        end
        # Populate conferences array
        conferences.push(data)
      end
      return conferences
    end

    def generate(site)
      # Set site.meetups and site.conferences global variables for liquid/jekyll
      class << site
        attr_accessor :meetups, :conferences
        alias event_site_payload site_payload
        def site_payload
          h = event_site_payload
          payload = h["site"]
          payload["meetups"] = self.meetups
          payload["conferences"] = self.conferences
          h["site"] = payload
          h
        end
      end
      # Populate site.conferences array
      site.conferences = conferences()
      # Populate site.meetups array
      site.meetups = meetups()
    end

  end

end
