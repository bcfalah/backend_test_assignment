# Read about factories at https://github.com/thoughtbot/factory_bot
require 'ffaker'

FactoryBot.define do
  factory :brand do
    name { FFaker::Vehicle.make }
  end
end
