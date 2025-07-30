# POS & Self-Registration Integrated System

## 概要
クラウド環境で稼働するPOSシステムとセルフレジシステムの統合システム

## 技術スタック
- **インフラ**: AWS (EC2, RDS, S3, CloudFront, Lambda, API Gateway)
- **バックエンド**: Java + Spring Boot
- **フロントエンド**: React + Next.js
- **モバイル**: Android (Android SDK)
- **データベース**: PostgreSQL (RDS)
- **プロジェクト管理**: Redmine + Git

## システム構成

### 1. バックエンド (Spring Boot)
- RESTful API
- マイクロサービスアーキテクチャ
- JWT認証
- 決済処理統合
- 在庫管理
- レポート生成

### 2. フロントエンド (React + Next.js)
- 管理者ダッシュボード
- レポート表示
- 設定管理
- レスポンシブデザイン

### 3. モバイルアプリ (Android)
- セルフレジ機能
- 商品スキャン
- 決済処理
- レシート表示

### 4. AWS インフラ
- EC2: アプリケーションサーバー
- RDS: データベース
- S3: ファイルストレージ
- CloudFront: CDN
- Lambda: サーバーレス処理
- API Gateway: API管理

## ディレクトリ構造
```
pos-selfreg-workingoncrowd/
├── backend/                 # Spring Boot バックエンド
├── frontend/               # React + Next.js フロントエンド
├── mobile/                 # Android アプリ
├── infrastructure/         # AWS インフラ設定
├── docs/                   # ドキュメント
└── scripts/               # デプロイスクリプト
```

## セットアップ手順

### 前提条件
- Java 17+
- Node.js 18+
- Android Studio
- AWS CLI
- Docker

### 1. バックエンドセットアップ
```bash
cd backend
./gradlew build
./gradlew bootRun
```

### 2. フロントエンドセットアップ
```bash
cd frontend
npm install
npm run dev
```

### 3. モバイルアプリセットアップ
```bash
cd mobile
# Android Studioでプロジェクトを開く
```

### 4. AWS インフラデプロイ
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

## 機能一覧

### POSシステム
- 商品管理
- 在庫管理
- 売上管理
- レポート生成
- 従業員管理
- 顧客管理

### セルフレジシステム
- 商品スキャン
- 自動価格計算
- 複数決済方法対応
- レシート印刷
- エラー処理

### 統合機能
- リアルタイム同期
- 統一管理画面
- データ分析
- セキュリティ管理

## 開発環境
- **開発サーバー**: localhost:8080 (バックエンド)
- **フロントエンド**: localhost:3000
- **データベース**: localhost:5432

## 本番環境
- **AWS Region**: ap-northeast-1 (東京)
- **ドメイン**: pos-selfreg.example.com
- **SSL**: AWS Certificate Manager

## セキュリティ
- JWT認証
- HTTPS通信
- データ暗号化
- アクセス制御
- 監査ログ

## 監視・ログ
- CloudWatch監視
- ELK Stack (Elasticsearch, Logstash, Kibana)
- アラート設定
- パフォーマンス監視

## ライセンス
MIT License "# pos-selfreg-workingoncrowd" 
