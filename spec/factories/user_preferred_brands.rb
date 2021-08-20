# Read about factories at https://github.com/thoughtbot/factory_bot
require 'ffaker'

FactoryBot.define do
  factory :user_preferred_brand do
    user
    brand
  end
end
