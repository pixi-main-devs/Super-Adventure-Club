openssl genrsa -des3 -out test.key 4096
openssl req -new -x509 -key test.key -out test.pem -days 1095

