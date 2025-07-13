class Role < ApplicationRecord
  validates :name, presence: true, uniqueness: true, inclusion: { in: %w[user admin] }

  has_many :users
end
