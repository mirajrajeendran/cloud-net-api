require 'base64'
require 'faraday'
require 'json'
module CloudNetApi

  # API_ENDPOINT = "https://api.cloud.net" its used for live data
  API_ENDPOINT = "https://api.staging.cloud.net/"

  class CloudNet

    def initialize auth_string
      @authentication_string = auth_string
      @connection = Faraday.new(API_ENDPOINT,{ssl: {verify: false}}) #its only for staging account
    end

    def self.setup mail_id, api_secret
      auth_string = Base64.encode64("#{mail_id}:#{api_secret}")
      return self.new(auth_string)
    end

    def get_all_datacenters
      #initial request for get response headers
      
      resp = @connection.get("#{API_ENDPOINT}/datacenters") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      total_results = resp.headers["x-total"]
      #get all in one request

      full_data = @connection.get("#{API_ENDPOINT}/datacenters") do |req|
        req.params["per_page"] = total_results.to_i
        req.params["pege"] = 1
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      return JSON.parse(full_data.body)
    end

    def get_datacenter id
      resp = @connection.get("#{API_ENDPOINT}/datacenters/#{id}") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      return JSON.parse(resp.body)
    end

    def create_server template_id, name = nil, host_name = nil, memory = 1024, disk_size = 20, cpus = 1
      resp = @connection.post("#{API_ENDPOINT}/servers") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}"
        req.params["template_id"] = template_id
        req.params["name"] = name
        req.params["host_name"] = host_name
        req.params["memory"] = memory
        req.params["disk_size"] = disk_size
        req.params["cpus"] = cpus
      end
      return JSON.parse(resp.body)    
    end

  end 
end
