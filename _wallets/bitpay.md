---
# This file is licensed under the MIT License (MIT) available on
# http://opensource.org/licenses/MIT.

id: bitpay
title: "BitPay Wallet"
titleshort: "BitPay"
compat: "mobile desktop android ios windows mac linux"
level: 3
platform:
  - mobile:
    name: mobile
    default: &DEFAULT
      text: "walletbitpay"
      link: "https://bitpay.com/wallet"
      source: "https://github.com/bitpay/copay"
      screenshot: "bitpay.png"
      check:
        control: "checkgoodcontrolfull"
        validation: "checkfailvalidationcentralized"
        transparency: "checkpasstransparencyopensource"
        environment: "checkpassenvironmentmobile"
        privacy: "checkpassprivacybasic"
        fees: "checkpassfeecontroloverride"
      privacycheck:
        privacyaddressreuse: "checkpassprivacyaddressrotation"
        privacydisclosure: "checkfailprivacydisclosurecentralized"
        privacynetwork: "checkfailprivacynetworknosupporttor"
    os:
      - name: android
        <<: *DEFAULT
      - name: ios
        <<: *DEFAULT
      - name: windowsphone
        <<: *DEFAULT
  - desktop:
    name: desktop
    default: &DEFAULT
      text: "walletbitpay"
      link: "https://bitpay.com/wallet"
      source: "https://github.com/bitpay/copay"
      screenshot: "bitpay.png"
      check:
        control: "checkgoodcontrolfull"
        validation: "checkfailvalidationcentralized"
        transparency: "checkpasstransparencyopensource"
        environment: "checkfailenvironmentdesktop"
        privacy: "checkpassprivacybasic"
        fees: "checkpassfeecontroloverride"
      privacycheck:
        privacyaddressreuse: "checkpassprivacyaddressrotation"
        privacydisclosure: "checkfailprivacydisclosurecentralized"
        privacynetwork: "checkfailprivacynetworknosupporttor"
    os:
      - name: windows
        <<: *DEFAULT
      - name: mac
        <<: *DEFAULT
      - name: linux
        <<: *DEFAULT
---
