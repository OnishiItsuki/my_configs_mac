# 環境情報

- シェル: fish shell
- 組織: air-closet (GitHub) ─ private リポジトリへは認証済み `gh` コマンドでアクセス可能。
- git submodule を頻繁に使用するため、必要なモジュールが見つからない場合はまず submodule を確認する。
- Node.js を実行するタスクの場合、コンテキスト開始時に `.node-version` を確認し、`node --version` を実行して差異がないことを確認する。差異が解消できない場合は `volta` で明示的に Node.js のバージョンを指定して実行する。 