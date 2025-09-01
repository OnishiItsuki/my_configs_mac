# コードスタイル

- ES Modules (`import` / `export`) を使用し、CommonJS (`require`) は避ける。
- 可能な限り import は分割代入を使用する。（例: `import { foo } from 'bar'`）
- TypeScript の型チェックを必ず実行する。
- コミットメッセージは英語で記載する。
- 未使用変数は必ず削除する。
- `--no-verify` フラグの使用は禁止。 