require 'rails_helper'

RSpec.describe PdfService, type: :service do
  let!(:gamemaster) do
    User.create!(
      email: 'gamemaster@example.com',
      first_name: 'Game',
      last_name: 'Master',
      password: 'TestPass123!',
      gamemaster: true
    )
  end
  
  let(:campaign) do
    Campaign.create!(
      name: 'Test Campaign',
      user: gamemaster
    )
  end
  
  # Mock PDF field structure to simulate pdftk output
  let(:mock_field) { Struct.new(:name, :value) }
  
  describe '.get_secondary_attack_from_pdf' do
    context 'with valid backup attack formats' do
      it 'parses "Backup Attack: Martial Arts: 12" format correctly' do
        fields = [
          mock_field.new("Skills", "Deceit: 8\r\nBackup Attack: Martial Arts: 12\r\nDodge: 10")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to eq({
          "SecondaryAttack" => "Martial Arts",
          "Martial Arts" => 12
        })
      end
      
      it 'parses "Backup Attack: Guns: 10" format correctly' do
        fields = [
          mock_field.new("Skills", "Backup Attack: Guns: 10\r\nDeceit: 8")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to eq({
          "SecondaryAttack" => "Guns",
          "Guns" => 10
        })
      end
      
      it 'parses backup attack with extra whitespace' do
        fields = [
          mock_field.new("Skills", "  Backup Attack:   Sorcery  :  15  \r\nDodge: 8")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to eq({
          "SecondaryAttack" => "Sorcery",
          "Sorcery" => 15
        })
      end
      
      it 'handles backup attack at end of skills list' do
        fields = [
          mock_field.new("Skills", "Deceit: 8\r\nDodge: 10\r\nBackup Attack: Guns: 13")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to eq({
          "SecondaryAttack" => "Guns",
          "Guns" => 13
        })
      end
      
      it 'handles single backup attack entry' do
        fields = [
          mock_field.new("Skills", "Backup Attack: Martial Arts: 14")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to eq({
          "SecondaryAttack" => "Martial Arts",
          "Martial Arts" => 14
        })
      end
    end
    
    context 'with no backup attack' do
      it 'returns nil when no backup attack is present' do
        fields = [
          mock_field.new("Skills", "Deceit: 8\r\nDodge: 10\r\nGuns: 12")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to be_nil
      end
      
      it 'returns nil when Skills field is empty' do
        fields = [
          mock_field.new("Skills", "")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to be_nil
      end
      
      it 'returns nil when Skills field is nil' do
        fields = [
          mock_field.new("Skills", nil)
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to be_nil
      end
    end
    
    context 'with malformed backup attack entries' do
      it 'returns nil for backup attack without value' do
        fields = [
          mock_field.new("Skills", "Backup Attack: Martial Arts\r\nDeceit: 8")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to be_nil
      end
      
      it 'returns nil for backup attack with non-numeric value' do
        fields = [
          mock_field.new("Skills", "Backup Attack: Martial Arts: abc\r\nDeceit: 8")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to be_nil
      end
      
      it 'returns nil for backup attack with missing skill name' do
        fields = [
          mock_field.new("Skills", "Backup Attack: : 12\r\nDeceit: 8")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to be_nil
      end
      
      it 'handles backup attack with zero value' do
        fields = [
          mock_field.new("Skills", "Backup Attack: Martial Arts: 0\r\nDeceit: 8")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to eq({
          "SecondaryAttack" => "Martial Arts",
          "Martial Arts" => 0
        })
      end
    end
    
    context 'with multiple backup attack entries' do
      it 'returns the first valid backup attack when multiple are present' do
        fields = [
          mock_field.new("Skills", "Backup Attack: Martial Arts: 12\r\nBackup Attack: Guns: 10\r\nDeceit: 8")
        ]
        
        result = PdfService.get_secondary_attack_from_pdf(fields)
        
        expect(result).to eq({
          "SecondaryAttack" => "Martial Arts",
          "Martial Arts" => 12
        })
      end
    end
  end
  
  describe '.pdf_attributes_for_character' do
    let(:fields) do
      [
        mock_field.new("Name", "Test Character"),
        mock_field.new("Attack Type", "Guns"),
        mock_field.new("Attack", "13"),
        mock_field.new("Defense", "12"),
        mock_field.new("Toughness", "8"),
        mock_field.new("Fortune Type", "Fortune"),
        mock_field.new("Fortune", "5"),
        mock_field.new("Speed", "7"),
        mock_field.new("Skills", "Deceit: 8\r\nBackup Attack: Martial Arts: 14\r\nDodge: 10"),
        mock_field.new("Archetype", "Cop"),
        mock_field.new("Wealth", "Working Stiff")
      ]
    end
    
    it 'correctly integrates backup attack parsing into character attributes' do
      result = PdfService.pdf_attributes_for_character(fields, campaign)
      
      expect(result[:action_values]).to include({
        "SecondaryAttack" => "Martial Arts",
        "Martial Arts" => 14
      })
    end
    
    it 'excludes backup attack from regular skills parsing' do
      result = PdfService.pdf_attributes_for_character(fields, campaign)
      
      # Skills should not include the "Backup Attack" entry
      expect(result[:skills]).to eq({
        "Deceit" => 8,
        "Dodge" => 10
      })
      expect(result[:skills]).not_to have_key("Backup Attack")
    end
  end
end