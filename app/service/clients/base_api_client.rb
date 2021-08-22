module Clients
  STATUS_OK = 1
  STATUS_ERROR = 0

  class BaseApiClient
    attr_reader :request_status, :response_message, :error_code

    def request_successful?
      request_status == STATUS_OK
    end

    def response_body
      @response_body ||= response.blank? ? nil : parse_body
    end

    private

    def handle_request(request)
      @response_body = nil
      @response_message = nil

      begin
        @response = execute_request(request)
      rescue StandardError => e
        @request_status = STATUS_ERROR
        @response_message = e.message
        Rails.logger.error "Error when making request - #{response_message}"
      end

      if response.present?
        handle_response
      end
    end

    def execute_request(proc)
      proc.call
    end

    def handle_response
      if response.success?
        @request_status = STATUS_OK
        @response_message = 'Request successful'
        return if response_body.blank?
      else
        @request_status = STATUS_ERROR
        @response_message = 'Request error'
      end
    end

    def parse_body
      return if response.body.empty?
      begin
        JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError => e
        nil
      end
    end

    protected

    attr_reader :response

    def perform_get_request(url, params = {})
      proc_request = proc { Faraday.get(url, params) }
      handle_request(proc_request)
    end
  end
end
