あなたはプロンプトエンジニアリングのエキスパートです。
下記の内容からタスクに合わせた適切なプロンプトを生成してください。

# 目的
リストされたエンドポイントに対してその処理の概要とどのようなDBアクセスが有るかを調査する

# 調査タスクの概要
search_endpoin_result.txtに書かれたエンドポイン全てに対して、以下の内容を調べてください。
- 処理の概要
- admin_delivery_ordersのCRUDの有無
- admin_delivery_ordersのCRUD処理がある場合
  - 使用カラム
  - CRUDのどの処理か
  - 処理の概要
- users.rental_statusの使用の有無
- admin_delivery_ordersを使用している場合は使用カラムとその概要

# タスクに関する制約
タスク実行時に以下の制約条件を守らせてください。
- まとめて実行するとサポってCRUDを書かなくなるので1タスクで1個のエンドポイントを調査するようにタスクを分割すること
- メモリリークを防ぐために5エンドポイントあたり1バッチとして、5タスク並列で動くようにバッチファイルタスク開始時に作成すること。バッチ処理は必ず一つずつ実行すること。
- `./.claude/reports/search_endpoint_result.txt`にリストされたエンドポイントが漏れなく調査されること
- 直接的なテーブル操作だけでなく、サービスやドメインロジック経由での操作も含めてください
- 出力結果は./.claude/reports/endpoints/${method}-${path}.mdであること。ただし、パスの `/`と`.` はすべて `-` に置き換えてください。

# 調査品質に関する厳格なルール
以下のルールを必ず守らせてください。

## 曖昧な表現の完全禁止
- 「詳細な解析が必要」「[要確認]」「など」「他」「可能性がある」といった曖昧な表現は一切禁止
- すべての項目について具体的な情報を記載すること
- 情報が得られない場合は「なし」または「使用されていない」と明記すること

## 使用カラムの特定方法（Sequelize + TypeORM対応）
admin_delivery_ordersテーブルを使用している場合、以下の手順で具体的なカラム名をすべて特定すること：

### Sequelizeパターン
1. find/findOne/findAll/findByPk等のメソッド呼び出しを検索
2. attributesオプションで指定されているカラムを抽出
3. includeで結合されている場合も、そのattributesを確認
4. whereオプションで使用されているカラムも含める
5. update/create/destroy/upsertの場合は、引数で指定されているカラムを抽出

### TypeORMパターン
1. find/findOne/findAndCount等のメソッド呼び出しを検索
2. selectオプションで指定されているカラムを抽出
3. createQueryBuilder使用時はselect()で指定されているカラムを確認
4. relationsで結合されている場合も確認
5. whereオプションで使用されているカラムも含める
6. save/update/delete/insertの場合は、引数で指定されているカラムを抽出
7. .addSelect()で追加されているカラムも確認

### 共通パターン
1. 生SQLがある場合はSELECT句/INSERT句/UPDATE句のカラムを抽出
2. クエリビルダー（Sequelize.literal, QueryBuilder等）内のカラムも確認
3. トランザクション内の操作も含める

## users.rental_statusの使用箇所特定方法
users.rental_statusが使用されている場合、以下を具体的に記載すること：

1. どのファイルのどの関数で使用されているか（ファイルパス:行数形式）
2. どのような条件式で使用されているか（例: `rental_status === 'RENTING'`）
3. 何のために使用されているか（例: レンタル中ユーザーの絞り込み）
4. Sequelizeのwhereオプション、TypeORMのwhereオプション、includeのwhere、生SQL等すべてのパターンを検出

## 具体的な調査手順
各エンドポイントの調査では、以下の手順を必ず実施すること：

### ステップ1: ルートハンドラの特定
1. Grepツールで対象エンドポイントのルート定義を検索
2. ルートハンドラ関数を特定
3. Readツールでハンドラファイルを読み込む

### ステップ2: 呼び出し関数の追跡
1. ハンドラから呼び出される全関数をリストアップ
2. 各関数のファイルをReadツールで読み込む
3. さらにその関数から呼び出される関数も追跡（最低10階層まで）
4. Service層、Repository層、Entity層すべてを確認

### ステップ3: テーブルアクセスの検出
1. Grepツールで 'admin_delivery_orders' を検索（テーブル名）
2. Grepツールで 'AdminDeliveryOrder' を検索（モデル/エンティティ名）
3. 見つかったファイルをReadツールで読み込み、具体的な操作を特定
4. ORMメソッドの引数を確認：
   - Sequelize: find系, create, update, destroy, upsert, bulkCreate等
   - TypeORM: find系, save, update, delete, insert, createQueryBuilder等
5. options引数（attributes, select, where等）からカラム名を抽出
6. QueryBuilder使用時は.select(), .addSelect(), .where()等を確認

### ステップ4: rental_statusの検出
1. Grepツールで 'rental_status' を検索
2. 見つかったファイルをReadツールで読み込む
3. 使用箇所のコンテキストを確認（条件式、絞り込み等）
4. ファイルパスと行数を記録

### ステップ5: レポート作成
1. 収集した情報を整理
2. 曖昧な表現を一切使わず、具体的に記述
3. カラム名はすべて列挙（カンマ区切り）
4. 使用箇所はファイルパス:行数形式で記載
5. 情報が見つからない場合は「なし」または「使用されていない」と明記
- 以下の形式で出力されること
```md

# エンドポイント調査結果

## エンドポイント: [エンドポイントパスを記入]

### 基本情報
- **HTTPメソッド**: [GET/POST/PUT/PATCH/DELETE]
- **処理概要**: [エンドポイントの主な処理内容を簡潔に記述]

### admin_delivery_orders テーブル
- **使用有無**: [あり/なし]
- **CRUD種別**: [C/R/U/D/なし] ※複数ある場合はカンマ区切り (例: C,U)
- **使用カラム**: [カラム名をカンマ区切りで列挙] (例: id, status, delivery_status, delivered_date)
- **CRUD処理概要**: [各CRUD処理の具体的な内容を記述]

### users.rental_status カラム
- **使用有無**: [あり/なし]
- **使用箇所・目的**: [どのような目的で使用されているか]

### 備考
[その他特記事項があれば記載]

---

## CSV変換用データ (コピー&ペースト用)
```
[エンドポイントパス],[HTTPメソッド],[処理概要],[admin_delivery_orders使用],[CRUD種別],[使用カラム],[CRUD処理概要],[users.rental_status使用],[備考]
```
```

生成したプロンプトは.claude/commands/RESEARCH_ENDPOINT_DETAILS.mdに出力して。

