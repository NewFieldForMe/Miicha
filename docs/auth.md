# 認証について
FirebaseのAuthenticationを使用する。

## platformの設定
### iOS
`Runner/Runner`に`GoogleService-Info.plist`を配置する。

### Android
T.B.D.

## pubspecの編集
以下のライブラリを使用する。
- firebase_auth: ^0.8.1+4
- google_sign_in: ^4.0.1+1

## Googleアカウントでログインするサンプルコード
[こちら](https://github.com/flutter/plugins/tree/master/packages/firebase_auth)に記載されている。

## 参考
- [FlutterFire: GitHub](https://github.com/flutter/plugins/blob/master/FlutterFire.md)
- [firebase_auth: GitHub](https://github.com/flutter/plugins/tree/master/packages/firebase_auth)
- [google_sign_in:GitHub](https://github.com/flutter/plugins/tree/master/packages/google_sign_in)