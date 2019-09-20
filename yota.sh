#!/bin/sh

BASE_DIR=$(dirname "$(realpath "$0")")

. "$BASE_DIR/settings.sh"

case $1 in
  64)
    OFFER_CODE='POS-MA6-0001';;
  416)
    OFFER_CODE='POS-MA6-0003';;
  512)
    OFFER_CODE='POS-MA6-0004';;
  640)
    OFFER_CODE='POS-MA6-0005';;
  768)
    OFFER_CODE='POS-MA6-0006';;
  896)
    OFFER_CODE='POS-MA6-0007';;
  1.0)
    OFFER_CODE='POS-MA6-0008';;
  1.3)
    OFFER_CODE='POS-MA6-0009';;
  1.7)
    OFFER_CODE='POS-MA6-0010';;
  2.1)
    OFFER_CODE='POS-MA6-0011';;
  3.1)
    OFFER_CODE='POS-MA6-0012';;
  4.1)
    OFFER_CODE='POS-MA6-0013';;
  5.0)
    OFFER_CODE='POS-MA6-0014';;
  5.7)
    OFFER_CODE='POS-MA6-0015';;
  6.4)
    OFFER_CODE='POS-MA6-0016';;
  7.1)
    OFFER_CODE='POS-MA6-0017';;
  7.8)
    OFFER_CODE='POS-MA6-0018';;
  8.5)
    OFFER_CODE='POS-MA6-0019';;
  9.2)
    OFFER_CODE='POS-MA6-0020';;
  10.0)
    OFFER_CODE='POS-MA6-0021';;
  12.0)
    OFFER_CODE='POS-MA6-0022';;
  15.0)
    OFFER_CODE='POS-MA6-0023';;
  max)
    OFFER_CODE='POS-MA6-0024';;
  *)
    echo 'Available speed steps: 64 416 512 640 768 896 1.0 1.3 1.7 2.1 3.1 4.1 5.0 5.7 6.4 7.1 7.8 8.5 9.2 10.0 12.0 15.0 max'
    exit 0;;
esac

YOTA_SIGNIN=$(curl -k -L -s -A "$USER_AGENT" -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
                  -d "IDToken1=$YOTA_USERNAME" -d "IDToken2=$YOTA_PASSWORD" -d 'org=customer' \
                  -d 'goto=https://my.yota.ru:443/selfcare/loginSuccess' -d 'gotoOnFail=https://my.yota.ru:443/selfcare/loginError' \
                  https://login.yota.ru/UI/Login)

if echo "$YOTA_SIGNIN" | grep -q '/changeOffer'; then
  PRODUCT_ID=$(echo "$YOTA_SIGNIN" | grep 'name="product" value' | sed -E 's/.+value="(.*)".+/\1/')
  sleep 5
  YOTA_CHANGE=$(curl -k -L -s -A "$USER_AGENT" -b "$COOKIE_JAR" -c "$COOKIE_JAR" \
                     -d "product=$PRODUCT_ID" -d "offerCode=$OFFER_CODE" \
                     -d 'autoprolong=0' -d 'currentDevice=1' -d 'status=custom' \
                     https://my.yota.ru/selfcare/devices/changeOffer)
    if echo "$YOTA_CHANGE" | grep -q '/changeOffer'; then
      AMOUNT=$(echo "$YOTA_CHANGE" | grep 'currentProduct' | sed -E 's/.+"currentProduct":\{(.*)\}.+/\1/' | sed -E 's/.+"amountNumber":"([0-9]*)".+/\1/')
      PERIOD=$(echo "$YOTA_CHANGE" | grep 'name="period" value' | sed -E 's/.+value="(.*)".+/\1/' | sed -e 's/дней/days/')
      YOTA_OUTPUT="Switched to $AMOUNT ($PERIOD left)"
    else
      YOTA_OUTPUT='ChangeOffer error: Unknown error (step 2)'
    fi
elif echo "$YOTA_SIGNIN" | grep -q 'Неверное имя пользователя или пароль'; then
  YOTA_OUTPUT='Auth error: Invalid user credentials'
elif echo "$YOTA_SIGNIN" | grep -q 'недоступен'; then
  YOTA_OUTPUT='Auth error: Temporarily unavailable'
else
  YOTA_OUTPUT='Auth error: Unknown error (step 1)'
fi

echo "$YOTA_OUTPUT"
logger -t YOTA "$YOTA_OUTPUT"

if [ "$DUMP_DEBUG" = true ]; then
  echo "$YOTA_SIGNIN" > "$BASE_DIR/debug_step1.html"
  echo "$YOTA_CHANGE" > "$BASE_DIR/debug_step2.html"
fi
