class UsersToImport < ApplicationRecord
  scope :waiting, -> { where(status: "waiting").order(:id) }
  scope :done, -> { where(status: "done") }

  def self.left
    self.waiting.count
  end

  def self.completed
    self.done.count
  end

  def complete
    update(status: "done")
  end
end
