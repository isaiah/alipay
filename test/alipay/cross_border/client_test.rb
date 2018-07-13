require 'test_helper'

class Alipay::CrossBorder::ClientTest < Minitest::Test

  def setup
    @client = Alipay::CrossBorder::Client.new(
      env: 'sandbox',
      partner: PARTNER,
      notify_url: NOTIFY_URL,
      return_url: RETURN_URL,

      #app_private_key: TEST_RSA_PRIVATE_KEY,
      charset: INPUT_CHARSET,
      alipay_public_key: TEST_MD5_KEY,
      sign_type: 'MD5'
    )

    @params = {
      notify_id: '1234',
    }
    @unsign_params = @params.merge(sign_type: 'MD5', sign: 'xxxx')
    @sign_params = @params.merge(
      sign_type: 'MD5',
      sign: '9e706619fdf93af82ea96c6c8fd6a4f1'
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
      out_trade_no: 'test20180709155547',
      split_fund_info: "[{'transIn':'2088621891276664','amount':'0.10','currency':'USD','desc':'Split _test1'}]",
      subject: 'test123',
      total_fee: '1.00',
    }
    assert_equal EXPECTED_FORM_J.gsub("\n", ''), @client.page_execute_form(params)
  end

  def test_verify_notify_when_true
    stub_request(
      :get, "https://openapi.alipaydev.com/gateway.do?service=notify_verify&partner=#{PARTNER}&notify_id=1234"
    ).to_return(body: "true")
    assert @client.valid?(@sign_params)
  end

  def test_refund
    body =<<EOF
<?xml version="1.0" encoding="GBK"?>
<alipay>
    <is_success>T</is_success>    
</alipay>
EOF
    url = %r{.*?gateway.do\?_input_charset=utf-8&currency=USD&gmt_return=\d+&notify_url=http://63a62ee5.ngrok.io/notify&out_return_no=abc&out_trade_no=123&partner=2088621891276675&product_code=NEW_OVERSEAS_SELLER&return_amount=100.00&return_url=http://63a62ee5.ngrok.io&service=forex_refund&sign=\w+?&sign_type=MD5}
    stub_request(:get, url).to_return(body: body)

    resp = @client.refund(refund_no: 'abc', order_id: '123', amount: '100.00', currency: 'USD', reason: 'rejected')
    assert resp[:success]
  end

  def test_query_transaction_status
    stub_request(:get, /.*?gateway\.do/).to_return(body: FINISHED_TX)
    resp = @client.query_transaction_status('123')
    assert resp[:success]
    assert_equal 'TRADE_FINISHED', resp[:status]
    assert_equal '2017061521001003550204235677', resp[:transaction_no]
  end

EXPECTED_FORM_J =<<EOF
<form id='alipaysubmit' name='alipaysubmit' action='https://openapi.alipaydev.com/gateway.do' method='GET'><input type='hidden' name=\"_input_charset\" value=\"utf-8\"/><input type='hidden' name=\"body\" value=\"test\"/><input type='hidden' name=\"currency\" value=\"USD\"/><input type='hidden' name=\"notify_url\" value=\"http://63a62ee5.ngrok.io/notify\"/><input type='hidden' name=\"out_trade_no\" value=\"test20180709155547\"/><input type='hidden' name=\"partner\" value=\"2088621891276675\"/><input type='hidden' name=\"product_code\" value=\"NEW_OVERSEAS_SELLER\"/><input type='hidden' name=\"return_url\" value=\"http://63a62ee5.ngrok.io\"/><input type='hidden' name=\"service\" value=\"create_forex_trade\"/><input type='hidden' name=\"sign\" value=\"0f76b157662f430defb9b71fd0349a18\"/><input type='hidden' name=\"sign_type\" value=\"MD5\"/><input type='hidden' name=\"split_fund_info\" value=\"[{'transIn':'2088621891276664','amount':'0.10','currency':'USD','desc':'Split _test1'}]\"/><input type='hidden' name=\"subject\" value=\"test123\"/><input type='hidden' name=\"total_fee\" value=\"1.00\"/><input type='submit' value='ok' style='display:none'></form><script>document.forms['alipaysubmit'].submit();</script>
EOF

FINISHED_TX =<<EOF
<alipay>
<is_success>T</is_success>
<request>
<param name="_input_charset">UTF-8</param>
<param name="service">single_trade_query</param>
<param name="partner">2088721091300630</param>
<param name="out_trade_no">2009011803596246</param>
<param name="sendFormat">normal</param>
</request>
<response>
<trade>
<body>hello</body>
<buyer_email>intltest059@service.alipay.com</buyer_email>
<buyer_id>2088122921745555</buyer_id>
<discount>0.00</discount>
<flag_trade_locked>0</flag_trade_locked>
<gmt_create>2017-06-15 16:25:31</gmt_create>
<gmt_last_modified_time>2017-06-15 16:25:58</gmt_last_modified_time>
<gmt_payment>2017-06-15 16:25:58</gmt_payment>
<is_total_fee_adjust>F</is_total_fee_adjust>
<operator_role>B</operator_role>
<out_trade_no>2009011803596246</out_trade_no>
<payment_type>100</payment_type>
<price>0.02</price>
<quantity>1</quantity>
<seller_email>test@126.com</seller_email>
<seller_id>2088721091300630</seller_id>
<subject>world</subject>
<to_buyer_fee>0.00</to_buyer_fee>
<to_seller_fee>0.02</to_seller_fee>
<total_fee>0.02</total_fee>
<trade_no>2017061521001003550204235677</trade_no>
<trade_status>TRADE_FINISHED</trade_status>
<use_coupon>F</use_coupon>
</trade>
</response>
<sign>6283ce0cf5aaa812d9c1d29719d53e8d</sign>
<sign_type>MD5</sign_type>
</alipay>
EOF
end
