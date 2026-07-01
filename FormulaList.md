# z80oolong/tts に含まれる Formula 一覧

## 概要

本文書では、 [Homebrew for Linux][BREW] 向け Tap リポジトリ ```z80oolong/tts``` に含まれる Formula 一覧を示します。各 Formula の詳細については、 ```brew info <formula>``` コマンドをご覧ください。

## Formula 一覧

### z80oolong/tts/voicevox-core

この Formula は、 [VOICEVOX CORE][VCOR] をソースコードからビルドし、ライブラリとしてインストールします。

[VOICEVOX CORE][VCOR] の各種ライブラリ等は以下のディレクトリにインストールされます。（ここに、 ```$HOMEBREW_PREFIX``` は [Homebrew for Linux][BREW] のインストール先のプレフィックスディレクトリを、 ```VERSION``` は [VOICEVOX CORE][VCOR] のバージョン番号を示します。）

- [VOICEVOX CORE][VCOR] 本体の動的ライブラリ … ```$HOMEBREW_PREFIX/opt/voicevox-core/lib/libvoicevox_core.so{, .VERSION}```
- VOICEVOX 専用の ONNX Runtime … ```$HOMEBREW_PREFIX/opt/voicevox-core/lib/voicevox/libonnxruntime.so{, .VERSION}```
- VOICEVOX で使用する OpenJTalk 辞書のディレクトリ … ```$HOMEBREW_PREFIX/opt/voicevox-core/share/dic```
- VOICEVOX の動作確認用のサンプル VVM … ```$HOMEBREW_PREFIX/opt/voicevox-core/share/models```

また、同時に [VOICEVOX CORE][VCOR] の簡易な動作確認用の CLI である ```voicevox-core-cli``` 及び Python で書かれた動作確認用の CLI である ```voicevox-core-pycli``` も ```$HOMEBREW_PREFIX/opt/voicevox-core/bin``` にインストールされます。使用方法は ```voicevox-core-cli -h``` 及び ```voicevox-core-pycli -h``` を参照してください。

- **注意**:
    - **この Formula によってインストールされる [VOICEVOX CORE][VCOR] は GPU に未対応です。** CPU のみでの動作となります。

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[VCOR]:https://github.com/VOICEVOX/voicevox_core
