# Read about factories at https://github.com/thoughtbot/factory_bot
require 'ffaker'

FactoryBot.define do
  factory :car do
    model { FFaker::Vehicle.model }
    brand
    price { FFaker::Random.rand(10000000) }
  end
end
