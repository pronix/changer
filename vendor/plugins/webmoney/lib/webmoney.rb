# :title:Webmoney library Documentation
# :main:lib/webmoney.rb
# :include:README

require 'time'
require 'net/http'
require 'net/https'
require 'rubygems'
require 'iconv'
require 'nokogiri'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))
%w(wmsigner wmid passport purse request_xml request_retval request_result messenger).each { |lib| require lib }

# Module for Webmoney lib. Instance contain info
# for WMT-interfaces requests (wmid, key, etc).
# Implement general requests.
module Webmoney

  include RequestXML
  include RequestRetval
  include RequestResult

  # Error classes
  class WebmoneyError < StandardError; end
  class RequestError < WebmoneyError;  end
  class ResultError < WebmoneyError;  end
  class IncorrectWmidError < WebmoneyError; end
  class IncorrectPurseError < WebmoneyError; end
  class NonExistentWmidError < WebmoneyError; end
  class CaCertificateError < WebmoneyError; end
  
  attr_reader :wmid, :error, :errormsg, :last_request, :interfaces
  attr_accessor :messenger


  # Preset for W3S
  def w3s_url
    'https://w3s.wmtransfer.com/asp/'
  end

  # Presets for interfaces
  def interface_urls
    {
      :create_invoice      => w3s_url + 'XMLInvoice.asp',       # x1
      :create_transaction  => w3s_url + 'XMLTrans.asp',         # x2
      :operation_history   => w3s_url + 'XMLOperations.asp',    # x3
      :outgoing_invoices   => w3s_url + 'XMLOutInvoices.asp',   # x4
      :finish_protect      => w3s_url + 'XMLFinishProtect.asp', # x5
      :send_message        => w3s_url + 'XMLSendMsg.asp',       # x6
      :check_sign          => w3s_url + 'XMLClassicAuth.asp',   # x7
      :find_wm             => w3s_url + 'XMLFindWMPurse.asp',   # x8
      :balance             => w3s_url + 'XMLPurses.asp',        # x9
      :incoming_invoices   => w3s_url + 'XMLInInvoices.asp',    # x10
      :get_passport        => 'https://passport.webmoney.ru/asp/XMLGetWMPassport.asp', # x11
      :reject_protection   => w3s_url + 'XMLRejectProtect.asp', # x13
      :transaction_moneyback => w3s_url + 'XMLTransMoneyback.asp', # x14
      :i_trust             => w3s_url + 'XMLTrustList.asp',     # x15
      :trust_me            => w3s_url + 'XMLTrustList2.asp',    # x15
      :trust_save          => w3s_url + 'XMLTrustSave2.asp',    # x15
      :create_purse        => w3s_url + 'XMLCreatePurse.asp',   # x16
      :create_contract => 'https://arbitrage.webmoney.ru/xml/X17_CreateContract.aspx', # x17
      :transaction_get => 'https://merchant.webmoney.ru/conf/xml/XMLTransGet.asp', # x18
      :bussines_level  => 'https://stats.wmtransfer.com/levels/XMLWMIDLevel.aspx'
    }
  end


  # Required options:
  #
  # - :wmid - WMID
  # - :password - on Classic key or Light X509 certificate & key
  # - :key - Base64 string for Classic key
  #
  # OR
  # #TODO
  # - :key - OpenSSL::PKey::RSA or OpenSSL::PKey::DSA object
  # - :cert - OpenSSL::X509::Certificate object
  #
  # Optional:
  #
  # - :ca_cert - file CA certificate or path to directory with certs (in PEM format)

  def initialize(opt = {})

    @wmid = Wmid.new(opt[:wmid])

    # classic or light
    case opt[:key]
      when String
        @signer = Signer.new(@wmid, opt[:password], opt[:key])
      when OpenSSL::PKey::RSA, OpenSSL::PKey::DSA
        @key = opt[:key]
        @cert = opt[:cert]
        @password = opt[:password]
    end

    # ca_cert or default
    @ca_cert =
      if opt[:ca_cert].nil?
         File.dirname(__FILE__) + '/../lib/certs/'
      else
        opt[:ca_cert]
      end

    # Iconv.new(to, from)
    @ic_in = Iconv.new('UTF-8', 'CP1251')
    @ic_out = Iconv.new('CP1251', 'UTF-8')

    prepare_interface_urls

    # initialize workers by self
    Purse.worker = self
    Passport.worker = self
  end

  # Webmoney instance is classic type?
  def classic?
    !! @signer
  end
  
  # Send message through Queue and Thread
  #
  # Params: { :wmid, :subj, :text }

  def send_message(params)
    @messenger = Messenger.new(self){} if @messenger.nil?
    @messenger.push(params)
  end

  # Check existent WMID or not
  #
  # Params: wmid
  def wmid_exist?(wmid)
    request(:find_wm, :wmid => Wmid.new(wmid))[:retval] == 1
  end
  
  # Generic function for request to WMT-interfaces

  def request(iface, opt ={})
    raise ArgumentError, "should be hash" unless opt.kind_of?(Hash)

    # Use self wmid when not defined
    opt[:wmid] ||= @wmid

    # Do request
    res = https_request(iface, make_xml(iface, opt))

    # Parse response
    doc = Nokogiri::XML(res)
    parse_retval(iface, doc)
    make_result(iface, doc)
  end

  # Signing string by instance wmid's,
  # return signed string

  def sign(str)
    @signer.sign(str) unless str.nil? || str.empty?
  end

  protected

  def prepare_interface_urls
    @interfaces = interface_urls.inject({}) do |m,k|
      url = k[1]
      url.sub!(/(\.asp)/, 'Cert.asp') if !classic? && url.match("^"+w3s_url)
      m.merge!(k[0] => URI.parse(url))
    end
  end

  # Make HTTPS request, return result body if 200 OK

  def https_request(iface, xml)
    url = case iface
      when Symbol
        @interfaces[iface]
      when String
        URI.parse(iface)
    end
    raise ArgumentError, iface unless url
    http = Net::HTTP.new(url.host, url.port)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    if File.file? @ca_cert
      http.ca_file = @ca_cert
    elsif File.directory? @ca_cert
      http.ca_path = @ca_cert
    else
      raise CaCertificateError, @ca_cert
    end
    http.use_ssl = true
    @last_request = xml
    result = http.post( url.path, xml, "Content-Type" => "text/xml" )
    case result
      when Net::HTTPSuccess
        result.body
      else
        @error = result.code
        @errormsg = result.body if result.class.body_permitted?()
        raise RequestError, [@error, @errormsg].join(' ')
    end
  end

  # Create unique Request Number based on time,
  # return 16 digits string
  def reqn
    t = Time.now
    msec = t.to_f.to_s.match(/\.(\d\d)/)[1] rescue '00'
    t.strftime('%Y%m%d%H%M%S') + msec
  end

  def make_xml(iface, opt)            # :nodoc:
    iface_func = "xml_#{iface}"
    send(iface_func, opt).to_xml
  end

  def parse_retval(iface, doc)         # :nodoc:
    method = "retval_#{iface}"
    if respond_to?(method)
      send(method, doc)
    else
      retval_common(doc)
    end
  end

  def make_result(iface, doc)         # :nodoc:
    iface_result = "result_#{iface}"
    send(iface_result, doc)
  end

end
