# 認証について
FirebaseのAuthenticationを使用する。

## platformの設定
### iOS
`Runner/Runner`に`GoogleService-Info.plist`を配置する。

### Android
- AndroidのGradleに関するまとめは[こちら(Qiita)](https://qiita.com/chikurin/items/0a37c77679422023198d)を参考にした
- GoogleServiceを使うための設定は[こちら(firebase_auth)](https://github.com/flutter/plugins/tree/master/packages/firebase_auth)
- Build TypeによってApplicationIdを変更する方法は[こちら](http://bison.hatenablog.com/entry/2017/12/17/110528)
  - 後ろに`.dev`をつける
- ビルドが通らなかったので、`gradle.properties`に以下の記述を追加した。[参考](https://github.com/flutter/flutter/issues/27156)
```
android.useAndroidX=true
android.enableJetifier=true
```

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