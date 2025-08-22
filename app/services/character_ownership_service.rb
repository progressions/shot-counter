class CharacterOwnershipService
  attr_reader :character, :new_owner, :actor, :errors

  def initialize(character:, new_owner:, actor:)
    @character = character
    @new_owner = new_owner
    @actor = actor
    @errors = []
  end

  def self.transfer(character:, new_owner:, actor:)
    new(character: character, new_owner: new_owner, actor: actor).transfer
  end

  def transfer
    return false unless validate_transfer

    ActiveRecord::Base.transaction do
      old_owner = character.user
      
      # Update the character's owner
      character.user = new_owner
      
      if character.save
        log_ownership_change(old_owner, new_owner)
        true
      else
        @errors.concat(character.errors.full_messages)
        raise ActiveRecord::Rollback
      end
    end
    
    @errors.empty?
  rescue StandardError => e
    @errors << "Transfer failed: #{e.message}"
    false
  end

  private

  def validate_transfer
    # Check actor authorization
    unless can_transfer?
      @errors << "You are not authorized to transfer ownership of this character"
      return false
    end

    # Check new owner exists
    unless new_owner.present?
      @errors << "New owner must be specified"
      return false
    end

    # Check new owner is in campaign
    unless character.campaign.users.include?(new_owner)
      @errors << "New owner must be a member of the campaign"
      return false
    end

    # Check if actually changing owner
    if character.user_id == new_owner.id
      @errors << "Character already belongs to this user"
      return false
    end

    true
  end

  def can_transfer?
    # Admin can transfer any character
    return true if actor.admin?
    
    # Gamemaster can transfer characters in their campaign
    return true if character.campaign.user == actor
    
    false
  end

  def log_ownership_change(old_owner, new_owner)
    Rails.logger.info(
      "Character ownership transferred: " \
      "Character ##{character.id} (#{character.name}) " \
      "from User ##{old_owner&.id} (#{old_owner&.email || 'none'}) " \
      "to User ##{new_owner.id} (#{new_owner.email}) " \
      "by User ##{actor.id} (#{actor.email}) " \
      "at #{Time.current}"
    )
  end
end