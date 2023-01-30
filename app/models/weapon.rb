class Weapon < ApplicationRecord
  validate :name, presence: true
  validate :damage, presence: true
end
