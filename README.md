# z80oolong/tts -- 各種オープンソース音声合成アプリケーション等を導入するための Formula 群

## 告知 (2026-06-30)

Homebrew がバージョン 6.0.0 に更新されたことに伴い、セキュリティ対策が強化されました。**これにより、サードパーティの Tap リポジトリを導入する際には、明示的に信頼を設定する必要があります。**

本 Tap リポジトリをご利用の際は、以下の手順に従ってください。

```
  $ brew tap z80oolong/tmux
  $ brew trust z80oolong/tmux
```

その後、通常通り Formula のインストールを行えます。

```
  $ brew install <formula>
```

詳細は `brew trust --help` コマンドまたは Homebrew 公式ドキュメントを参照してください。

## 概要

[Homebrew for Linux][BREW] は、Linux ディストリビューションにおけるソースコードベースのパッケージ管理システムです。これにより、ソフトウェアのソースコードからのビルドおよびインストールを簡単かつ効率的に行えます。

[VOICEVOX][VVOX] は、無料で利用できる中品質なテキスト読み上げ・歌声合成ソフトウェアです。詳細については [VOICEVOX 公式ページ][VVOX] を参照してください。

本 Tap リポジトリは、[VOICEVOX][VVOX] をはじめ、各種オープンソースの音声合成アプリケーションおよびこれに対応する音源ライブラリ等を [Homebrew for Linux][BREW] に導入するためのものです。

## 使用方法

[Homebrew for Linux][BREW] を端末にインストールします。以下のリソースを参考にしてください：

- [thermes 氏][THER] による「[Linuxbrew のススメ][THBR]」
- [Homebrew for Linux 公式ページ][BREW]

本リポジトリの Formula を以下のようにインストールします：

```
  $ brew tap z80oolong/tts
  $ brew trust z80oolong/tts
  $ brew install <formula>
```

または、一時的な方法として、以下のように URL を直接指定してインストール可能です：

```
  $ brew install https://raw.githubusercontent.com/z80oolong/homebrew-tts/master/Formula/<formula>.rb
```

利用可能な Formula の一覧および詳細は、本リポジトリに同梱の `FormulaList.md` を参照してください。

## 詳細情報

本リポジトリおよび [Homebrew for Linux][BREW] の使用方法の詳細は、以下のコマンドやリソースを参照してください：

- `brew help` コマンド
- `man brew` コマンド
- [Homebrew for Linux 公式ページ][BREW]

## 謝辞

[VOICEVOX][VVOX] の開発者である hiroshiba 氏に心より感謝申し上げます。

また、[VOICEVOX][VVOX] およびその他音声合成アプリケーション等の開発者および開発コミュニティ各位に深く感謝いたします。

さらに、[VOICEVOX][VVOX] 及びその他音声合成アプリケーションに関わる全ての皆さまに心より感謝申し上げます。

## 使用条件

本リポジトリは、[Homebrew for Linux][BREW] の Tap リポジトリとして、[Homebrew for Linux 開発コミュニティ][BREW] および [Z.OOL.][ZOOL] が著作権を有し、[BSD 2-Clause License][BSD2] に基づいて配布されます。詳細は、本リポジトリに同梱の ```LICENSE``` ファイルを参照してください。

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[VVOX]:https://voicevox.hiroshiba.jp/
[THER]:https://qiita.com/thermes
[THBR]:https://qiita.com/thermes/items/926b478ff6e3758ecfea
[BSD2]:https://opensource.org/licenses/BSD-2-Clause
[ZOOL]:http://zool.jpn.org/
