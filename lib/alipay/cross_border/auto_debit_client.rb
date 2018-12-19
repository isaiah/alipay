require 'alipay/cross_border/client'

module Alipay
  module CrossBorder
    class AutoDebitClient < Client
      def sign_agreement(token:, access_channel: 'PC', scene: 'INDUSTRY|TAVEL')
        params = {
          access_info: '{"channel": "' + access_channel + '"}',
          external_sign_no: token,
          scene: scene,
          third_party_type: 'PARTNER',
          service: 'alipay.dut.customer.agreement.page.sign',
          product_code: 'GENERAL_WITHHOLDING_P',
          sales_product_code: 'FOREX_GENERAL_WITHHOLDING'
        }
        page_execute_url(params)
      end

      def unsign_agreement(token: token, notify_url: nil, scene: 'INDUSTRY|TRAVEL')
        doc = sdk_execute(service: 'alipay.dut.customer.agreement.unsign',
                          scene: scene,
                          product_code: 'GENERAL_WITHHOLDING_P',
                          external_sign_no: token,
                          notify_url: notify_url
                         )
        {success: doc.xpath('/alipay/is_success').text == 'T',
         error: doc.xpath('//error').text}
      end

      def query_agreement(token:, scene: 'INDUSTRY|TRAVEL')
        doc = sdk_execute(service: 'alipay.dut.customer.agreement.query',
                          product_code: 'FOREX_GENERAL_WITHHOLDING',
                          scene: scene,
                          external_sign_no: token)
        {success: doc.xpath('/alipay/is_success').text == 'T',
         error: doc.xpath('//error').text,
         status: doc.xpath('//status').text}
      end

      def charge(agreement_number:, amount:, currency:, order_id:,
                 subject:, description:, notify_url:, show_url:, scene: 'INDUSTRY|TRAVEL')
        doc = sdk_execute(service: 'alipay.acquire.createandpay',
                          product_code: 'FOREX_GENERAL_WITHHOLDING',
                          out_trade_no: order_id,
                          notify_url: notify_url,
                          show_url: show_url,
                          subject: subject,
                          body: description,
                          currency: currency,
                          scene: scene,
                          total_fee: amount,
                          agreement_info: "{ \"agreement_no\": \"#{agreement_number}\" }")
        {success: doc.xpath('/alipay/is_success').text == 'T',
         error: doc.xpath('//error').text,
         transaction_no: doc.xpath('/response/alipay/trade_no').text,
         result_code: doc.xpath('/response/alipay/result_code').text }
      end

      def refund(order_id:, amount:, currency:, reason: nil)
        sdk_execute(out_trade_no: order_id,
                    refund_amount: amount,
                    refund_reason: reason,
                    trans_currency: currency,
                    service: 'alipay.acquire.refund')
      end

      def query_transaction_status(order_id:)
        sdk_execute(out_trade_no: order_id, service: 'alipay.acquire.query')
      end


    end
  end
end