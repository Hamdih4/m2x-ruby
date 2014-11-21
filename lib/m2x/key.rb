# Wrapper for AT&T M2X Keys API
# https://m2x.att.com/developer/documentation/v2/keys
class M2X::Client::Key

  PATH = "/keys"

  class << self
    # List all the Master API Key that belongs to the user associated
    # with the AT&T M2X API key supplied when initializing M2X
    def list(client, params={})
      res = client.get(PATH, params)

      res.json["keys"].map{ |atts| new(client, atts) } if res.success?
    end

    # Create a new API Key
    #
    # Note that, according to the parameters sent, you can create a
    # Master API Key or a Device/Stream API Key. See
    # https://m2x.att.com/developer/documentation/keys#Create-Key for
    # details on the parameters accepted by this method.
    def create!(client, params={})
      res = client.post(PATH, nil, params, "Content-Type" => "application/json")

      new(client, res.json) if res.success?
    end
  end

  def path
    @path ||= "#{ PATH }/#{ URI.encode(@attributes.fetch("key")) }"
  end

  # Regenerate an API Key token
  #
  # Note that if you regenerate the key that you're using for
  # authentication then you would need to change your scripts to
  # start using the new key token for all subsequent requests.
  def regenerate
    res = @client.post("#{path}/regenerate", nil, {})

    if res.success?
      @path = nil
      @attributes = res.json
    end
  end
end
