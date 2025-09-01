リーダブルコードのうち、コードレビューで守りたいもののリストです。
これらを守りつつ可読性,保守性の高いコードを作りたい。


章節	タイトル	要約	例
2.1	明確な単語を選ぶ	getのような曖昧な単語より具体的な単語を使う	"// 悪い例：曖昧
function getPage(url) { }

// 良い例：具体的
function fetchPage(url) { }  // インターネットから取得
function downloadPage(url) { }  // ダウンロードする"
2.2	汎用的な名前を避ける	tmpやretvalのような汎用名は具体的な目的がある時のみ使う	"// 悪い例：汎用的すぎる
let retval = 0.0;
for (let i = 0; i < v.length; i++) {
    retval += v[i] * v[i];
}

// 良い例：目的が明確
let sumSquares = 0.0;
for (let i = 0; i < v.length; i++) {
    sumSquares += v[i] * v[i];
}"
2.3	抽象的な名前よりも具体的な名前を使う	ServerCanStart()よりCanListenOnPort()のほうが具体的	"// 悪い例：抽象的
function serverCanStart() { }

// 良い例：具体的
function canListenOnPort() { }"
2.4	名前に情報を追加する	単位や重要な属性を名前に含める	"// 単位を含める
delay → delaySecs
size → sizeMb
angle → degreesCw

// 重要な属性を含める
password → plaintextPassword
comment → unescapedComment"
2.5	名前の長さを決める	短いスコープなら短い名前でも可、長いスコープなら説明的な名前を	"// 短いスコープ：短い名前でOK
if (debug) {
    const m = new Map();
    lookupNamesNumbers(m);
    print(m);
}

// 長いスコープ：説明的な名前が必要
class member: userDatabaseConnection"
2.6	名前のフォーマットで情報を伝える	大文字小文字やアンダースコアで意味を区別する	"// 定数
const MAX_OPEN_FILES = 100;

// プライベートプロパティ
class LogReader {
    private _offset: number;  // _で始まるとプライベート
}"
4.5	一貫性と意味のある並び	コードの順序に意味を持たせて一貫性を保ち、コードを読む際の視線移動を最小化できるように並べる	"// HTMLフォームの順序に合わせる
// または重要度順、アルファベット順など一貫した順序
const details = request.POST.get('details');
const location = request.POST.get('location');
const phone = request.POST.get('phone');
const email = request.POST.get('email');"
4.6	宣言をブロックにまとめる	意味のあるまとまりをコードブロックにする	"class FrontendServer {
    constructor() { }
    destructor() { }

    // Handlers
    viewProfile(request: HttpRequest): void { }
    saveProfile(request: HttpRequest): void { }

    // Database Helpers
    openDatabase(location: string, user: string): void { }
    closeDatabase(location: string): void { }
}"
4.7	コードを「段落」に分割する	段落でコードブロックを作る	"function suggestNewFriends(user: User, emailPassword: string) {
    // ユーザの友達のメールアドレスを取得する
    const friends = user.friends();
    const friendEmails = new Set(friends.map(f => f.email));

    // ユーザのメールアカウントからすべてのメールアドレスをインポートする
    const contacts = importContacts(user.email, emailPassword);
    const contactEmails = new Set(contacts.map(c => c.email));

    // まだ友達になっていないユーザを探す
    const nonFriendEmails = contactEmails.difference(friendEmails);
}"
4.8	個人的な好みと一貫性	個人の好みより一貫性の方が大事	"// どちらも正しいが、組織内では統一
class Logger {
    // ...
}

// または
class Logger
{
    // ...
}"
5.1	コメントするべきでは「ない」こと	コードから素早く分かることはコメントしない	"// 悪い例：冗長なコメント
// Accountクラスの定義
class Account {
    // コンストラクタ
    constructor() { }
}

// 良い例：価値のあるコメント
// 与えられた'name'に合致したNodeかnullを返す
function findNodeInSubtree(subtree: Node, name: string, depth: number): Node | null { }"
5.2	自分の考えを記録する	書き手の意図をコメントする	"// 合理的な限界値。人間はこんなに読めない。
const MAX_RSS_SUBSCRIPTIONS = 1000"
5.3	読み手の立場になって考える	読み手の理解を助けるコメントをする	"# ハマりそうな罠を告知する
// メールを送信する外部サービスを呼び出している（1 分でタイムアウト）
function SendEmail(string to, string subject, string body) {}

# 要約するコメント
// 顧客が自分で購入した商品を検索する
for (customer_id in all_customers) {
  for (sale in all_sales[customer_id].sales) {
    if sale.recipient == customer_id:"
7.2	if/else ブロックの並び順	簡単なケース、興味深いケースを先に書くなどで、条件分岐全体で認知負荷が低くなるような順序でif文を記述する。	"// 良い例：正のケースを先に
if (url.hasQueryParameter('expand_all')) {
    // expand処理
} else {
    // 通常処理
}

// 悪い例：負のケースが先
if (!url.hasQueryParameter('expand_all')) {
    // 通常処理
} else {
    // expand処理
}"
7.7	ネストを浅くする	early return, early continueでネストを減らす	"// 悪い例：深いネスト
if (userResult === 'SUCCESS') {
    if (permissionResult !== 'SUCCESS') {
        reply.writeErrors('error reading permissions');
        reply.done();
        return;
    }
    reply.writeErrors('');
}

// 良い例：フラットな構造
if (userResult !== 'SUCCESS') {
    reply.writeErrors(userResult);
    reply.done();
    return;
}
if (permissionResult !== 'SUCCESS') {
    reply.writeErrors(permissionResult);
    reply.done();
    return;
}
reply.writeErrors('');"
8.1	説明変数	複雑な部分式に名前を付けて理解しやすくする	"// 悪い例：複雑な式
if (line.split(':')[0].trim() === 'root') { }

// 良い例：説明変数
const username = line.split(':')[0].trim();
if (username === 'root') { }"
8.6	巨大な文を分割する	"複雑な処理は処理単位で分割する
共通処理は別関数、別変数にしてまとめる"	"// 改善前：重複が多く複雑
const canView = (user, resource) => user && (user.role === 'admin' || user.teamId === resource.teamId);
const canEdit = (user, resource) => user && (user.role === 'admin' || user.id === resource.ownerId);
const canDelete = (user, resource) => user && (user.role === 'admin');

// 改善後：共通部分を抽出
const isAdmin = (user) => user?.resourceole === 'admin';
const sameTeam = (user, resource) => user?.teamId === resource?.teamId;
const isOwner = (user, resource) => user?.id === resource?.owner;

const canView = (user, resource) => isAdmin(user) || sameTeam(user, resource);
const canEdit = (user, resource) => isAdmin(user) || isOwner(user, resource);
const canDelete = (user, resource) => isAdmin(user);
"
9.1	変数を削除する	よりシンプルなコードを書けないか考え、不要な変数は削除する	"// 悪い例：不要な変数
const now = new Date();
rootMessage.lastViewTime = now;

// 良い例：直接代入
rootMessage.lastViewTime = new Date();"
9.2	変数のスコープを縮める	変数のスコープは常に最小限にする	"// 悪い例：スコープが広い
class Test {
    private info = database.readPaymentInfo();
    public method () {
        if (info) {
            console.log(`User paid: ${info.amount()}`);
        }
    }
    // infoがまだスコープ内...
}

// 良い例：スコープを限定（TypeScriptでは少し難しいが、ブロックスコープを使用）
class Test {
    public method () {
        const info = database.readPaymentInfo();
        if (info) {
            console.log(`User paid: ${info.amount()}`);
        }
    }
    // infoはスコープ外
}"
9.3	変数は一度だけ書き込む	再代入は他の手段がない限り使わない	"// 悪い例：変数を何度も書き換える
let total = 0;
total = 100;        // 基本料金
total = total + 50; // アイテム追加
total = total * 1.1; // 税金適用
return total;

// 良い例：各段階で新しい変数を使う
const baseFee = 100;
const subtotal = baseFee + 50;
const total = subtotal * 1.1;
return total;"
10.1	入門的な例：findClosestLocation()	複雑な処理は関数に切り出してカプセル化する	"// 悪い例：メインロジックに距離計算が混在
const findClosestLocation = (lat: number, lng: number, array: Location[]) => {
    for (let i = 0; i < array.length; i++) {
        // 複雑な球面距離計算...
        const dist = Math.acos(Math.sin(latRad) * Math.sin(lat2Rad) + ...);
        // 最近接判定ロジック
    }
};

// 良い例：責務分離
const sphericalDistance = (lat1: number, lng1: number, lat2: number, lng2: number): number => {
    // 球面距離計算のみ
};
const findClosestLocation = (lat: number, lng: number, array: Location[]) => {
    const dist = sphericalDistance(lat, lng, array[i].latitude, array[i].longitude);
    // 最近接判定ロジックのみ
};"
10.3	その他の汎用コード	汎用的な処理は別関数で切り出す	"// 悪い例：Ajax処理に表示ロジックが混在
ajaxPost({
    onSuccess: (responseData: any) => {
        let str = '{\n';
        for (const key in responseData) {
            str += ` ${key} = ${responseData[key]}\n`;
        }
        alert(str + '}');
    }
});

// 良い例：表示ロジックを分離
const formatPretty = (obj: any): string => {
    let str = '{\n';
    for (const key in obj) {
        str += ` ${key} = ${obj[key]}\n`;
    }
    return str + '}';
};
// Ajax処理はシンプルに
ajaxPost({
    onSuccess: (responseData: any) => {
        alert(formatPretty(responseData));
    }
});"
"10.6
10.7"	"既存のインタフェースを簡潔にする
必要に応じてインタフェースを整える"	責務を分離しインターフェイスを整えることで、処理本体のコードで扱いたい問題に注力できるようにする	"// ブラウザのCookie APIをラップ
function getCookie(name: string): string | null {
    const cookies = document.cookie.split(';');
    for (const cookie of cookies) {
        const c = cookie.replace(/^[ ]+/, '');
        if (c.indexOf(name + '=') === 0) {
            return c.substring(name.length + 1, c.length);
        }
    }
    return null;
}

// 使いやすいAPI
const maxResults = getCookie('max_results');"
10.8	やりすぎ	細分化もやりすぎだと可読性が下がるので、責務が明確な範囲でまとめる	"// 悪い例：細分化しすぎ
function urlSafeEncryptObj(obj: any): string {
    return urlSafeEncryptStr(JSON.stringify(obj));
}

function urlSafeEncryptStr(data: string): string {
    return btoa(encrypt(data));
}

function encrypt(data: string): string {
    return makeCipher().update(data) + makeCipher().final();
}

// 良い例：必要十分な抽象化
function urlSafeEncrypt(obj: any): string {
    // 必要な処理をまとめて実装
}"
11	1度に1つのことを	1つの処理では1つのタスクを行い、1つの責務を持つ	"// 改善前：複数タスクが混在
const voteChanged = (oldVote: string, newVote: string) => {
    let score = getScore();
    if (newVote !== oldVote) {
        if (newVote === 'Up') {
            score += (oldVote === 'Down' ? 2 : 1);
        } else if (newVote === 'Down') {
            score -= (oldVote === 'Up' ? 2 : 1);
        } else if (newVote === '') {
            score += (oldVote === 'Up' ? -1 : 1);
        }
    }
    setScore(score);
};

// 改善後：タスク分離
const voteValue = (vote: string): number => {
    if (vote === 'Up') return +1;
    if (vote === 'Down') return -1;
    return 0;
};
const voteChanged = (oldVote: string, newVote: string) => {
    let score = getScore();
    score -= voteValue(oldVote);  // 古い投票を削除
    score += voteValue(newVote);  // 新しい投票を追加
    setScore(score);
};"
12	コードに思いを込める	処理で実現したいことを言語化して、文章として読めるコードを書く	-
13.2	質問と要求の分割	要件を満たすために必要十分な処理を実装する	"# 店舗検索の例：地球上の任意の位置で最近接店舗を見つける
## 元の要求
→国際日付変更線、極地、地球の曲率を考慮

## 簡素化した要求
テキサス州内で近似的に最近接店舗を見つける
→単純なユークリッド距離で十分"
13.3	コードを小さく保つ	不要なコードの削除や重複したコードをまとめることでコード総量を小さく保つ	-
13.4	身近なライブラリに親しむ	ライブラリで実装できるものはライブラリを使う	"// 悪い例：独自実装
function unique(elements: number[]): number[] {
    const temp: {[key: number]: boolean} = {};
    for (const element of elements) {
        temp[element] = true;
    }
    return Object.keys(temp).map(Number);
}

// 良い例：標準ライブラリ
const uniqueElements = [...new Set([2, 1, 2])];"
14	テストと読みやすさ	単体テストもソースコードと同様に可読性を意識する	具体的な観点は本を参照
