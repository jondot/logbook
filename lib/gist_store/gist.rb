require 'gist_store/net_http_ext'
require 'open-uri'
require 'net/https'
require 'optparse'
require 'json'
require 'base64'



# You can use this class from other scripts with the greatest of
# ease.
#
#   >> Gist.read(gist_id)
#   Returns the body of gist_id as a string.
#
#   >> Gist.write(content)
#   Creates a gist from the string `content`. Returns the URL of the
#   new gist.
#
#   >> Gist.copy(string)
#   Copies string to the clipboard.
#
#   >> Gist.browse(url)
#   Opens URL in your default browser.
module Gist
  extend self

  GIST_URL   = 'https://api.github.com/gists/%s'
  CREATE_URL = 'https://api.github.com/gists'

  if ENV['HTTPS_PROXY']
    PROXY = URI(ENV['HTTPS_PROXY'])
  elsif ENV['HTTP_PROXY']
    PROXY = URI(ENV['HTTP_PROXY'])
  else
    PROXY = nil
  end
  PROXY_HOST = PROXY ? PROXY.host : nil
  PROXY_PORT = PROXY ? PROXY.port : nil


  # Create a gist on gist.github.com
  def write(files, private_gist = false, description = nil)
    url = URI.parse(CREATE_URL)

    if PROXY_HOST
      proxy = Net::HTTP::Proxy(PROXY_HOST, PROXY_PORT)
      http  = proxy.new(url.host, url.port)
    else
      http = Net::HTTP.new(url.host, url.port)
    end

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = ca_cert

    req = Net::HTTP::Post.new(url.path)
    req.body = JSON.generate(data(files, private_gist, description))

    user, password = auth()
    if user && password
      req.basic_auth(user, password)
    end

    response = http.start{|h| h.request(req) }
    case response
    when Net::HTTPCreated
      JSON.parse(response.body)['html_url']
    else
      raise "Creating gist failed: #{response.code} #{response.message}"
    end
  end

  # Create a gist on gist.github.com
  def update(id, files)
    url = URI.parse(CREATE_URL)

    if PROXY_HOST
      proxy = Net::HTTP::Proxy(PROXY_HOST, PROXY_PORT)
      http  = proxy.new(url.host, url.port)
    else
      http = Net::HTTP.new(url.host, url.port)
    end

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = ca_cert

    req = Net::HTTP::Patch.new(GIST_URL % id)
    req.body = JSON.generate(data(files, nil, nil))

    user, password = auth()
    if user && password
      req.basic_auth(user, password)
    end

    response = http.start{|h| h.request(req) }
    case response
    when Net::HTTPOK
      JSON.parse(response.body)['html_url']
    else
      raise "Updating gist failed: #{response.code} #{response.message}"
    end
  end


  
  # Create a gist on gist.github.com
  def delete(id)
    url = URI.parse(CREATE_URL)

    if PROXY_HOST
      proxy = Net::HTTP::Proxy(PROXY_HOST, PROXY_PORT)
      http  = proxy.new(url.host, url.port)
    else
      http = Net::HTTP.new(url.host, url.port)
    end

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = ca_cert

    req = Net::HTTP::Delete.new(GIST_URL % id)

    user, password = auth()
    if user && password
      req.basic_auth(user, password)
    end

    response = http.start{|h| h.request(req) }
    case response
    when Net::HTTPNoContent
      true
    else
      raise "Creating gist failed: #{response.code} #{response.message}"
    end
  end

  # Given a gist id, returns its content.
  def read(gist_id)
    data = read_raw(gist_id)
    data["files"].map{|name, content| content['content'] }.join("\n\n")
  end

  def read_raw(gist_id)
    data = JSON.parse(open(GIST_URL % gist_id).read)
  end


private
  # Give an array of file information and private boolean, returns
  # an appropriate payload for POSTing to gist.github.com
  def data(files, private_gist, description)
    i = 0
    file_data = {}
    files.each do |file|
      i = i + 1
      filename = file[:filename] ? file[:filename] : "gistfile#{i}"
      file_data[filename] = {:content => file[:input]}
    end

    data = {"files" => file_data}
    data.merge!({ 'description' => description }) unless description.nil?
    data.merge!({ 'public' => !private_gist }) unless private_gist.nil?
    data
  end

  # Returns a basic auth string of the user's GitHub credentials if set.
  # http://github.com/guides/local-github-config
  #
  # Returns an Array of Strings if auth is found: [user, password]
  # Returns nil if no auth is found.
  def auth
    user  = config("github.user")
    password = config("github.password")

    token = config("github.token")
    if password.to_s.empty? && !token.to_s.empty?
      raise "Please set GITHUB_PASSWORD or github.password instead of using a token."
    end

    if user.to_s.empty? || password.to_s.empty?
      nil
    else
      [ user, password ]
    end
  end

  # Returns default values based on settings in your gitconfig. See
  # git-config(1) for more information.
  #
  # Settings applicable to gist.rb are:
  #
  # gist.private - boolean
  # gist.extension - string
  def defaults
    extension = config("gist.extension")

    return {
      "private"   => config("gist.private"),
      "browse"    => config("gist.browse"),
      "extension" => extension
    }
  end

  # Reads a config value using:
  # => Environment: GITHUB_PASSWORD, GITHUB_USER
  #                 like vim gist plugin
  # => git-config(1)
  #
  # return something useful or nil
  def config(key)
    env_key = ENV[key.upcase.gsub(/\./, '_')]
    return env_key if env_key and not env_key.strip.empty?

    str_to_bool `git config --global #{key}`.strip
  end

  # Parses a value that might appear in a .gitconfig file into
  # something useful in a Ruby script.
  def str_to_bool(str)
    if str.size > 0 and str[0].chr == '!'
      command = str[1, str.length]
      value = `#{command}`
    else
      value = str
    end

    case value.downcase.strip
    when "false", "0", "nil", "", "no", "off"
      nil
    when "true", "1", "yes", "on"
      true
    else
      value
    end
  end

  def ca_cert
    cert_file = [
      File.expand_path("../cacert.pem", __FILE__),
      "/tmp/gist_cacert.pem"
    ].find{|l| File.exist?(l) }

    if cert_file
      cert_file
    else
      File.open("/tmp/gist_cacert.pem", "w") do |f|
        f.write(DATA.read.split("__CACERT__").last)
      end
      "/tmp/gist_cacert.pem"
    end
  end

end
