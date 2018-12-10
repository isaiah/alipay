require 'active_support/core_ext/hash'
require 'alipay/notify'
require 'nokogiri'
module Alipay
  module CrossBorder
    class Client
      include Alipay::Notify
      #沙箱网关The Alipay gateway of sandbox environment.
      ALIPAY_GATEWAY_SANDBOX_NEW = "https://openapi.alipaydev.com/gateway.do"
      #生产环境网关，如果商户用的生产环境请换成下面的正式网关
      #The Alipay gateway of production environment.(pls use the below line instead if you were in production environment)
      ALIPAY_GATEWAY_PRODUCTION_NEW = "https://intlmapi.alipay.com/gateway.do"

      PRODUCT_CODE = 'NEW_OVERSEAS_SELLER'
      PAYMENT_SERVICE = 'create_forex_trade'

      # Create a client to manage all API request.
      #
      # Example:
      #
      #   alipay_client = Alipay::CrossBorder::Client.new(
      #     env: 'sandbox',
      #     app_id: '2016000000000000',
      #     app_private_key: APP_PRIVATE_KEY,
      #     alipay_public_key: ALIPAY_PUBLIC_KEY
      #   )
      #
      # Options:
      #
      # [:url]  Alipay Open API gateway,
      #         'https://openapi.alipaydev.com/gateway.do'(Sandbox) or
      #         'https://openapi.alipay.com/gateway.do'(Production).
      #
      # [:app_id] Your APP ID.
      #
      # [:app_private_key] APP private key.
      #
      # [:alipay_public_key] Alipay public key.
      #
      # [:charset] default is 'UTF-8', only support 'UTF-8'.
      #
      # [:sign_type] default is 'RSA2', support 'RSA2', 'RSA', 'RSA2' is recommended.
      def initialize(options)
        options = ::Alipay::Utils.stringify_keys(options)
        @url = options['env'] == 'production' ? ALIPAY_GATEWAY_PRODUCTION_NEW : ALIPAY_GATEWAY_SANDBOX_NEW
        @app_id = options['app_id'] || options['partner']
        @sign_type = options['sign_type'] || 'RSA2'
        @app_private_key = options['app_private_key']
        @alipay_public_key = options['alipay_public_key']
        if @sign_type == 'MD5'
          key = @app_private_key || @alipay_public_key
          @app_private_key = @alipay_public_key = key
        end

        @charset = options['charset'] || 'UTF-8'
        @options = options
      end

      # Generate a query string that use for APP SDK excute.
      #
      # Example:
      #
      #   alipay_client.sdk_execute(
      #     method: 'alipay.trade.app.pay',
      #     biz_content: {
      #       out_trade_no: '20160401000000',
      #       product_code: 'QUICK_MSECURITY_PAY',
      #       total_amount: '0.01',
      #       subject: 'test'
      #     }.to_json(ascii_only: true),
      #     timestamp: '2016-04-01 00:00:00'
      #   )
      #   # => 'app_id=2016000000000000&charset=utf-8&sig....'
      def sdk_execute(params)
        params = prepare_params(params)

        URI.encode_www_form(params)
      end

      # Generate a url that use to redirect user to Alipay payment page.
      #
      # Example:
      #
      #   alipay_client.page_execute_url(
      #     method: 'alipay.trade.page.pay',
      #     biz_content: {
      #       out_trade_no: '20160401000000',
      #       product_code: 'FAST_INSTANT_TRADE_PAY',
      #       total_amount: '0.01',
      #       subject: 'test'
      #     }.to_json(ascii_only: true),
      #     timestamp: '2016-04-01 00:00:00'
      #   )
      #   # => 'https://openapi.alipaydev.com/gateway.do?app_id=2016...'
      def page_execute_url(params)
        params = prepare_params(params)

        uri = URI(@url)
        uri.query = URI.encode_www_form(params)
        uri.to_s
      end

      # Generate a form string that use to render in view and auto POST to
      # Alipay server.
      #
      # Example:
      #
      #   alipay_client.page_execute_form(
      #     method: 'alipay.trade.page.pay',
      #     biz_content: {
      #       out_trade_no: '20160401000000',
      #       product_code: 'FAST_INSTANT_TRADE_PAY',
      #       total_amount: '0.01',
      #       subject: 'test'
      #     }.to_json(ascii_only: true),
      #     timestamp: '2016-04-01 00:00:00'
      #   )
      #   # => '<form id='alipaysubmit' name='alipaysubmit' action=...'
      def page_execute_form(params)
        params = prepare_params(params)

        html = %Q(<form id='alipaysubmit' name='alipaysubmit' action='#{@url}' method='GET'>)
        params.keys.sort.each do |key|
          html << %Q(<input type='hidden' name="#{key}" value="#{params[key]}"/>)
        end
        html << "<input type='submit' value='ok' style='display:none'></form>"
        html << "<script>document.forms['alipaysubmit'].submit();</script>"
        html
      end

      # Immediately make a API request to Alipay and return response body.
      #
      # Example:
      #
      #   alipay_client.execute(
      #     method: 'alipay.data.dataservice.bill.downloadurl.query',
      #     biz_content: {
      #       bill_type: 'trade',
      #       bill_date: '2016-04-01'
      #     }.to_json(ascii_only: true)
      #   )
      #   # => '{ "alipay_data_dataservice_bill_downloadurl_query_response":{...'
      def execute(params)
        params = prepare_params(params)

        Net::HTTP.post_form(URI(@url), params).body
      end

      # Generate sign for params.
      def sign(params)
        string = params_to_string(params)

        case @sign_type
        when 'RSA'
          ::Alipay::Sign::RSA.sign(@app_private_key, string)
        when 'RSA2'
          ::Alipay::Sign::RSA2.sign(@app_private_key, string)
        when 'MD5'
          ::Alipay::Sign::MD5.sign(@app_private_key, string)
        else
          raise "Unsupported sign_type: #{@sign_type}"
        end
      end

      # Verify Alipay notification.
      #
      # Example:
      #
      #   params = {
      #     out_trade_no: '20160401000000',
      #     trade_status: 'TRADE_SUCCESS'
      #     sign_type: 'RSA2',
      #     sign: '...'
      #   }
      #   alipay_client.verify?(params)
      #   # => true / false
      def verify?(params)
        params = Utils.stringify_keys(params)
        return false if params['sign_type'] != @sign_type

        sign = params.delete('sign')
        # sign_type does not use in notify sign
        params.delete('sign_type')
        string = params_to_string(params)
        case @sign_type
        when 'RSA'
          ::Alipay::Sign::RSA.verify?(@alipay_public_key, string, sign)
        when 'RSA2'
          ::Alipay::Sign::RSA2.verify?(@alipay_public_key, string, sign)
        when 'MD5'
          ::Alipay::Sign::MD5.verify?(@alipay_public_key, string, sign)
        else
          raise "Unsupported sign_type: #{@sign_type}"
        end
      end

      def sign_autodebit(opts = {})
        params = { service: 'alipay.dut.customer.agreement.page.sign',
                                product_code: 'GENERAL_WITHHOLDING_P',
                                sales_product_code: 'FOREX_GENERAL_WITHHOLDING' }
        page_execute_form(params.merge(opts))
      end

      def refund(refund_no:, order_id:, amount:, currency:, reason: nil)
        params = prepare_params(out_return_no: refund_no,
                                out_trade_no: order_id,
                                return_amount: amount,
                                currency: currency,
                                gmt_return: Time.now.getlocal("+08:00").strftime("%Y%m%d%H%M%S"),
                                service: 'forex_refund')

        uri = URI(@url)
        uri.query = URI.encode_www_form(params)
        resp = Net::HTTP.get(uri)
        doc = Nokogiri::XML(resp)
        {success: doc.xpath('/alipay/is_success').text == 'T',
         error: doc.xpath('//error').text}
      end

      def query_transaction_status(order_id)
        params = prepare_params(out_trade_no: order_id,
                                service: 'single_trade_query')
        uri = URI(@url)
        uri.query = URI.encode_www_form(params)
        resp = Net::HTTP.get(uri)
        doc = Nokogiri::XML(resp)

        {
          success: doc.xpath('/alipay/is_success').text == 'T',
          error: doc.xpath('/alipay/error'),
          status: doc.xpath('//trade/trade_status').text,
          transaction_no: doc.xpath('//trade/trade_no').text,
        }
      end

      private

      def prepare_params(params)
        params = ::Alipay::Utils.stringify_keys(params)
        params['split_fund_info'] &&= params['split_fund_info'].gsub("\"", "'")

        params = @options.slice('return_url', 'notify_url').merge({
          'partner' => @app_id,
          '_input_charset' => @charset,
          'product_code' => PRODUCT_CODE,
          'service' => PAYMENT_SERVICE,
        }).merge(params.except('sign', 'sign_type')).reject{|k, v| !v}
        params['sign'] = sign(params)
        params['sign_type'] = @sign_type
        params
      end

      def params_to_string(params)
        params.sort.map { |item| item.join('=') }.join('&')
      end
    end
  end
end
