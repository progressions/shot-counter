class CampaignImageCopyService
  Result = Struct.new(:copied, :skipped, :missing, :errors, keyword_init: true)

  def self.call(...)
    new(...).call
  end

  def initialize(target_campaign:, source_campaign: nil, importer: ImageKitImporter, force: false, logger: default_logger)
    @target_campaign = target_campaign
    @source_campaign = source_campaign || Campaign.find_by(is_master_template: true)
    @importer = importer
    @force = force
    @logger = logger

    raise ArgumentError, "target_campaign must be present" unless @target_campaign.present?
    raise ArgumentError, "source_campaign must be present" unless @source_campaign.present?
    raise ArgumentError, "target_campaign must be persisted" unless @target_campaign.persisted?
    raise ArgumentError, "source_campaign must be persisted" unless @source_campaign.persisted?
  end

  def call
    {
      schticks: copy_collection(:schticks),
      weapons: copy_collection(:weapons)
    }
  end

  private

  attr_reader :source_campaign, :target_campaign, :importer, :force, :logger

  def copy_collection(association_name)
    return default_result unless supported_association?(association_name)

    result = default_result
    lookup = build_target_lookup(association_name)

    source_campaign.public_send(association_name).find_each do |source_record|
      canonical_name = canonical(source_record.name)
      target_record = lookup[canonical_name]

      unless target_record
        result.missing += 1
        next
      end

      source_image_url = raw_image_url(source_record)
      if source_image_url.blank?
        result.skipped += 1
        next
      end

      if target_has_image?(target_record) && !force
        result.skipped += 1
        next
      end

      begin
        importer.call(
          source_url: source_image_url,
          attachable: target_record,
          attachment_name: :image
        )
        result.copied += 1
      rescue StandardError => e
        logger.warn("Failed to copy #{association_name.to_s.singularize} image for #{source_record.name}: #{e.message}") if logger
        result.errors << { name: source_record.name, message: e.message }
      end
    end

    result
  end

  def supported_association?(association_name)
    source_campaign.respond_to?(association_name) && target_campaign.respond_to?(association_name)
  end

  def build_target_lookup(association_name)
    target_campaign
      .public_send(association_name)
      .includes(image_attachment: :blob)
      .index_by { |record| canonical(record.name) }
  end

  def canonical(value)
    value.to_s.strip.downcase
  end

  def raw_image_url(record)
    image_url_from_method(record)
  end

  def target_has_image?(record)
    record.respond_to?(:image) && record.image.attached?
  end

  def default_result
    Result.new(copied: 0, skipped: 0, missing: 0, errors: [])
  end

  def default_logger
    defined?(Rails) ? Rails.logger : Logger.new($stdout)
  end

  def image_url_from_method(record)
    return unless record.respond_to?(:image_url)

    record.image_url.presence
  rescue StandardError => e
    logger.warn("Failed to read image_url for #{record.class}##{record.id}: #{e.message}") if logger
    nil
  end
end
