class Repo < ApplicationRecord

    has_many :notifications
    belongs_to :user
end