require 'minitest/autorun'
require 'alipay'
require 'webmock/minitest'

Alipay.pid = '1000000000000000'
Alipay.key = '10000000000000000000000000000000'

TEST_RSA_PUBLIC_KEY = <<EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCjNVhJf9PYDFN1PFd4SXEvxmjD
0dn+xQ4lQu6o8HbGXz4de/RRVTJDL48qwxn81lar5cNSIjbnhDRXm9fZcrzuwbjq
xXOv2Ov7MZAa/WJEcfvp3XcSgxKPB54FLVvHo/rxuMK2xpps47Lpc7vppkvi3ofb
XW61S+aT0TWFkUMTnwIDAQAB
-----END PUBLIC KEY-----
EOF

TEST_RSA_PRIVATE_KEY = <<EOF
-----BEGIN PRIVATE KEY-----
MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKM1WEl/09gMU3U8
V3hJcS/GaMPR2f7FDiVC7qjwdsZfPh179FFVMkMvjyrDGfzWVqvlw1IiNueENFeb
19lyvO7BuOrFc6/Y6/sxkBr9YkRx++nddxKDEo8HngUtW8ej+vG4wrbGmmzjsulz
u+mmS+Leh9tdbrVL5pPRNYWRQxOfAgMBAAECgYB7xOSjOJFK8m4IJi6fRfLULD8e
4XHUR1Qm5c9fxpwMbAYLDgmF9HodgV+tKi/3EgTAb4nkK5Y/lH6tQb47ZUvo/lKz
RlIVZ6Rm76V07g/+5exIZzTyvdD9T2fLeYQwKV/2JYUv0KSYWPvWykdaV4aNkCuw
mxTUjvhDxK/Ns31CIQJBANI1Y3gGBqbBIN9wxjx3ShBtt/U8YnipUJ92eTI7OU9p
ZsCIFPoeYG/X40miwDb5ouPnvJTtzuY4PkPokEefN9MCQQDGwurqa8RNK2APA62U
CdZbJuWimkdHEc53IKvD/l2tWVFqhVAy8bs+3LGzBNfuxUuAxOoQm9n0IVRaH5jn
l8GFAkEAijuTmsUTsKsGDAmkQvULHnyYYUuBUem92+9TycWKbX9Zk7ipWsWJE2N7
0tuU3VISXR7yM1mjGl/YCl4wKvk4AwJAE1DkBY4dkKZTeoIP/2AJXehkzq2Rmb2I
RBl/t9djgTI58FEuXxUQ7mYCOvSQi5rO4J/CY4TR5KDMksmZUYB1BQJAIEfVDxz4
5yoHL7L+6EoC5TWxUxFMN7z7FhObyKeaLKj3inEsbjfcPCA09zPUce0FSKBc/dVh
DEorJMaPK5vXiA==
-----END PRIVATE KEY-----
EOF

TEST_MD5_KEY = "6cgz2arb7djrp0ohrcz580a4sl1n0pfz"

PARTNER = "2088621891276675"

# 服务器异步通知页面路径，不能加?id=123这类自定义参数，必须外网可以正常访问
#Page for receiving asynchronous Notification. It should be accessable from outer net.No custom parameters like '?id=123' permitted.
NOTIFY_URL = "http://63a62ee5.ngrok.io/notify"

# 页面跳转同步通知页面路径 需http://格式的完整路径，不能加?id=123这类自定义参数，必须外网可以正常访问
#Page for synchronous notification.It should be accessable from outer net.No custom parameters like '?id=123' permitted.
RETURN_URL = "http://63a62ee5.ngrok.io"

# 签名方式
#sign_type
SIGN_TYPE = "MD5"

PAYMENT_SERVICE = "create_forex_trade"

INPUT_CHARSET = "utf-8"
