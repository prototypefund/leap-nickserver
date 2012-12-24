$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'minitest/autorun'
require 'webmock/minitest'
require 'nickserver'

class MiniTest::Unit::TestCase
  # Add global extensions to the test case class here

  def setup
    # by default, mock all non-localhost network connections
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  def file_content(filename)
    (@file_contents ||= {})[filename] ||= File.read("%s/files/%s" % [File.dirname(__FILE__), filename])
  end

  def real_network
    if ENV['REAL_NET'] == 'true'
      WebMock.allow_net_connect!
      yield
      WebMock.disable_net_connect!
    end
  end

  def stub_vindex_response(uid, opts = {})
    options = {:status => 200, :body => ""}.merge(opts)
    stub_http_request(:get, Nickserver::Config.sks_url).with(
      :query => {:op => 'vindex', :search => uid, :exact => 'on', :options => 'mr', :fingerprint => 'on'}
    ).to_return(options)
  end

  def stub_get_response(key_id, opts = {})
    options = {:status => 200, :body => ""}.merge(opts)
    stub_http_request(:get, Nickserver::Config.sks_url).with(
      :query => {:op => 'get', :search => "0x"+key_id, :exact => 'on', :options => 'mr'}
    ).to_return(options)
  end

end