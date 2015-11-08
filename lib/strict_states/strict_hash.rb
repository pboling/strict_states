require "hashie/extensions/strict_key_access"

module StrictStates
  class StrictHash < Hash
    include Hashie::Extensions::StrictKeyAccess
  end
end
