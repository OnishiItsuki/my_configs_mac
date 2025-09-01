# `.agents/` ディレクトリの利用ルール

プロジェクトルートに `.agents/` ディレクトリを作成し、以下の構造でファイルを配置する。

- `docs/` : ドキュメントを配置。
- `todo/` : 作業計画を書いた todo ファイルを配置。
  - `archived/` : 完了した todo ファイルを格納。
- `rules/` : プロジェクトルールを配置。
  - `index.md` : ルール一覧を記載するインデックスファイル。
  - `{something}.md` : 開発に必要な各種ルールを個別ファイルとして記載。
- `temp/` : 一時的なファイルを配置。
  - 動作検証用スクリプト・ログなど

## `project-rules-index.md` について

`project-rules-index.md` には、`rules/` ディレクトリに存在するルールファイルの一覧を記載し、ルールの本文は含めない。

例:

```markdown
.claude/rules/ には以下のようなルールがあります。必要に応じて参照してください。

- project-structure.md: プロジェクトの構造についてまとめたルールがあります。
- use-volta.md: volta を使用して nodejs のバージョンを管理するルールがあります。
- development-workflow.md: 開発時のワークフローについてまとめたルールがあります。
- external-using-services.md: 外部サービスを使用する際のルールがあります。
``` 