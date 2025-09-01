コードレベルのアンチパターン集です。
絶対にこれらのルールのいずれにも違反がないようにしてください。



	タイトル (NGなこと)	キーワード	アンチパターンの理由	アンチパターンとなるコード例	こうした方がいいコード
	英語版はこちら				
1	forEach内でasync処理をしている	JavaScript,TypeScript	処理が直列で実行されないことがあり、順番がおかしくなるため	"itemIds.foreach (async (itemId) => {
  await this.getOrder(itemId);
}"	"for (const itemId of itemIds) {
  await this.getOrder(itemId);
}"
2	ハードコードを使ったプログラミングを行う（Magic number）	MagicNumber	"定数で定義しなくて生の値使うとコード読みコストかかるし、可読性下がる。また業務理解時間もかかる。
さらに運用で変更があった場合地獄。"	"switch (type) {
  case 1:
  case 2:
}"	"switch (type) {
  case REGULAR:
  case LITE:
}"
3	for文の中でselectする	n+1,SQL,DB	SELECT文はSQLの中でも最もコストがかかる。for文で必要なデータがあるなら、できる限りfor文の外で先にSELECTできないか検討すること。	"for (let i = 0, length = userList.length; i < length; i++) {
  db.users.find({
    where: {
      id: userList[i].id,
    }
  })
}"	"db.users.findAll({
  where: {
    id: { $in: userList.map(user => user.id) }
  }
});"
4	transactionがないコードを書く	SQL,DB	"単一テーブルの更新でもかならずtransactionをはるべき。機能拡張を踏まえてコードを書く意識を必ず持つこと。

〜Third Partyのapiを叩く場合〜
1. Transaction貼る
2. データベースの更新を行う
3. Third PartyのAPIを叩く
失敗したらRollbackする。
Third PartyのAPIを先に叩くとRollbackできないので注意。"	"db.users.update(data, {
  where: {
    id: this.user.id
  }
});"	"await db.sequelize.transaction(async (transaction: Transaction) => {
  return db.users.update(data, {
    where: {
      id: this.user.id
    },
    transaction
  });
});"
5	SQLのパフォーマンスチェックをしない	SQL,DB	リリース前に追加したsqlをチェックしないと、indexが効くか効かないか知らないので、パフォーマンスが担保できない		"// sequelizeやtypeormが出力したロークエリをEXPLAINで確認する。
// 必要に応じてINDEXを貼ったり、クエリを分割したりといった対応をする。
EXPLAIN SELECT ..."
6	意味が曖昧な変数名をつける、もしくはgeneralすぎる変数名をつける	命名規則	"変数名を見てもなんのための変数かがわからない。
→勘違いや無駄な調査時間を生んでしまう"	const list = [];	const users = [];
7	InnerJoinでいい場面でLeftJoinをする	パフォーマンス, SQL, DB	LeftJoinはパフォーマンス悪くなるから	"admin_payment_histories: {
  users: {
    requred: false
  }
}

// もしくは

admin_payment_histories: {
  users: {
    // requredの指定なし
  }
}"	"admin_payment_histories: {
  users: {
    requred: true
  }
}"
8	RequestURLの文字列結合で"+"を使う		"+"だと/のありなしを気にしないといけないため。	const staticPath = rootPath + '/.tmp';	const staticPath = path.join(rootPath, '.tmp');
9	"Objectの引数を編集する
(ミュータブルなデータで渡ってきた引数を変更する)"		Objectは参照渡しのため、引数のObjectを編集すると呼び出し元にも副作用が発生してしまうため。	"function test(obj) {
obj.a = obj.a-1;
} "	"function test(obj) {
  const {
    a
  } = obj;
} "
10	attribute指定せずにselectしてしまう	DB	attribute指定しないと、テーブルの全カラムとってくるので、パフォーマンスによくない	 db.users.find({attributes: []})	 db.users.find({attributes: [id, name]})
11	関数の役割が理解できない関数名をつける	命名規則	関数名が関数の役割と違う場合はメンテナンスしにくい		
12	spec書く時に it()の中にデータ業務処理を書く	単体テスト	もしspec落ちたらデータ取得処理が落ちた原因が、期待返却値がおかしいのかどうかわからないので、itやtestの中ではそれ以外の処理は書かない。	"describe() {
  let actualResult;
  beforeAll() {
    await usecase.execute();
  }

  it('Result should be ...', async () => {
    actualResult = await repository.getData();
    assert.equal(actualResult, expected);
   });
}"	"describe() {
  let actualResult;
  beforeAll() {
    await usecase.execute();

    actualResult = await repository.getData();
  }

  it('Result should be ...', () => {
    assert.equal(actualResult, expected);
  });
}"
13	関数の引数をひとつずつもらう（Objectになっていない）		個別で引数を指定している場合、あとからその関数を拡張するときにもどんどん引数が増えてしまい、OptionalとRequiredの指定もしづらくなってしまうため。	function(userId, membershipStatus, planId, firstName, lastName, optionId, limit, offset) {}	function({userId, membershipStatus, planId, firstName, lastName, optionId}, {limit, offset}) {}
14	constで変数定義できる場面で、var, letを使う		値が変わってしまうことによる副作用を防ぐため。とくにjsは型が存在しないため非常に重要。	"var userId = 1;
let userId = 1;"	const userId = 1;
15	DB更新するとき、フロントから渡されたObjectのパラメータでそのまま更新する	バリデーション	"予期しない値で更新させしまうリスクがある。
→ かならずそれをつかってfactoryでmodel生成するなり、ホワイトリストでプロパティチェックを行う。"	"function(req, res) {
  db.users.update(req.body, {where: req.user.id})
}"	"function(req, res) {
  const updateData = userFactory.create(req.body);
  db.users.update(updateData, {where: req.user.id})
}"
16	メンバ変数のないクラスを作る	クラス	"わざわざクラスにする意図があいまいになり、余計な読取コストがかかる。パフォーマンス悪化にもつながる。
objectや関数で実現したほうがシンプルだから。
状態を管理したいのかどうかわかっていない人がとりあえずクラスにしておこうとなりがち。"	"class Person {
   call(name) {
       return ""Hi"" + name
   }
}"	"// 例1: 関数にする
export const call = (name) => ""Hi"" + name

// 例2: メンバ変数を使う
class Person {
  constructor() {
    this.name = 'no name';
  }
  set(name) {
    this.name = name;
  }
  call() {
    return ""Hi"" + this.name;
  }
}"
17	specファイルのdescribeに関数名を入れる	単体テスト	"関数で実現したい仕様・意図を書いてほしいから。
また関数名が変更されたときここも修正しないといけないから。
なんの処理をテストしたいのかを記載する。"	describe('updateUserRentalStatus', () => {	describe('ユーザーのレンタルステータスを更新する', () => {
18	テストコードの中で、事後処理としてデータ削除処理を書かない	単体テスト	"後処理でデータ削除していないと、その後のテストが適切に動かない。
→結果、「テストの前処理でデータ削除処理を追加してしまう」のような要らない処理が発生してしまう。
自分のテストのために相手のテストを考慮したり、依存関係ができることは本来不要。"	"before() {
  testDataGenerator.reset();
  testDataGenerator.create(testData);
}
after() {
  // nothing to do
}"	"before() {
  testDataGenerator.create(testData);
}
after() {
  testDataGenerator.reset();
}"
19	specのitの中で大量のチェックを行う	単体テスト	"基本はitの中には1つのassertにする。テスト失敗の原因を明確にするため。
assertが複数あるとどのassertで失敗したのか不明になる。
また、このアンチパターンはObjectをassertすることを禁止したものではない。"	"it (""test"" => {
  assert(1);
  assert(2);
  assert(3);
})"	"it (""test1"" => {
  assert(1);
})
it (""test2"" => {
  assert(2);
})
it (""test3"" => {
  assert(3);
})"
20	DB存在チェックでfindOneやfindAllを使用する	DB	countを使う。findOneやfindAllはcountよりコストがかかる上、コードを読んだときの可読性がよくない。	const isUser = !!db.users.findOne({ where: {id: userId} });	const isUser = !!db.users.count({ where: {id: userId} });
21	DefaultValueが設定できるものにNull許可する	DB, モデル定義	"allowNull: falseにする
もしNull許可をする場合、アプリケーション側でNULLチェックを必ず行うこと"	"contract_month: {
   type: Sequelize.TINYINT,
   allowNull: true
},"	"contract_month: {
  type: Sequelize.TINYINT,
  defaultValue: 1,
  allowNull: false,
},"
22	constants等に登録するINTEGERに0を使う		"0だと真偽値にしたときにfalseになる可能性があるので危険。
constants等に登録するINTEGERは1から始める"	"const paymentStatus = [
  0: ""RESOLVE"",
  1: ""SUCCESS"",
];"	"const paymentStatus = [
  1: ""RESOLVE"",
  2: ""SUCCESS"",
];"
23	フロントエンドだけにバリデーションを書く	設計, Backend	"フロントエンドのバリデーションはあくまでUX向上（通信せずにエラー判定ができる）のため。
基本的に悪意のあるユーザはAPIを直接実行してくると想定すべきで、バックエンドにバリデーションがない場合はありえない。"		
24	サーバ側で発生したエラーをそのままフロントに返却する	エラーハンドリング	"バックエンド側で発生しているエラー情報をそのまま返しても、フロントではなにも解決できないし、場合によってはセキュリティリスクにもつながる。
フロントに返すエラーは必ず一度catchして、フロント用に加工したエラーオブジェクトを返却する。"	"try {
  db.users.update(data, where);
} catch(err) {
  req.send(err);
}"	"try {
  db.users.update(data, where);
} catch(err) {
  const errorResponse = errorFactory.create(err);
  res.send(errorResponse);
}"
25	現在時刻の取得ロジックを書く時、グローバルで取得する	日付・時刻	"最新の時間を取得できなくなる。
→必ずfunctionの中に入れて関数が実行されるたびに最新の時間を取得できるようにする。"	"const today = NOW();

function test() {
  console.log(today);
}"	"function test() {
  const today = NOW();
  console.log(today);
}"
26	"try catchでcatchした際に、ログ出すとか、カスタムエラーにするとか、もしくはエラーを握りつぶすとか明確な意図がみえない。（そのままerrorをthrowするなら不要。）
↓
catch処理に明確な意図がない"	エラーハンドリング	エラーが握りつぶされて終わっている処理は無くす	"// なんのためのcatchかわからない
try {
  hogehoge;
} catch((err) => {
  throw(err);
};

// ログくらいだしたい
try {
  hogehoge;
} catch((err) => {
};"	"const CustomBadRequestError = class CustomBadRequestError extends Error {
  constructor(message) {
    super(message);
    this.name = 'CustomBadRequestError';
    this.status = 400;
  }
};

try {
  hogehoge;
} catch((err) => {
  if (err instanceof CustomBadRequestError) {
    logger.api.warn(err.message);
    throw(err);
  } else {
    logger.api.error(err);
    throw(err);
  }
};"
27	配列のデータが入る変数が英単語として単数形にする	命名規則	直感的にコードの意味を理解できなくなる。	const user = db.user.findAll({})	const users = db.user.findAll({})
28	REST apiのendpointを定義するとき、resourceに紐づけない	ルーティング	resourceに紐付かないとrest apiじゃないから	post: /v1.14/ticket-exchange-coupon/	post: /v1.14/coupon/exchange-by-ticket/
29	数千、数万を超えるような処理をPromise.allする。	Promise	Promise.allの並列実行はパフォーマンスが良いが、度を超える数の並列実行になるとメモリが足りなくなるのでほどほどにチャンクする。	"const users = db.users.findAll();
Promise.all(users.map(user => updateUserInfo(user)));"	"const users = db.users.findAll();
const chunkedUsers = chunk(users);
for (const userList of chunkedUsers) {
  await Promise.all(userList.map(user => updateUserInfo(user)));
}"
30	テスト結果を取得する時にwhere句を使用しない	単体テスト	find allで取得してテストするとあとから追加するひとが大変。userId等で指定して取得 -> テストする		
31	異常値のテストを書かない	単体テスト	"具体的に、以下のような異常系テストパターンが漏れがち
- nullにはならない
- undefinedにはならない
- 0にはならない
- マイナスにはならない"	"describe('ユーザーのレンタルステータスを変更する', () => {
  describe('正常系', () => {
    //...
  })
  describe('異常系', () => {
    // ... 異常値のテストがない
  })
});"	"例）DefaultValueがデータとして入る場合、NULLではなくDefaultValueを返すことを確認する

describe('ユーザーのレンタルステータスを変更する', () => {
  describe('正常系', () => {
    //...
  })
  describe('異常系', () => {
    describe('コンストラクタで異常値が渡された場合', () => {
      describe('0が渡された場合', () => {
        it('0が渡された場合、エラーになる', () => {
          // ...
        });
      })
      // nullの場合
      // undefinedの場合
    })
  })
});"
32	it()の内容を雑に記述する	単体テスト	何を期待するか、チェックするか全然書いてない	"it('verify result', () => {

---

it('verify users', () => {"	it('The user's rental status is "RENTING" as expected.', () => {
33	残したいログにconsole.logを使う	ログ	"console.errorすると、react-nativeならLogBox(RedBox)が出てくれる。warnはYellow。
https://qiita.com/kashira2339/items/874f95aaaa59f4a17d3d"	console.log('hoge');	"console.error('hoge');
// もしくは
console.warn('hoge')"
34	"domain層の関数がinfra層に依存するコードを書く
（DDDでinfra層のコードを読まないとdomain層のinterface関数の役割が理解できない状態になっている）"	DDD	"domain層のロジックがinfra層に依存するのはDDDじゃない
→ domain層単体を見ても意図が分からない状態になっているとアウト"	"domain層：
saveUserDetails({userDetail})

 → domain層でuser_detailsが存在するか知らないからNG"	"domain層：
saveUsers({userDetail})"
35	stacktraceを握りつぶす	エラーハンドリング	stacktraceがないと発生した事象がわからなくなる。かりにエラーにしないとしてもログには出力する。	"try {
  hogehoge;
} catch (err) {
  logger.error(`エラーが発生しました。${hogeId}`);
}"	"try {
  hogehoge;
} catch (err) {
  logger.error(error.stack || error);
  logger.error('エラーが発生しました');
}"
36	フロントエンドの時間に依存した処理を作る	日付・時刻	フロントエンドの時間はエンドユーザが自由に変更できてしまうため。サーバから時間を返却し、その時間を用いるべき。		
37	カラー指定にrgb()を使う	CSS	フロントエンドはとにかく記述量が少ないことが正義。α値（opacity）を使いたい場合はrgbaを使うが、必要ない場合は16進数を利用する。	".className {
  color: rgb(255, 255, 255);
}"	".className {
  color: #ffffff;
}"
38	toggleメソッドを作成する		"toggleメソッドはメソッド自体が状態管理しているのと同義。メソッドはあくまでプレーンに保ち、状態管理はstoreやmodelで行う。
また、関数はパラメータが同じであれば必ず同じ結果を返すことが期待される。"	"const toggle = () => {
  if (getCurrentFlag()) {
    setTrue();
  } else {
    setFalse();
  }
};
toggle();"	"const on = () => {
  setTrue();
};
const off = () => {
  setTrue();
};
if (getCurrentFlag()) {
  on();
} else {
  off();
}"
39	未来日付を条件にテストするとき、日付を変えてテストするのではなく、そもそもの条件を変えてテストする	日付・時刻	"コードを変えると意図しない修正も含まれてしまう危険性が絶対につきまとう。
テストはプログラムを修正せずに行う方法を必ず模索する。"		server日付を変更する
40	CSSでブロック要素のwidth: 100%;設定する。	CSS	"block要素ではwidth: 100%がデフォルト。そのため必要がなければwidth: 100%;は指定しない。
absoluteとかfixedにした場合は100%ではなくなるので、その場合は適宜指定する。"	".inputBuildingsContainer {
  width: 100%;
}

.AddressFormContainer {
  width: 100%;
}"	
41	~とか〜を使う。	特殊文字	"~とか〜は文字コードによって文字が崩れたり、変な見え方になったりするので使わないのが望ましい。
https://qiita.com/kasei-san/items/3ce2249f0a1c1af1cbd2"	https://github.com/air-closet/air-closet-ssr/pull/2341/files/1bb49472248f65530310d3e6e16ee7b83e2e4b69#r1002622519	
42	if文でブロックスコープを書かない。		"if文でブロックスコープを書かないと、ぱっと見どこまでがif文の範囲かわからなくなってしまう。
短ければ1行で書くのはOK。"	"if (false)
  console.log('
    !!!!!!!!!!
    これは出力されない
    !!!!!!!!!!
   ');"	"if (false) {
  console.log('
    !!!!!!!!!!
    これは出力される
    !!!!!!!!!!
   ');
}"
43	catchしたエラーをJSON.stringifyする。	エラーハンドリング	"errorオブジェクトの.messageや.stackはenumerableプロパティがfalseで、JSON.stringifyでは列挙されない。
つまり空のオブジェクトが出力されるだけなので、必ず.stackを出力する。"	"try {
  hoge();
} catch (err) {
  console.log(JSON.stringify(err));
}"	"try {
  hoge();
} catch (err) {
  console.log(err.stack);
}
"
44	gmoの処理をpromiseで同一ユーザーの決済処理を並列実行している	外部API	"gmo処理は同一ユーザーの決済処理を並列実行するとエラーになるためawaitにて直列で実行する
また、gmoの決済処理はrollbackできないため、transactionの最後に記述する"		
45	DBカラム名 / テーブル名のRename	DB, migration	"・Rollbackできない(Migration流し直し必要)
・ダウンタイムが発生する"	"// renameTable
await queryInterface.renameTable(oldTableName, newTableName);

// renameColumn
await queryInterface.renameColumn(oldColumnName, newColumnName);"	"// 新しいテーブルもしくはカラムを作成する。
// その後APIのリリースによって向き先を変える。

// createTable
await queryInterface.createTable(tableName, {
  // some column...
});

// addColumn
await queryInterface.addColumn({
  // some structure...
});"
46	Reactなのに実DOMを直接操作する	React	実DOMを直接操作するとその都度レンダリングが行われ、パフォーマンスを悪化させてしまう。	"document.body.style.top = `-${window.scrollY}px`;
document.body.style.position = 'fixed';
document.body.style.width = '100vw';"	
47	Reactのcomponentのクリーンアップを考慮しない	React	そのコンポーネントがコンポーネント外の要素を操作していた場合、そのコンポーネントが画面からunmoountされたとき、コンポーネント外の要素に対する操作方法を失う。	"React.useEffect(() => {   
  if (isOpenedSideMenu) {
    fixOffset(); // コンポーネント外の要素を操作する処理
  } else {
    restoreOffset(); // コンポーネント外の要素への操作を解除する処理
  }
}, [fixOffset, isOpenedSideMenu, restoreOffset]);"	"React.useEffect(() => {   
  if (isOpenedSideMenu) {
    fixOffset(); // コンポーネント外の要素を操作する処理
  } else {
    restoreOffset(); // コンポーネント外の要素への操作を解除する処理
  }
}, [fixOffset, isOpenedSideMenu, restoreOffset]);

// アンマウント時必ずスクロール固定を外す
React.useEffect(
  () => () => {
    restoreOffset();
  },
  [],
);"
48	DBなど外部システムへのコネクションをサーバ起動時のみ作成している	DB	内部であれ外部で、あれ別システムへアクセスする場合、IPアドレスではなくドメインでアクセスすることが一般的だが、そのシステムへのコネクションをサーバ起動時に作成しているだけだと、そのドメインが参照しているIPが変更された場合アクセスできなくなる。	"//起動時に下記を実行

module.exports = { user_events: mongoose.model('user_events', schema) };"	"//実行時にコネクションを作成（下記は一例）

module.exports = () => ({ user_events: mongoose.model('user_events', schema) });"
49	PCとSPの出し分けをjsで行う	レスポンシブ対応	jsでハンドリングしていると、画面のリサイズが行われたときに画面の切り替えが行われないため。（resizeイベントは使っていない前提）	"if (window.outerWidth < 768) {
  // SPのスタイリング関連処理
} else {
  // PCのスタイリング関連処理
}"	".class {
  /* SP用のスタイル */
}
@media screen and (min-width: 768px) {
  /* PC用のスタイル */
}

画像パスであればpictureタグ使う。"
50	absoluteやfixedなどを使っているのに、画面幅を変えてテストしていない	結合テスト	"画面幅によって崩れる可能性が高く保守性が悪い。
使わなくて済むなら絶対使わない。"		
51	DBにinsert/update直後に最新データを取得するため、再度getする	DB	"DBのmaster-slave使ったら、最新データを取れない可能性がある

経緯：
Aurora MySQLではトランザクションIDを指定することで、特定のトランザクションのスナップショットをリードレプリカから読み取ることができます。しかし、この方法はリアルタイム性を保証するものではなく、リードレプリカは通常、プライマリインスタンスのデータにタイムラグがあるため、最新のデータを反映していない可能性があります。

一般的に、Aurora MySQLのリードレプリカはリアルタイム性を求める用途ではなく、読み取り負荷を分散するために使用されます。コミットされたデータを安定して読む場合は、プライマリインスタンス上での操作を行うことが推奨されます。

要するに、トランザクションIDを指定すれば過去のトランザクションのデータにアクセスできるが、リアルタイムのデータを取得するためにはプライマリインスタンスを利用し、コミットされたデータを読むことが最も適しています。リードレプリカは通常、読み取り負荷分散や冗長性向上のために使用され、リアルタイム性は保証されていません。"	"const { masterCoordinatePriceScheduleIds } =
  awalt this._insertMasterCoordinatePriceSchedule(
    masterCoordinatePriceScheduleData,
  );

const coordinateAggregates =
  await this.coordinateRepository.getManyByCondition({
    masterCoordinatePriceSchedulelds,
  });

if (coordinateAggregates, length) {
  this._dispatchCoordinateStylePriceAndRentalStockChangedEvent (
    coordinateAggregates,
  );
}"	
52	あるテーブルにrelationを追加した際に、キャンセル処理の考慮をしない。	設計	"システム上様々なキャンセル処理（例えば月額会員退会など）があるが、relationがあるテーブルは一緒にキャンセルしないとデータ上不整合が発生する。
そのため新たにrelationを追加する場合は、relation元のデータがキャンセル状態になる処理を考慮しなければならない。"		
53	クライアントから渡されたパラメータのみを使ってリソースの更新/削除（場合によっては取得）を行う	設計	"クライアントからサーバにわたすパラメータはいくらでも偽装が可能。
そのためクライアントから渡されたパラメータをそのまま使うとかなり危ないセキュリティリスクになる。"	"// client side
request.put('/user', { user_id: 12345, last_name: 'foo' });
-----------------------------------------------------------
// server side
export default () => (req, res) {
  db.users.update({ last_name: req.body.last_name }, {where: { id: req.body.user_id }});
}"	"// client side
request.put('/user', { last_name: 'foo' });
-----------------------------------------------------------
// server side
export default () => (req, res) {
  // headerにある認証情報からユーザ情報に変換。本来middlewareでいれておくと便利。
  const currentUser = getUser(req.headers.cookies);
  db.users.update({ last_name: req.body.last_name }, {where: { id: currentUser.user_id }});
}"
54	複数の単体テストで、同一のテストデータを使用する	単体テスト	単体テストのテストデータを共通で使うと実行順によって結果が変わるし、前提となるデータの条件も分かりにくくなるため、基本的にテストケース：テストデータは1:1にする。		
55	anyやunknownの型をコメントアウトの補足なしに使う	TypeScript	"TSファイルの場合、原則型を付けたい。
どうしても型が付けられないオブジェクトを扱う場合は、コメントアウトで補足してanyやunknownを使用する。"	const gmoData: any = gmo.response;	"// サードパーティのレスポンスの型は不明なためany
const gmoData: any = gmo.response;"
56	imgタグにaltタグがない	フロントエンド	imgタグにaltタグがないとSEO的に全く評価されないし、アクセシビリティの観点からもNG。	<img src="hogehoge.png">	<img src="hogehoge.png" alt="ファッション（洋服）のサブスク・レンタル　エアークローゼット 300ブランドからプロが厳選">
57	fetch all data from DB without limit, offset	DB, backend	limit, offsetがないと、データが多くなる場合はメモリオーバーエラーになってしまう	getAllUserDataFromDB()	"getAllUserDataFromDB({
  limit: XXX,
  offset: YYY
})"
58	try文ないで非同期処理をawaitしない	JavaScript,TypeScript	try-catch構文でawaitをつけていないと非同期処理の実行完了を待たないため、エラーが発生してもcatchされない。	"// ex.1
try {
  errorAsyncFunction();
} catch (error) {
  console.error('これは表示されない');
}
-----------------------------------------
// ex.2
try {
  return errorAsyncFunction();
} catch (error) {
  console.error('これは表示されない');
}"	"// Way to resolve.1
try {
  await errorAsyncFunction();
} catch (error) {
  console.error('これは表示される');
}
-----------------------------------------
// Way to resolve.2
errorAsyncFunction().catch((error) => {
  console.error('これは表示される');
};
"
59	環境変数を参照する際に、固定値でstg環境で使う値を入れる	JavaScript,TypeScript	本来「環境変数の設定できているか」もSTG環境で担保すべきだが、対応漏れのリスクやテストの意味がなくなるなどの問題がある	const clientAccessToken = process.env.CLIENT_TOKEN_PAYMENT || 'NzsPGajkaVWkQrA7R6Q8';	const clientAccessToken = process.env.CLIENT_TOKEN_PAYMENT;
60	dayjs.format使うときに小文字のhhを使う	JavaScript,TypeScript	午後の時間が勝手に-12hになってしまう場合がある	"dayjs(""2024-01-31 16:58:00"").format('YYYY-MM-DD hh:mm:ss')
= 
2024-01-31 4:58:00"	"dayjs(""2024-01-31 16:58:00"").format('YYYY-MM-DD HH:mm:ss')
= 
2024-01-31 16:58:00"
61	deleteなどを用いてプロパティの削除をする	JavaScript,TypeScript	プロパティをdeleteする処理を追加した結果、そのプロパティを参照している場所で意図しない挙動となった	"プロパティをdeleteする処理を追加した結果エラーが発生

⁠const func = x ⇒ console.log(x.b.c); // Cannot read properties of undefined
⁠
⁠const a = {a: 'a', b: {c: 'c'}};

// inserted process: start
⁠delete a.b;
console.log(a); // Logging {a: 'a'} is expected
// inserted process: end

⁠x(a);"	"特定のプロパティを渡したくない場所でオブジェクトを再定義する

⁠const func = x ⇒ console.log(x.b.c); // The log is 'c'
⁠
⁠const a = {a: 'a', b: {c: 'c'}};
⁠
// inserted process: start
const newA = {a: a.a};
console.log(newA); // The log is {a: 'a'}
// inserted process: end

⁠x(a);"
62	first viewのABテストを初期レンダリング後にjsで実行する	JavaScript,TypeScript,フロントエンド	"ABテストしたい内容（画像やテキストなど）が画面を開いたあとにちらつく。
また、初期で表示しない状態にしてしまうとSEO観点で悪影響が出る。"	"``` HTML ``````````````````````````````````````````````````````
<body>
  <h1 class=""hero-image"">
    <img class=""imageA"" src=""patternA.png"" />
    <img class=""imageB"" src=""patternB.png"" />
    <img class=""imageC"" src=""patternC.png"" />
  </h1>
  <script src=""main.js""></script>
</body>
 ``````````````````````````````````````````````````````````````````

``` javascript main.js ```````````````````````````````````````
const pattern = getPattern();

switch (pattern) {
  case 'A':
    $('.imageA').show();
    $('.imageB').hide();
    $('.imageC').hide();
    break;
  case 'B':
    $('.imageA').hide();
    $('.imageB').show();
    $('.imageC').hide();
    break;
  case 'C':
    $('.imageA').hide();
    $('.imageB').hide();
    $('.imageC').show();
    break;
}
 ``````````````````````````````````````````````````````````````````"	"``` HTML `````````````````````````````````````````````````````
<body>
  <script src=""pre-main.js""></script>
  <h1 class=""hero-image"">
    <img class=""imageA"" src=""patternA.png"" />
    <img class=""imageB"" src=""patternB.png"" />
    <img class=""imageC"" src=""patternC.png"" />
  </h1>
</body>
``````````````````````````````````````````````````````````````````

``` javascript pre-main.js `````````````````````````````````
const pattern = getPattern();
document.body.classList.add(`pattern-${pattern}`);
``````````````````````````````````````````````````````````````````

``` css `````````````````````````````````````````````````````````
body.patternA {
  .imageA { display: block; };
  .imageB { display: none; };
  .imageC { display: none; };
}
body.patternB {
  .imageA { display: none; };
  .imageB { display: block; };
  .imageC { display: none; };
}
body.patternC {
  .imageA { display: none; };
  .imageB { display: none; };
  .imageC { display: block; };
}
``````````````````````````````````````````````````````````````````"
63	外部サービスに不要なパラメータを渡している	外部API	不要なパラメータを渡すことで、外部サービス側で意図しないエラーが起こる可能性があるため	"const peymentParams = {
  ac_user_id: 1,
  payment_id: 100,
  item_id: 200,
  price: 9000,
}

payment(peymentParams);"	"const peymentParams = {
  price: 9000,
}

payment(peymentParams);"
64	REST apiのendpointを定義するとき、resourceに対する操作内容をendpointに含める	ルーティング	"REST APIの原則としてURIはresouceを示すもの。それに対する操作内容はHTTP Methodで表現し、統一インターフェイスを担保するべき。
参考
https://qiita.com/NagaokaKenichi/items/0f3a55e422d5cc9f1b9c"	get: /v1.14/me/getCoupon/	get: /v1.14/me/coupon/
65	特定のパラメータの条件で条件分岐するときに、switchでもなくelse ifでもなくifを使う	プログラミング	予期せず複数回if文の中に入る可能性があるため、絶対にelse ifかswitch。	"if (itemType === ITEM_TYPE.RENTAL_TYPE) {
}
if (input.itemPurchaseTypeForRental && input.itemPurchaseTypeRateForRental) {
}
if (
  [ITEM_TYPE.ACCESSORIES_TYPE, ITEM_TYPE.PURCHASE_TYPE].includes(itemType) &&
  (input.itemPurchaseTypeForPurchase || input.itemPurchaseTypeForAccessory) &&
  input.itemPurchaseTypeRateForPurchase
) {
}
if (itemType === ITEM_TYPE.ACCESSORIES_TYPE && input.itemPurchaseTypeForAccessory) {
}"	"if (itemType === ITEM_TYPE.RENTAL_TYPE) {
} else if (
  input.itemPurchaseTypeForRental &&
  input.itemPurchaseTypeRateForRental) {
} else if (
  [ITEM_TYPE.ACCESSORIES_TYPE, ITEM_TYPE.PURCHASE_TYPE].includes(itemType) &&
  (input.itemPurchaseTypeForPurchase || input.itemPurchaseTypeForAccessory) &&
  input.itemPurchaseTypeRateForPurchase
) {
} else if (itemType === ITEM_TYPE.ACCESSORIES_TYPE && input.itemPurchaseTypeForAccessory) {
}"
66	リリースに伴い、本番環境が参照しているリソースに影響を及ぼす処理（データ移行など）を実行する場合に、その処理が行われている間の処理が考慮されていない	基本設計	短い時間であっても致命的なインシデントにつながる恐れがある。		
67	select以外（INSERT, UPDATE, DELETE）でORM ライブラリーを使用する際に、Promise.all()でトランザクション実行するとエラーが発生した時にロールバックされない	プログラミング	https://medium.com/@alkor_shikyaro/transactions-and-promises-in-node-js-ca5a3aeb6b74	"entityManager.transaction

const updates = [
  { id: 1, /* other fields to update */ },
  { id: 2, /* other fields to update */ },
  // ... more updates
];
entityManager.transaction( async(trans) => {
     await Promise.all(updates.map(e => repo.update(e)))
   }
)

----------------------------
queryRunner

const updates = [
  { id: 1, /* other fields to update */ },
  { id: 2, /* other fields to update */ },
  // ... more updates
];

try {
  const transaction = await queryRunner.startTransaction()
  await Promise.all(updates.map(e => transaction.getRepository(repo).update(e)))
  
}catch (e) {
 await transaction.rollback()
 throw new Error(e)
} finally {
  await transaction.commit()
}

----------------------------"	"using Promise.allSetttled()

import { EntityManager } from 'typeorm';

// Assuming you have an `entityManager` instance
const updates = [
  { id: 1, /* other fields to update */ },
  { id: 2, /* other fields to update */ },
  // ... more updates
];

await entityManager.transaction(async (manager) => {
  const promises = updates.map(async (update) => {
    const query = { id: update.id };
    delete update.id; // Remove the ID field to prevent updating it
    await manager.update(YourEntity, query, update);
  });

  // Wait for all promises to settle
  await Promise.allSettled(promises);
});

----------------------------
using await for each record

import { EntityManager } from 'typeorm';

// Assuming you have an `entityManager` instance
const updates = [
  { id: 1, /* other fields to update */ },
  { id: 2, /* other fields to update */ },
  // ... more updates
];

await entityManager.transaction(async (manager) => {
  for (const update of updates) {
    const query = { id: update.id };
    delete update.id; // Remove the ID field to prevent updating it
    await manager.update(YourEntity, query, update);
  }
});"
68	CSSでネガティブマージンを使っている	プログラミング, フロントエンド, CSS	"・スタイリングが複雑になり、崩れる場合がある
・ブラウザにより効かない
・インライン要素には効かない（特例あり）"	".hoo {
    margin-bottom: 100px;
}
.hoge {
    margin-top: -100px;
}"	".hoo {
    
}
.hoge {
    
}"
69	TypeormでLimitとOffsetを使わらず、SkipとTakeを使用する	Typeorm, limit, offset, skip, take	TypeormでLimitとOffsetを使ったら、RAWクエリでやっていて、one_to_manyとmany_to_manyリレーションがあれば、最後の結果は正しくなくなる。SkipとTakeなら、最後の結果で適用してるので、結果は正しく取得できる。	"query.limit(limitCondition);
query.offset((pageCondition - 1) * limitCondition);"	"query.take(limitCondition);
query.skip((pageCondition - 1) * limitCondition);"
70	新しい変数やプロパティをつくるときに、データソースと全然違う名前を設定する	プログラミング, 変数	なにがはいっている変数なのか非常にわかりづらくなってしまう、かつ本来その名前が意味しているものが別で存在する場合に、とてつもなくメンテしづらくなるため。	"const [{ shopIdentityCode: itemCode = '' }] = itemSkuProperties;

return {
    code: itemCode,
};
https://github.com/air-closet/bridge-api/blob/989de34e73892820402c36c320246faf00d8822e/src/view-provider/dtoFactory/receive-record/external/index.ts#L94"	"const [{ shopIdentityCode }] = itemSkuProperties;

return {
    shopIdentityCode,
};"
71	lowerCaseを交換したい場合にJavaScriptのBuildInメソッド（string.prototype.toLowerCase()）ではなく、3rdパーティーライブラリのメソッドを使う	javascript,プログラミング	Lodash.lowerCaseを使うと、メールアドレスのフォーマットが崩れてしまいます。メールアドレスの比較や変換には、lowerCaseは適していません。	"https://github.com/lodash/lodash/blob/e51a424513fbbe83a34c1b3c21f8c5478e79389f/lowerCase.js

checkEmailChanged(email:string, changedEmail:string){
   return Lodash.lowerCase(email) !== Lodash.lowerCase(changedEmail);
}"	"checkEmailChanged(email:string, changedEmail:string){
   return email.toLowerCase() !== changedEmail.toLowerCase;
}"
72	同列の条件分岐のなかで、同期処理と非同期処理が混在している	javascript,プログラミング	返却される値が条件によって変わってしまう（型が決められない）。	"if (warehouseWorkInstructionDate && orderIdList.length) {
  await rentalUsecase.shipping(...);
} else if (orderIdList.length) {
  await rentalUsecase.shipping(...);
} else {
  rentalUsecase.shipping(...);
}"	"if (warehouseWorkInstructionDate && orderIdList.length) {
  await rentalUsecase.shipping(...);
} else if (orderIdList.length) {
  await rentalUsecase.shipping(...);
} else {
  await rentalUsecase.shipping(...);
}"
73	処理の失敗をcatchして同じ処理を実行する	プログラミング	無限loopになる	"/* /slackのendpointがエラーを返してくる処理の場合、無限loopする */
function request (url, body) {
  try {
    await axios.post(url, body);
  } catch (err) {
    errorLogger(err);
  }
}

function errorLogger(err) {
  try {
    await sendSlack('errorChannel', err.stack);
  } catch (err) {
    return {};
  }
}

function sendSlack(channel, message) {
  request('/slack', { channel, message });
}

try {
  request('/slack', { channel: 'developers', message: 'この味は、嘘をついてる味だぜッ！' });
} catch (err) {
  errorLogger(err);
}"	"/* そもそもエラー通知はログファイルに出力して、slack通知はlog warehouseに任せるべき */
function request (url, body) {
  try {
    axios.post(url, body);
  } catch (err) {
    errorLogger(err);
  }
}

function errorLogger(err) {
  console.error(err.stack);
  } catch (err) {
    return {};
  }
}

try {
  request('/slack', { channel: 'developers', message: 'この味は、嘘をついてる味だぜッ！' });
} catch (err) {
  errorLogger(err);
}"
74	DBで型がdatetimeのcolumnに対して、dateしか条件で渡されていない（timeが渡されていない）	プログラミング	dateのみの条件の場合、UTC,JSTのズレなどで意図した挙動にならない場合が発生する	startDate.format('YYYY-MM-DD')	startDate.format('YYYY-MM-DD hh:mm:ss')
75	既存の変数名や関数名、プロパティ名に対して、それに近い新しい概念を追加するときに、NEWやOLDなどの単語を使う	プログラミング	その時点ではNewかもしれないが、数年後には絶対にNewではないし、可能ならそれらの塊がどういう概念の塊なのかで変数名をつけたい。	"const FIGURE_TYPES = {
  1: 'Aライン',
  2: 'Iライン',
  3: 'Vライン',
};

const FIGURE_TYPE_NEWS = {
  9: 'ストレート',
  10: 'ウェーブ',
  11: 'ナチュラル',
  88: 'わからない',
};"	"const FIGURE_TYPES = {
  1: 'Aライン',
  2: 'Iライン',
  3: 'Vライン',
};

const FIGURE_TYPES_V2 = {
  9: 'ストレート',
  10: 'ウェーブ',
  11: 'ナチュラル',
  88: 'わからない',
};"
76	関数、メッソドのinput, outputの型をつけない	TypeScript	"外部ライブラリのレスポンスをそのまま使っていると、本来のレスポンスと異なる型が付く場合がある。
関数やメソッドのinterfaceを定義することで、型の正しさを1つの関数、メソッド内で担保することができるようになり、可読性、保守性を上げることができる"	"const func = (params) => {
  return db.items.find(
    {
      attributes: ['id', 'sku_id'],
      where: params,
    }
  )
}"	"type IFuncParams = {
  id: number
};

type IFuncResponse = {
  id: number,
  sku_id: number,
}

const func = (params: IFuncParams): IFuncResponse => {
  return db.items.find(
    {
      attributes: ['id', 'sku_id'],
      where: params.where,
    }
  )
}"
77	APIキーやtokenなど秘匿すべきものをconfigやプログラムに記載し、gitのリモートレポジトリにアップロードする	APIキー, config	セキュリティインシデントにつながるため	"air-closet-config/config.jsonに外部サーバーのAPIキーを書く

{
  ""sendgrid"": {
    ""token"": ""XXXXXXXXXXXX""
  }
}
"	"secret managerに書き、アプリケーション側で使うタイミングで取得する

{
  // API keyやtokenはconfigに書かない
}
"
78	classをトップレベルでインスタンス化する	プログラミング	"単体テストでmockしたいときにできなくなる可能性がある。
トップレベルでインスタンス化できるclassは中で状態を持ってないからclassで作る意味がない。"	"```
import UserService from '~/domain/User/service/'

// トップレベルでインスタンス化している
const userService = new UserService();

const getPlan = (userId: number) => {
  return userService.getPlan(userId);
}
```"	"```
import UserService from '~/domain/User/service/'

const getPlan = (userId: number) => {
  // 使用するタイミングでインスタンス化している
  const userService = new UserService();
  return userService.getPlan(userId);
}
```


そもそもの正しいclass設計では下記のように必要な状態がインスタンス化するときに渡されるべき
```
import UserService from '~/domain/User/service/'

const getPlan = (userId: number) => {
  const userService = new UserService(userId);
  return userService.getPlan();
}
```"
79	外部API利用時にレスポンスがundefined, null, error, 空配列になる場合のハンドリングを考慮できていない	プログラミング, 設計, エラーハンドリング	外部APIはさまざまな理由で期待通りのレスポンスを返さないことがある。仕様としてNullを返す場合、ネットワークの問題、APIの不具合、データの不整合など。これらの状況を考慮せずにコードを記述すると、アプリケーションが予期しない動作をする可能性が高まる。	"const fetchData = async (apiUrl) => {
    const response = await fetch(apiUrl);
    const data = await response.json(); // ここでエラーが発生する可能性あり

    // dataがundefinedまたはnullの場合の処理がない
    return data.property; // ここでTypeErrorが発生する可能性あり
};
"	"const fetchData = async (apiUrl) => {
    try {
        const response = await fetch(apiUrl);

        if (!response.ok) {
            throw new Error('Network response was not ok');
        }

        const data = await response.json();

        // dataがundefinedまたはnullの場合の処理
        if (!data) {
            logger.api.error('Received null or undefined data');
            return null; // 適切なエラーハンドリング
        }

        // dataが正しい場合の処理
        return data.property;
    } catch (error) {
        logger.api.error('Fetch error: ', error);
        // エラーハンドリングの処理
        return null; // エラー時の適切な返り値
    }
};
"
80	APIのInput/Outputが変わるときにAPI Versionを上げない	プログラミング, 設計	"・既存クライアントの互換性が壊れる
　古いフォーマットを前提にしたクライアントが、突如として新しい形式のデータを受け取り、処理に失敗する。
・障害発生時の切り戻しが困難になる
　どのクライアントがどの形式を期待しているかが不明になり、変更前の状態に戻すのが困難。"	"// 以前は以下のようなレスポンスを返していた：
// { ""id"": 1, ""name"": ""John"" }

app.get('/api/v1/user', (req, res) => {
  // 仕様変更により以下のようなレスポンスに変更されてしまった：
  res.json({
    id: 1,
    firstName: 'John',
    lastName: 'Smith'
  });
});"	"// v1: 以前の形式
app.get('/api/v1/user', (req, res) => {
  res.json({
    id: 1,
    name: 'John'
  });
});

// v2: 新しい形式（firstName, lastName に分割）
app.get('/api/v2/user', (req, res) => {
  res.json({
    id: 1,
    firstName: 'John',
    lastName: 'Smith'
  });
});"
81	toLocaleString()を使用する	プログラミング, javascript	"Number.prototype.toLocaleString() は、ロケールに応じたフォーマット（カンマや小数点、スペースなど）を自動で適用してくれる便利なメソッドですが、以下のような問題があります：
・実行環境のロケールに依存する
　→ 特にCI/CDや本番ビルド環境が日本ではなくベトナムやその他の国に設定されていると、意図しない形式（例：12 345のようなスペース区切り）になる。
・明示的にロケールを指定できるとはいえ、コード全体の統一性や保守性が下がる
　→ ""ja-JP"" を都度指定すれば日本形式にはなるが、チームでそれが徹底されていなければ環境によって揺れてしまう。
・リリース後のUIバグに直結しやすい
　→ 実際に ACE でのリリース作業中に、ベトナムロケールによるフォーマットが原因で表示崩れが発生したという実例あり。"	"const number = 12345;
console.log(number.toLocaleString()); // ベトナム環境では ""12 345"" になることがある

const number = 12345;
console.log(number.toLocaleString(""ja-JP"")); // 明示しても、運用上のブレを完全には防げない"	"function formatNumberWithCommas(num) {
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, "","");
}

const number = 12345;
console.log(formatNumberWithCommas(number)); // ""12,345"""
82	ssrでクライアントとサーバーが同じ変数（cookies）を編集する	プログラミング, javascript	クライアントとサーバーの両方が同じ変数を更新すると、コンフリクトが発生しやすくなります。例えば、サーバー側は削除しようとしているのに、クライアント側は追加してしまう、といった具合です。これによりクッキーの状態をコントロールするのが非常に難しくなり、副作用的なバグを引き起こしやすくなります。	"//-- src/server.js
res.saveCookie('_ac_before_path', { path: '/' });

//-- client/action.js
cookie.save('_ac_before_path', beforePath, cookieOptions);
"	"//-- src/server.js
//-- クライアントが編集できないようにhttpOnly設定
res.saveCookie('_ac_before_path', { path: '/' }, {httpOnly: true});

//-- client/action.js
"
