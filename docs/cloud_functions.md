# Cloud Functionsについて
## 開発環境
- node: v8.15.0
- firebase-tools: v6.10.0
- TypeScriptを使用する

[参考](https://cloud.google.com/functions/docs/concepts/nodejs-8-runtime)
[Cloud Functionsのスタートガイド](https://firebase.google.com/docs/functions/get-started?authuser=0)

### 環境構築手順
1. `nodebrew`でnodeをインストール(nodeのバージョン管理ツールはお好みで)
2. `npm install -g firebase-tools`を実行する

## Cloud Functionsのプロジェクトを作る
1. `firebase init functions`

## Deploy
1. `cd functions`
2. `firebase deploy --only functions`