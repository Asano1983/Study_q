
my q Tips

プラクティス的なことについて。
主にQ Tipsを読んで書きました。
構成や項目名はEffective C++を微かに意識しました。

# 制御構文

## `if`はアーリーリターンするときのみ使おう

条件分岐は通常、三項演算子（条件演算子）あるいは次項のarray lookupを使って行う。
`if`は関数から途中で抜けるときに限って使う。

次の例はq Tipsの`.stat.bm`である。
入力値が事前条件を満たさないときに例外を投げている。

```
/ box-muller
bm:{
 if[count[x] mod 2;'`length];
 x:2 0N#x;
 r:sqrt -2f*log first x;
 theta:2f*acos[-1f]*last x;
 x: r*cos theta;
 x,:r*sin theta;
 x}
```

参考：

Q Tip 11.2 Use `if` statements to exit functions early

[q4m3](https://code.kx.com/q4m3/10_Execution_Control/#1014-if) Well-written q code rarely needs if. One example of legitimate use is pre-checking function arguments to abort execution for bad values.

## array lookupは簡単な条件分岐に使おう

三項演算子（条件演算子）`$[;;]`の代わりにbool値をインデックスとして、要素数2のリストから値を取る技法がある。

```
q)"ny" 0b
"n"
q)"ny" 1b
"y"
```

array lookupはatomicなのでリストや辞書、テーブルにも使える（`each`を書かなくても自動的にリフトされる）。

```
q)"ny" 10101b
"ynyny"
```

但し、三項演算子と異なり、遅延評価されない（正格評価される）ことに注意しよう。

次の例はq Tipsの`.sim.genp`である。
`dtm`の型がtimestamp(12h)、dete(14h)、datetime(15h)のときはtimestamp(p)にキャストし、そうでないときはtimespan(n)にキャストしている。

```
/ generate price path
/ security (id), (S)pot, (s)igma, (r)ate, (d)ate/(t)i(m)e
genp:{[id;S;s;r;dtm]
 t:abs type dtm;
 tm:("np" t in 12 14 15h)$dtm; / array lookup技法を使っている
 p:S*path[s;r;tm%365D06];
 c:`id,`time`date[t=14h],`price;
 p:flip c!(id;dtm;p);
 p}
```

これの拡張版（３値版）として、符号が負、ゼロ、正についての場合分けなどを書くこともできる。

```
q)"S B"1+signum 10 0 -10
"B S"
```

数値の場合は次のような算術記法も便利である。

```
q)flag:1b
q)base:100
q)base+flag*42
142
```

参考：

[q4m3](https://code.kx.com/q4m3/2_Basic_Data_Types_Atoms/#231-boolean) Tip: The ability of booleans to participate in arithmetic can be useful in eliminating conditionals.

Q Tip 8.1 Use array lookups to implement simple conditional statements

Q Tip 5.4 Use scalar condtional $[;;]to implement lazily evaluated blocks

## `while`よりも配列処理を使おう

q言語は配列（リスト）の処理が得意な言語であり、map, filter, fold相当の操作を簡潔に書け、効率的である。
多くの処理はこれらで書くことが可能であるはずで、converge(`(func\)x`)などのiteratorを用いればニュートン法などの収束計算もできる。

```
q)nr:{[e;f;x]$[e>abs d:first[r]%last r:f x;x;x-d]} / newton-raphson
q)func:{(-2+x*x;2*x)}
q)nr[1e-10;func;]/[1.0]
1.414214
```

稀であるが`while`が必要なときもある。
次の例はq Tipsの`.timer.loop`（CEPエンジンにおけるループ関数）である。

```
/ scan timer (t)able for runable jobs
loop:{[t;tm]
 while[tm>=last tms:t `time;t:run[t;-1+count tms;tm]];
 t}
```

参考：

[q4m3](https://code.kx.com/q4m3/10_Execution_Control/#1016-while) The author has never used while in actual code.

[Reference](https://code.kx.com/v2/basics/control/#control-words) Control words are little used in practice for iteration. Iterators are more commonly used.

Q Tip 17.9 Pursue the functional-vector solution

## 制御構文は１行で書こう。

`if`や`while`は１行で書いてしまおう（１行で書ける程度の内容に留めよう）。
`if[...]`や`while[...]`の中にはセミコロンが現れるが、改行はしないようにしよう。

参考：

Q Tip 4.5 Limit control flow statesments to a single line


# データ構造

## 要素1のリストを作るときは`enlist`を使おう

要素1のリスト（q言語ではシングルトンという）を作る方法はいろいろがあるが、`enlist`が最も読みやすいのでこれを使おう。

```
q)a:42
q)(),a
,42
q)a,()
,42
q)1#a
,42
q)enlist a
,42
```

参考：

[q4m3](https://code.kx.com/q4m3/3_Lists/#351-joining-with) Tip: To ensure that a q entity becomes a list, use either `(),x` or `x,()`. This leaves a list unchanged but effectively enlists an atom. Such a seemingly trivial expression is actually useful and is our first example of a q idiom. You cannot use `enlist x` for the same purpose. Why not?

Q Tipsは`1#a`をよく使っていますが、q4m3に従うことにします。

## 辞書のキーはユニークになるようにしよう

q言語の辞書はリスト2つから構成されているため、同じキーを複数持ってしまうことができてしまう。

```
q)d:(`hoge;`hoge)!(10 20)
q)d
hoge| 10
hoge| 20
```

が、このような辞書は作らないように気を付けよう（いろいろな演算が未定義動作）。

参考：

Q Tip 7.1 Ensure dictionary keys are unique

## テーブルでジェネリック型の列を扱う技法について知ろう

１つの列にいろいろな型の要素を持たせたいことがある。
次の例ではQ TipsのCEPエンジンでのイベントテーブルを作ろうとしている。
`meta`を実行することで`func`列がジェネリックであることが確認できる

```
q)timer.job:([] name:`symbol$();func:();time:`timestamp$())
q)show timer.job
name func time
--------------
q)meta timer.job
c   | t f a
----| -----
name| s
func|
time| p
```

しかしながら、安直に行を追加すると、`func`列は型付きリスト（simple list）になってしまう。

```
q)meta timer.job upsert (`;`;.z.P)
c   | t f a
----| -----
name| s
func| s
time| p
```

これを回避するためには最初の要素としてジェネリックな空リストを入れておけばよい。
そうすれば、`func`列の全要素が同じ型になることがないため、ジェネリックリストであることを保つことができる。

```
q)`timer.job upsert (`;();0Wp)
`timer.job
q)`timer.job upsert (`;`;.z.P)
`timer.job
q)show timer.job
name func time
---------------------------------------
     ()   0W
     `    2019.05.12D05:37:35.894148000
q)meta timer.job
c   | t f a
----| -----
name| s
func|
time| p
```

参考：

Q Tip 10.1 Insert an empty row to prevent untyped columns from collapsing


# 関数

## 関数の各行はセミコロンで終わるようにしよう

セミコロンを忘れるのはq言語の一般的な間違いである。
スクリプトで関数を複数行で書くときには、最初の行（関数名と仮引数名を書く）と最後の行（戻り値を書く）を除いてセミコロンで終わるようにしよう。

また、途中で戻り値を戻すときも

```
 if[not count x;:x];
```

のように、１行の`if`ステートメントの中で（改行せずに）行うことにしよう。


参考：

Q Tip 4.6 Make sure each line in a function ends with a semicolon

## 関数の最後の行は戻り値変数と閉じカッコ（`}`）を使おう。

関数の最後の行は戻り値変数と閉じカッコ（`}`）だけにすることが、関数のドキュメントとして望ましい（可読性が高い）。

```
 }
```

のように関数の最後の行が閉じカッコ（`}`）のみであるのは、戻り値がnull（generic null）であることを意味する。

## 関数の部分適用は明示的に行おう

多変数関数の部分適用を行う際、末尾のセミコロンは省略することができる（先頭から部分適用される）。

```
q)f:{x+y+z}
q)g:f[42]
q)g[1;2]
45
```

しかし、これは読みにくいので、明示的に

```
q)g:f[42;;]
q)g[1;2]
45
```

と書こう。

参考：

[q4m3](https://code.kx.com/q4m3/6_Functions/#641-function-projection) We recommend that you do not omit trailing semi-colons in projections, as this can obscure the intent of code.

[Reference](https://code.kx.com/v2/basics/application/#projection) Make projections explicit

Q Tipsは普通に省略していますが、q4m3に従うことにします。


# 効率

## 実体がコピーされるときを知ろう

q言語は（C++同様に）値のセマンティクスを持つ言語であり、セマンティクスとしてはコピーは深いコピーである。

```
q)L1:10 20 30
q)L2:L1 / 深いコピー（と思ってよい）
q)L2[0]:100 / L2を書き換える
q)show L1 / L1は変わらないことを見る
10 20 30
q)show L2
100 20 30
```

しかしながら、q言語では必要があるまでは実際に実体がコピーされることはなく、書き換え時にコピーされる（Copy-On-Write）。
内部関数`-16!`を使うことで変数の参照カウントをみることができるので、これを使って挙動を確認してみる。

```
q)L1:10 20 30
q)-16!L1
1i
q)L2:L1
q)-16!L1 / L2と実体を共有しているので参照カウントは2
2i
q)L2[0]:100 / 書き換え時に実体がコピーされ、別物になる。
q)-16!L1 / L2と実体を共有していないので参照カウントは1
1i
```

リストから辞書やテーブルを作るとき、テーブルからq-sqlでデータを抽出するときなども同様である。
つまり、データを書き換えるまで、実体がコピーされるわけではない。

## テーブルから行を削除するよりフラグを使おう

q言語のテーブルは行方向がメモリ上連続であること保つため、行削除は非常に重たい処理である。
真に行を削除する必要がなければ、ブール値のフラグを立てることで代用しよう。

参考：

Q Tip 12.1 Use boolean flags instead of deleting rows

## テーブルの不要な列は削除しよう

列削除はどんどんやってよい。
不要な列を削除すると、その後のクエリが速くなるかもしれない。

参考：

Q Tip 17.2 Delete unused columns before adding new ones


# q-sql

## insertよりupsertを使おう

そのまま。

参考：

[q4m3](https://code.kx.com/q4m3/9_Queries_q-sql/#91-inserting-records) Tip: The upsert function is superior to insert and is to be preferred. We include insert for nostalgia only.

## `where`句の最初に判定が速いもの、制限的なものを書こう

`where`句では、コンマ区切りで複数条件を書け、短絡評価される。
従って、最初の（左側の）条件に判定が速いものや制限的なものを書こう。

```
q)dts:.util.rng[1;2000.01.01;2005.01.01]
q)t:raze .sim.genp[;100;.3;.03;dts] each til 10
q)select from t where id=1,date.month = 2000.02m
id date       price
----------------------
1  2000.02.01 109.0513
1  2000.02.02 109.657
1  2000.02.03 112.1111
1  2000.02.04 115.0771
1  2000.02.05 115.0505
1  2000.02.06 116.454
1  2000.02.07 116.5213
1  2000.02.08 119.8954
1  2000.02.09 118.2443
1  2000.02.10 121.9608
1  2000.02.11 121.6705
1  2000.02.12 121.1099
1  2000.02.13 120.5877
1  2000.02.14 122.7702
1  2000.02.15 120.9654
1  2000.02.16 120.4115
1  2000.02.17 121.0173
1  2000.02.18 121.5537
1  2000.02.19 121.7538
1  2000.02.20 118.0143
..
```

注意点として、q言語の`and`（`&`）は短絡評価でない。
なので、

```
q)select from t where (id=1) and date.month = 2000.02m
```

と書くと効率が落ちる。

参考：

Q Tip 14.2 Apply the fastest and most restrictive where clauses first

