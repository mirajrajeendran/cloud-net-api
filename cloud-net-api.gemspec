Gem::Specification.new do |spec|
  
  spec.name = "cloud-net-api"
  spec.version = "0.0.1"
  spec.authors = ["Miraj P Rajeendran", "Tinu"]
  spec.email = ["miraj@nuventure.in"]
  spec.summary = "Cloud.net API endpoit wrapper"
  spec.description = "All apis in one gem"
  spec.files = ["lib/cloud-net-api.rb"]
  spec.license = 'MIT'

  spec.add_dependency 'faraday'
  spec.add_dependency 'json'
end