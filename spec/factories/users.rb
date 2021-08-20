# Read about factories at https://github.com/thoughtbot/factory_bot
require 'ffaker'

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    preferred_price_range do
      range_begin = FFaker::Random.rand(10000000)
      range_end = range_begin + FFaker::Random.rand(10000000)
      (range_begin..range_end)
    end
  end
end
