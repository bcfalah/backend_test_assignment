require 'rails_helper'

RSpec.describe 'Cars', type: :request do
  describe 'GET /recommended' do
    context 'on error' do
      context 'when user_id is not specified' do
        it 'should return a 404' do
          get recommended_cars_path, params: {}
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include("Couldn't find User without an ID")
        end
      end
    end

    context 'on success' do
      let(:user) { FactoryBot.create(:user, preferred_price_range: 1000..1500) }
      let(:brand1) { FactoryBot.create(:brand, name: 'Toyota') }
      let(:brand2) { FactoryBot.create(:brand, name: 'Honda') }
      let!(:user_preferred_brand1) { FactoryBot.create(:user_preferred_brand, user: user, brand: brand1) }

      let!(:car_perfect_match) { FactoryBot.create(:car, brand: brand1, price: 1250) }
      let!(:car_good_match) { FactoryBot.create(:car, brand: brand1, price: 1501) }
      let!(:car_ai_match) { FactoryBot.create(:car, brand: brand2, price: 500) }
      let!(:car_no_match) { FactoryBot.create(:car, brand: brand2, price: 1001) }
      let(:parsed_body) { JSON.parse(response.body, symbolize_names: true) }

      let(:expected_car_perfect_match) do
        {
          brand: {id: brand1.id, name: brand1.name },
          id: car_perfect_match.id,
          label: 'perfect_match',
          model: car_perfect_match.model,
          price: car_perfect_match.price,
          rank_score: nil
        }
      end

      let(:expected_car_good_match) do
        {
          brand: {id: brand1.id, name: brand1.name },
          id: car_good_match.id,
          label: 'good_match',
          model: car_good_match.model,
          price: car_good_match.price,
          rank_score: nil
        }
      end

      let(:expected_car_ai_match) do
        {
          brand: {id: brand2.id, name: brand2.name },
          id: car_ai_match.id,
          label: nil,
          model: car_ai_match.model,
          price: car_ai_match.price,
          rank_score: car_ai_match_rank_score
        }
      end
      let(:car_ai_match_rank_score) { 0.945 }

      let(:expected_car_no_match) do
        {
          brand: {id: brand2.id, name: brand2.name },
          id: car_no_match.id,
          label: nil,
          model: car_no_match.model,
          price: car_no_match.price,
          rank_score: nil
        }
      end

      before do
        cars_rec_api_response = [
          { "car_id": car_ai_match.id, "rank_score": car_ai_match_rank_score }
        ]

        stub_request(:get, "#{ENV['CARS_RECOMMENDATION_API_URL']}/recomended_cars.json?user_id=#{user.id}").
          to_return(status: 200, body: cars_rec_api_response.to_json, headers: {"Content-Type"=> "application/json"})
      end

      context 'when only user_id is used' do
        let(:expected_response) do
          [
            expected_car_perfect_match,
            expected_car_good_match,
            expected_car_ai_match,
            expected_car_no_match
          ]
        end

        it 'should return cars ordered by match and price' do
          get recommended_cars_path, params: { user_id: user.id }
          expect(response).to have_http_status(:ok)
          expect(parsed_body.size).to eq(4)
          expect(parsed_body).to eq(expected_response)
        end
      end

      context 'when query param is used' do
        let(:expected_response) do
          [
            expected_car_perfect_match,
            expected_car_good_match
          ]
        end

        it 'should return only cars of that brand name' do
          get recommended_cars_path, params: { user_id: user.id, query: 'Toyota' }
          expect(response).to have_http_status(:ok)
          expect(parsed_body.size).to eq(2)
          expect(parsed_body).to eq(expected_response)
        end

        context 'when using a part of the brand name in the query' do
          it 'should return only cars matching that brand name' do
            get recommended_cars_path, params: { user_id: user.id, query: 'Toy' }
            expect(response).to have_http_status(:ok)
            expect(parsed_body.size).to eq(2)
            expect(parsed_body).to eq(expected_response)
          end
        end

        context 'when using part of a brand name not preferred by the user ' do
          let(:expected_response) do
            [
              expected_car_ai_match,
              expected_car_no_match
            ]
          end

          it 'should return only cars matching that brand name' do
            get recommended_cars_path, params: { user_id: user.id, query: 'onda' }
            expect(response).to have_http_status(:ok)
            expect(parsed_body.size).to eq(2)
            expect(parsed_body).to eq(expected_response)
          end
        end
      end

      context 'when price_min and price_max params are used' do
        let(:expected_response) do
          [
            expected_car_perfect_match,
            expected_car_no_match
          ]
        end

        it 'should return only cars in this price range' do
          get recommended_cars_path, params: { user_id: user.id, price_min: 1000, price_max: 1250 }
          expect(response).to have_http_status(:ok)
          expect(parsed_body.size).to eq(2)
          expect(parsed_body).to eq(expected_response)
        end

        context 'when only price_min is used' do
          let(:expected_response) do
            [
              expected_car_good_match
            ]
          end

          it 'should return only cars in this price range' do
            get recommended_cars_path, params: { user_id: user.id, price_min: 1500 }
            expect(response).to have_http_status(:ok)
            expect(parsed_body.size).to eq(1)
            expect(parsed_body).to eq(expected_response)
          end
        end

        context 'when only price_max is used' do
          let(:expected_response) do
            [
              expected_car_ai_match,
              expected_car_no_match,
            ]
          end

          it 'should return only cars in this price range' do
            get recommended_cars_path, params: { user_id: user.id, price_max: 1002 }
            expect(response).to have_http_status(:ok)
            expect(parsed_body.size).to eq(2)
            expect(parsed_body).to eq(expected_response)
          end
        end
      end

      context 'when page param is used' do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('RECOMMENDED_CARS_PER_PAGE').and_return '2'
        end

        context 'page 1' do
          let(:expected_response) do
            [
              expected_car_perfect_match,
              expected_car_good_match
            ]
          end

          it 'should return only cars in this price range' do
            get recommended_cars_path,
              params: { user_id: user.id, page: 1 }
            expect(response).to have_http_status(:ok)
            expect(parsed_body.size).to eq(2)
            expect(parsed_body).to eq(expected_response)
          end
        end

        context 'page 2' do
          let(:expected_response) do
            [
              expected_car_ai_match,
              expected_car_no_match
            ]
          end

          it 'should return only cars in this price range' do
            get recommended_cars_path,
              params: { user_id: user.id, page: 2 }
            expect(response).to have_http_status(:ok)
            expect(parsed_body.size).to eq(2)
            expect(parsed_body).to eq(expected_response)
          end
        end
      end

      context 'when all params are used' do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with('RECOMMENDED_CARS_PER_PAGE').and_return '1'
        end

        let(:expected_response) do
          [
            expected_car_no_match
          ]
        end

        it 'should return only cars in this price range' do
          get recommended_cars_path,
            params: { user_id: user.id, query: 'Hon', price_min: 500, price_max: 1500, page: 2 }
          expect(response).to have_http_status(:ok)
          expect(parsed_body.size).to eq(1)
          expect(parsed_body).to eq(expected_response)
        end
      end
    end
  end
end
