require 'test_helper'

class Alipay::CrossBorder::ClientTest < Minitest::Test

  def setup
    @client = Alipay::CrossBorder::Client.new(
      url: 'https://openapi.alipaydev.com/gateway.do',
      partner: PARTNER,
      notify_url: NOTIFY_URL,
      return_url: RETURN_URL,

      #app_private_key: TEST_RSA_PRIVATE_KEY,
      charset: INPUT_CHARSET,
      alipay_public_key: TEST_MD5_KEY,
      sign_type: 'MD5'
    )
  end

  def test_cross_border_page_payment_signature
    signature = '7c1e6547485190d8473cd73be5a268bc'

    params = {
      out_trade_no: '20160401000000',
      subject: 'test',
      total_fee: 0.01,
      body: 'test_body',
      currency: 'USD',
      #split_fund_info: params[:split_fund_info].gsub("\"", "'"),
    }

    assert_equal signature, @client.sign(params)
  end

  def test_cross_border_page_payment_form
    params = {
      body: 'test',
      currency: 'USD',
      out_trade_no: 'test20180709121544',
      split_fund_info: '[{"transIn":"2088621891276664","amount":"0.01","currency":"USD","desc":"Split _test1"}]',
      subject: 'test123',
      'total_fee': '0.1',
    }
    assert_equal EXPECTED_FORM.gsub("\n", ''), @client.page_execute_form(params)
  end

  EXPECTED_FORM = <<EOF
<form id='alipaysubmit' name='alipaysubmit' action='https://openapi.alipaydev.com/gateway.do' method='POST'>
<input type='hidden' name='_input_charset' value='utf-8'/>
<input type='hidden' name='body' value='test'/>
<input type='hidden' name='currency' value='USD'/>
<input type='hidden' name='notify_url' value='#{NOTIFY_URL}'/>
<input type='hidden' name='out_trade_no' value='test20180709121544'/>
<input type='hidden' name='partner' value='#{PARTNER}'/>
<input type='hidden' name='product_code' value='NEW_OVERSEAS_SELLER'/>
<input type='hidden' name='return_url' value='#{RETURN_URL}'/>
<input type='hidden' name='service' value='create_forex_trade'/>
<input type='hidden' name='split_fund_info' value='[{"transIn":"2088621891276664","amount":"0.01","currency":"USD","desc":"Split _test1"}]'/>
<input type='hidden' name='subject' value='test123'/>
<input type='hidden' name='total_fee' value='0.1'/>
<input type='hidden' name='sign' value='3d826bacd9f06a52be7d1555d248bb3a'/>
<input type='hidden' name='sign_type' value='MD5'/>
<input type='submit' value='OK' style='dislay:none'>
</form>
<script>document.forms['alipaysubmit'].submit();</script>
EOF
end
