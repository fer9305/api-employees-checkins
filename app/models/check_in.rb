class CheckIn < ApplicationRecord
  belongs_to :user

  validates :begin_time, presence: true
  validate :end_time_after_begin_time

  scope :today, -> { where("begin_time >= ? AND begin_time <= ?", Time.current.beginning_of_day, Time.current.end_of_day) }

  private
    def end_time_after_begin_time
      return if end_time.blank?

      if end_time < begin_time
        errors.add(:end_time, "must be after the begin time")
      end
    end
end
