require 'base64'
require 'faraday'
require 'json'
module CloudNetApi

  # API_ENDPOINT = "https://api.cloud.net" its used for live data

  API_ENDPOINT = "https://api.staging.cloud.net/" #now testing with staging data.

  class CloudNet

    def initialize auth_string
      @authentication_string = auth_string
      @connection = Faraday.new(API_ENDPOINT,{ssl: {verify: false}}) #its only for staging account
    end

  #initial connection setup encription with cloud.net

    def self.setup mail_id, api_secret
      auth_string = Base64.encode64("#{mail_id}:#{api_secret}")
      return self.new(auth_string) #creates new object of CloudNet for accessing all instance methods availabele 
    end

  #datacenter requests

    def get_all_datacenters
      return collection_request "datacenters"
    end

    def get_datacenter id
      return member_request id, "datacenters"
    end

  #server requests

    def get_all_servers
      return collection_request "servers"
    end

    def get_server id
      return member_request id, "servers"
    end

    # server CRUD actions

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

    def destroy_server id
      resp = @connection.delete("#{API_ENDPOINT}/servers/#{id}") do |req|
        req.headers["Authorization"] = "Basic #{@authentication_string}"
      end
      return JSON.parse(resp)
    end

    #server power options

    def reboot_server id
      return power_options id,"reboot"
    end

    def shutdown_server id
      return power_options id,"shutdown"
    end

    def startup_server id
      return power_options id,"startup"
    end

    private

      def collection_request type
        #send intial request for getting full response header and use total number of results to get all data in one request.
        
        resp = @connection.get("#{API_ENDPOINT}/#{type}") do |req|
          req.headers["Authorization"] = "Basic #{@authentication_string}" 
        end
        total_results = resp.headers["x-total"]
        
        #get all in one request

        full_data = @connection.get("#{API_ENDPOINT}/#{type}") do |req|
          req.params["per_page"] = total_results.to_i
          req.params["pege"] = 1
          req.headers["Authorization"] = "Basic #{@authentication_string}" 
        end

        return JSON.parse(full_data.body)

      end

      def member_request id, type
        resp = @connection.get("#{API_ENDPOINT}/#{type}/#{id}") do |req|
          req.headers["Authorization"] = "Basic #{@authentication_string}" 
        end
        return JSON.parse(resp.body) 
      end

      def power_options server_id, option
        resp = @connection.put("#{API_ENDPOINT}/servers/#{server_id}/#{option}") do |req|
          req.headers["Authorization"] = "Basic #{@authentication_string}"
        end
        return JSON.parse(resp.body)
      end
  end 
end
