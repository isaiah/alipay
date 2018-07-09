module Alipay
  module Notify
    def validate?(params, options = {})
      params = Utils.stringify_keys(params)
      Sign.verify?(params, options) &&
        Alipay::Notify.verify_notify_id?(@app_id, params['notify_id'], url: @url)
    end

    module_function

    def self.verify?(params, options = {})
      params = Utils.stringify_keys(params)
      Sign.verify?(params, options) && verify_notify_id?(Alipay.pid, params['notify_id'])
    end

    def self.verify_notify_id?(pid, notify_id, url: "https://mapi.alipay.com/gateway.do")
      uri = URI(url)
      uri.query = URI.encode_www_form(
        'service'   => 'notify_verify',
        'partner'   => pid,
        'notify_id' => notify_id
      )
      Net::HTTP.get(uri) == 'true'
    end
  end
end
