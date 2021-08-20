require 'rails_helper'

RSpec.describe 'Cars', type: :request do
  describe 'GET /recommended' do
    context 'on error' do
      context 'when user_id is not specified' do
        it 'should return a 404' do
          # post '/api/v1/users', :params => user_params.to_json, :headers => { "Content-Type": "application/json" }
          get recommended_cars_path, params: {}
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include("Couldn't find User without an ID")
        end
      end
    end

    context 'on success' do
      let(:user) { FactoryBot.create(:user, preferred_price_range: 1000..1500) }
      let(:brand1) { FactoryBot.create(:brand) }
      let(:brand2) { FactoryBot.create(:brand) }
      let!(:user_preferred_brand1) { FactoryBot.create(:user_preferred_brand, user: user, brand: brand1) }

      let!(:car_perfect_match) { FactoryBot.create(:car, brand: brand1, price: 1250) }
      let!(:car_good_match) { FactoryBot.create(:car, brand: brand1, price: 1501) }
      let!(:car_no_match) { FactoryBot.create(:car, brand: brand2) }
      let(:parsed_body) { JSON.parse(response.body, symbolize_names: true) }
      let(:expected_response) { [ expected_car_1, expected_car_2] }

      let(:expected_car_1) do
        {
          brand: {id: brand1.id, name: brand1.name },
          id: car_perfect_match.id,
          label: 'perfect_match',
          model: car_perfect_match.model,
          price: car_perfect_match.price,
          rank_score: nil
        }
      end

      let(:expected_car_2) do
        {
          brand: {id: brand1.id, name: brand1.name },
          id: car_good_match.id,
          label: 'good_match',
          model: car_good_match.model,
          price: car_good_match.price,
          rank_score: nil
        }
      end

      context 'when only user_id is used' do
        it 'should return cars ordered by match and price' do
          # post '/api/v1/users', :params => user_params.to_json, :headers => { "Content-Type": "application/json" }
          get recommended_cars_path, params: { user_id: user.id }
          expect(response).to have_http_status(:ok)
          expect(parsed_body.size).to eq(2)
          expect(parsed_body).to eq(expected_response)
        end
      end

    end
  end
end
