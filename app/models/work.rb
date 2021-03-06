class Work < ApplicationRecord

  validates :name, presence: true, length: { minimum: 1, maximum: 25, message: "は1文字以上、25文字以内で入力してください" }
  validates :content, length: {maximum: 300, message: "300文字以内で入力してください" }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :start_finish_check
  validate :start_check
  # 現場
  belongs_to :site
  # 人数
  has_many :personnels, dependent: :destroy
  # 通知機能
  has_many :notifications, dependent: :destroy

  accepts_nested_attributes_for :personnels, allow_destroy: true



  def start_finish_check
    errors.add(:end_date, "は開始日時より遅い時間を選択してください") if self.start_date > self.end_date
  end

  def start_check
    errors.add(:start_date, "は現時刻から2日以上前の日時は選択できません") if self.start_date < Time.zone.now - 2.day
  end

# 作業の開始日時が2日過ぎているかどうか
  def work_started?(work)
    work.start_date > Time.zone.now - 2.day
  end

end
