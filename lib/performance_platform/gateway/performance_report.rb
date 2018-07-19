class PerformancePlatform::Gateway::HttpError < StandardError; end

class PerformancePlatform::Gateway::PerformanceReport
  def send_stats(data)
    uri = build_url(data)

    post(uri, data[:payload])
  end

private

  def post(uri, data)
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{ENV['PERFORMANCE_BEARER_VOLUMETRICS']}"
    request['Content-Type'] = 'application/json'
    request.body = data.to_json

    Net::HTTP.start(uri.hostname, 443, use_ssl: true) do |http|
      response = http.request(request)

      raise PerformancePlatform::Gateway::HttpError, "#{response.code} - #{response.body}" \
        unless response.code == '200'

      JSON.parse(response.body)
    end
  end

  def build_url(data)
    URI("#{ENV['PERFORMANCE_URL']}data/gov-wifi/#{data[:metric_name]}")
  end
end
