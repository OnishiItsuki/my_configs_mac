# PRコードレビュー実行プロンプト

## 使い方
Claude Codeにこのファイルの内容をコピペして、PR番号を指定するだけでレビューが実行されます。

---

## プロンプト

現在チェックアウトしているブランチのコードレビューを実行してください。

以下の手順で実行：

1. PRのdiffを取得（`gh pr diff [PR番号] --name-only` と `gh pr diff [PR番号]`）
2. `~/.claude/settings/tasks/quality/coding`に定義されたコード品質基準の観点でレビュー
3. レビュー結果をJSON形式でまとめる
4. GitHub PRレビューAPIを使用して行単位でコメント

### レビュー基準

- `~/.claude/settings/tasks/coding/quality/anti-pattern.md` のアンチパターンを確認
- `~/.claude/settings/tasks/coding/quality/readable-code.md` の可読性・保守性観点を確認

### 重点チェック項目

1. **forEach内のasync処理** - 必ずfor...ofを使用
2. **トランザクションの有無** - DB更新時は必須
3. **N+1問題** - for文内のSELECT
4. **エラーハンドリング** - stacktraceを握りつぶさない
5. **型定義** - 入出力の型が定義されているか
6. **テスト** - 異常値（null/undefined/0）のテスト
7. **命名** - 明確で具体的な名前
8. **APIバージョニング** - 破壊的変更時

## コメントフォーマット

### 重大な問題
アンチパターン、可読性、保守性の低いコードについては下記のコメントを付けてください。
```markdown
⚠️下記内容の修正をお願いします！

**[ファイル:行番号] **
問題: [説明]
修正案: [コード]
違反項目: [当該項目のタイトル]
```

### 警告、要検討事項
アンチパターン、可読性、保守性やその他プログアム上問題が発生しうる箇所には下記のコメントを付けてください。
```markdown
️下記内容に問題がある可能性があるので確認をお願いします!

**[ファイル:行番号] **
問題: [説明]
修正案: [コード]
違反項目: [当該項目のタイトル]
```

## GitHub PRへの行単位コメント投稿

### 手順1: PR情報の取得
```bash
# PR番号からcommit IDとレポジトリ情報を取得
gh pr view [PR番号] --json headRefOid,headRepository -q '.headRefOid'
# または
gh pr view [PR番号] --json commits -q '.commits[-1].oid'
```

### 手順2: レビューコメントの投稿

#### 単一行へのコメント
```bash
# 行単位でレビューコメントを投稿（GitHub API使用）
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/{owner}/{repo}/pulls/[PR番号]/comments \
  -f commit_id="[commit_id]" \
  -f body="[コメント内容]" \
  -f path="[ファイルパス]" \
  -F line=[行番号] \
  -f side="RIGHT"
```

#### 複数行へのコメント
```bash
# 複数行にわたるコメントを投稿
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/{owner}/{repo}/pulls/[PR番号]/comments \
  -f commit_id="[commit_id]" \
  -f body="[コメント内容]" \
  -f path="[ファイルパス]" \
  -F start_line=[開始行番号] \
  -f start_side="RIGHT" \
  -F line=[終了行番号] \
  -f side="RIGHT"
```

### パラメータ説明
- `commit_id`: PR最新のコミットSHA（手順1で取得）
- `body`: コメントの内容
- `path`: ファイルの相対パス（例: `src/components/Modal.jsx`）
- `line`: 単一行の場合は対象行番号、複数行の場合は終了行番号
- `start_line`: 複数行コメントの開始行番号（複数行の場合のみ）
- `side`: `RIGHT`（新しいコード）または `LEFT`（古いコード）
- `start_side`: 複数行コメントの開始行のサイド（複数行の場合のみ）

### 実行例

#### 単一行へのコメント例
```bash
# 1. commit IDの取得
COMMIT_ID=$(gh pr view 123 --json headRefOid -q '.headRefOid')

# 2. レポジトリ情報の取得
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')

# 3. コメント投稿（例のため1コメントのみ）
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/${REPO}/pulls/123/comments \
  -f body="⚠️ **重大な問題**
**問題**: forEachの中でasync/awaitが使われています
**修正案**: for...ofループに変更してください
\`\`\`javascript
// 修正前 items.forEach(async (item) => { ... })
// 修正後  for (const item of items) { ... }
\`\`\`
**違反項目**: forEach内のasync処理のアンチパターン" \
  -f commit_id="${COMMIT_ID}" \
  -f path="src/components/Modal.jsx" \
  -F line=45 \
  -f side="RIGHT"
```

#### 複数行へのコメント例
```bash
# 50行目から55行目にコメント
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/${REPO}/pulls/123/comments \
  -f body="⚠️ **重大な問題**
**問題**: この関数全体でエラーハンドリングが不足しています
**修正案**: try-catchブロックで適切にエラーを処理してください
**違反項目**: エラーハンドリング" \
  -f commit_id="${COMMIT_ID}" \
  -f path="src/utils/api.js" \
  -F start_line=50 \
  -f start_side="RIGHT" \
  -F line=55 \
  -f side="RIGHT"
```

