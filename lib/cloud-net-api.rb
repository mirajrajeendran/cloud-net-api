require 'base64'
require 'faraday'
require 'json'
module CloudNetApi

  API_ENDPOINT = "https://api.cloud.net"

  class CloudNet

    def initialize auth_string
      @authentication_string = auth_string
    end

    def self.setup mail_id, api_secret
      auth_string = Base64.encode64("#{mail_id}:#{api_secret}")
      return self.new(auth_string)
    end

    def get_all_datacenters
      resp = Faraday.get("#{API_ENDPOINT}/datacenters") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      total_results = resp.headers["x-total"]
      full_data = Faraday.get("#{API_ENDPOINT}/datacenters") do |req|
        req.params["per_page"] = total_results.to_i
        req.params["pege"] = 1
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      return JSON.parse(full_data.body)
    end

    def get_datacenter id
      resp = Faraday.get("#{API_ENDPOINT}/datacenters/#{id}") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      return JSON.parse(resp.body)
    end
  end 
end
