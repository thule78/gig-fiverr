class Request < ApplicationRecord
  belongs_to :user
  belongs_to :category

  has_one_attached :attachement_file

  validates :title, presence: {message: "cannot be empty"}
  validates :description, presence: {message: "cannot be empty"}
  validates :delivery, numbericality: {only_integer: true, message:"must be a number"}
end
