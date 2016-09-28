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

    def create_server template_id, options = {}
      options = {name: nil, hostname: nil, memory: 1024, disk_size: 20, cpus: 2}.merge(options)
      resp = @connection.post("#{API_ENDPOINT}/servers") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}"
        req.params["template_id"] = template_id 
        req.params["name"] = options[:name]
        req.params["hostname"] = options[:hostname] 
        req.params["memory"] = options[:memory] 
        req.params["disk_size"] = options[:disk_size] 
        req.params["cpus"] = options[:cpus]
      end
      return JSON.parse(resp.body)   
    end

    def get_all_servers
      resp = @connection.get("#{API_ENDPOINT}/servers") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      total_results = resp.headers["x-total"]

      full_data = @connection.get("#{API_ENDPOINT}/servers") do |req|
        req.params["per_page"] = total_results.to_i
        req.params["pege"] = 1
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      return JSON.parse(full_data.body)
    end

    def get_server id
      resp = @connection.get("#{API_ENDPOINT}/servers/#{id}") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}" 
      end
      return JSON.parse(resp.body)
    end

    def edit_server server_id, options = {}
      options = {template_id: nil, memory: nil, cpus: nil, disk_size: nil}.merge(options)
      resp = @connection.put("#{API_ENDPOINT}/servers/#{server_id}") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}"
        req.params["template_id"] = options[:template_id] 
        req.params["memory"] = options[:memory]           
        req.params["disk_size"] = options[:disk_size]     
        req.params["cpus"] = options[:cpus]            
        req.params["id"] = server_id
      end
      return JSON.parse(resp.body)
    end

    def reboot_server id
      resp = @connection.put("#{API_ENDPOINT}/servers/#{id}/reboot") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}"
      end
    end

    def shutdown_server id
      resp = @connection.put("#{API_ENDPOINT}/servers/#{id}/shutdown") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}"
      end
    end

    def startup_server id
      resp = @connection.put("#{API_ENDPOINT}/servers/#{id}/startup") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}"
      end
    end

    def destroy_server id
      resp = @connection.delete("#{API_ENDPOINT}/servers/#{id}") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}"
      end
    end

  end 
end
