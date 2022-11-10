require "faraday"
require "logger"
require "json"

class Dune
  BASE_URL = "https://api.dune.com/api/v1"
  autoload :VERSION, "dune/version"
  autoload :Client, "dune/client"
  autoload :Error, "dune/error"
end
