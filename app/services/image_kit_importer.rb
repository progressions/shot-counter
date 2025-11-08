require "cgi"
require "net/http"
require "openssl"
require "tempfile"
require "uri"

# Downloads an ImageKit-hosted asset and attaches it to any Active Storage relation.
# Usage:
#   ImageKitImporter.call(source_url: "https://...", attachable: character)
class ImageKitImporter
  DownloadError = Class.new(StandardError)

  DEFAULT_ATTACHMENT = :image
  MAX_REDIRECTS = 5
  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 15
  RELAXED_VERIFY_CALLBACK = lambda do |ok, ctx|
    ok || ctx.error == OpenSSL::X509::V_ERR_UNABLE_TO_GET_CRL
  end

  def self.call(...)
    new(...).call
  end

  def initialize(source_url:, attachable:, attachment_name: DEFAULT_ATTACHMENT, filename: nil, content_type: nil)
    @original_uri = URI.parse(source_url.to_s)
    @attachable = attachable
    @attachment_name = attachment_name
    @filename = filename
    @content_type = content_type

    unless @attachable.respond_to?(attachment_name)
      raise ArgumentError, "#{attachable.class} does not have #{attachment_name} attachment"
    end
  rescue URI::InvalidURIError => e
    raise ArgumentError, "Invalid ImageKit URL: #{e.message}"
  end

  def call
    tempfile = Tempfile.new(%w[image_kit_import .tmp])
    tempfile.binmode

    download_into(tempfile, @original_uri, MAX_REDIRECTS)
    tempfile.rewind

    attachment.attach(
      io: tempfile,
      filename: final_filename,
      content_type: final_content_type,
      metadata: metadata_payload
    )
  ensure
    tempfile&.close!
  end

  private

  attr_reader :attachment_name

  def attachment
    @attachable.public_send(attachment_name)
  end

  def download_into(tempfile, uri, redirects_remaining, relaxed_ssl: false)
    raise DownloadError, "Too many redirects for #{uri}" if redirects_remaining.negative?

    request = Net::HTTP::Get.new(uri)

    with_http(uri, relaxed_ssl: relaxed_ssl) do |http|
      http.request(request) do |response|
        case response
        when Net::HTTPSuccess
          @final_uri = uri
          assign_response_metadata(response)
          response.read_body { |chunk| tempfile.write(chunk) }
        when Net::HTTPRedirection
          location = response["location"]
          raise DownloadError, "Redirect missing location for #{uri}" if location.blank?

          next_uri = build_redirect_uri(uri, location)
          download_into(tempfile, next_uri, redirects_remaining - 1, relaxed_ssl: relaxed_ssl)
        else
          raise DownloadError, "ImageKit download failed with #{response.code} #{response.message}"
        end
      end
    end
  rescue OpenSSL::SSL::SSLError => e
    raise unless crl_error?(e) && !relaxed_ssl

    Rails.logger.warn("Retrying ImageKit download without CRL verification: #{e.message}") if defined?(Rails)
    download_into(tempfile, uri, redirects_remaining, relaxed_ssl: true)
  end

  def with_http(uri, relaxed_ssl:)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT

    if http.use_ssl?
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.cert_store = cert_store
      http.verify_callback = RELAXED_VERIFY_CALLBACK if relaxed_ssl
    end

    http.start { |connection| yield(connection) }
  end

  def assign_response_metadata(response)
    @content_type ||= response["content-type"]
    @filename ||= filename_from_response(response)
  end

  def filename_from_response(response)
    filename_from_disposition(response["content-disposition"]) || default_filename
  end

  def filename_from_disposition(disposition)
    return if disposition.blank?

    match = disposition.match(/filename\*?=(?:UTF-8'')?\"?([^\";]+)\"?/i)
    CGI.unescape(match[1]) if match
  rescue ArgumentError
    nil
  end

  def default_filename
    candidate = File.basename(source_uri_for_metadata.path.to_s)
    candidate = nil if candidate.blank? || candidate == "/"
    candidate || "image-kit-import.jpg"
  end

  def final_filename
    @filename.presence || default_filename
  end

  def final_content_type
    @content_type.presence
  end

  def metadata_payload
    {
      imagekit_url: source_uri_for_metadata.to_s,
      imagekit_file_path: source_uri_for_metadata.path.to_s.delete_prefix("/").presence
    }.compact
  end

  def source_uri_for_metadata
    @final_uri || @original_uri
  end

  def cert_store
    @cert_store ||= OpenSSL::X509::Store.new.tap(&:set_default_paths)
  end

  def crl_error?(error)
    error.message.to_s.include?("unable to get certificate CRL")
  end

  def build_redirect_uri(current_uri, location)
    candidate = URI.parse(location)
    candidate = current_uri + location unless candidate.absolute?
    candidate
  rescue URI::InvalidURIError => e
    raise DownloadError, "Invalid redirect location: #{location.inspect} (#{e.message})"
  end
end
