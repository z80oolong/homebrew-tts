class VoicevoxCore < Formula
  include Language::Python::Virtualenv

  desc "Free, medium-quality text-to-speech software (CPU version, CORE Program)"
  homepage "https://github.com/VOICEVOX/voicevox_core"
  url "https://github.com/VOICEVOX/voicevox_core/archive/refs/tags/0.16.4.tar.gz"
  sha256 "2f69e4a34f3375d598b168201289536525c8bce6f0fa8c98dbee5d31979a6ca9"
  license "MIT"

  # --- Version of ONNX Runtime, OpenJTalk Dictionary, etc. ---
  VERSION_ONNX_RUNTIME  = "1.17.3".freeze
  VERSION_OPENJTALK_DIC = "1.11".freeze
  REVISION_VOICE_CORE_CLI = "93bd64ffeb0043ca0997a82c4f859c7fdbf4ca40".freeze

  # --- Build dependencies ---
  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "maturin" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.12" => :build
  depends_on "rust" => :build
  depends_on "mecab"
  depends_on "openssl@3"

  # --- Resource: VOICEVOX-specific ONNX Runtime ---
  resource "voicevox_onnxruntime" do
    url "https://github.com/VOICEVOX/onnxruntime-builder/releases/download/" \
        "voicevox_onnxruntime-#{VERSION_ONNX_RUNTIME}/voicevox_onnxruntime-linux-x64-#{VERSION_ONNX_RUNTIME}.tgz"
    sha256 "72b5287fdd48dc833a9929f6e9e3826e793b54ce1202181be93f63823a222f58"
  end

  # --- Resource: Open JTalk UTF-8 dictionary (fixed version) ---
  resource "open_jtalk_dic_utf_8" do
    url "https://downloads.sourceforge.net/open-jtalk/open_jtalk_dic_utf_8-#{VERSION_OPENJTALK_DIC}.tar.gz"
    sha256 "33e9cd251bc41aa2bd7ca36f57abbf61eae3543ca25ca892ae345e394cb10549"
  end

  # --- Resource: voicevox-core-cli.c, etc. ---
  resource "voicevox_core_cli" do
    url "https://gist.github.com/f95f5e98cd4874bd6f7173f03cdf6fce.git", revision: REVISION_VOICE_CORE_CLI
  end

  def install
    # --- Extract VOICEVOX-specific ONNX Runtime ---
    resource("voicevox_onnxruntime").stage do
      v = VERSION_ONNX_RUNTIME
      # --- Install libvoicevox_onnxruntime.so.{VER} -> lib/voicevox/libonnxruntime.so{,VER}
      ohai "Install ./lib/libvoicevox_onnxruntime.so.#{v} => #{lib}/voicevox/libonnxruntime.so{,.#{v}}"
      (lib/"voicevox").install "./lib/libvoicevox_onnxruntime.so.#{v}" => "libonnxruntime.so.#{v}"
      (lib/"voicevox").install_symlink "libonnxruntime.so.#{v}" => "libonnxruntime.so"

      # --- Install Link lib/voicevox/onnxruntime.so.{VER} -> lib/libvoicevox_libonnxruntime.so{,VER}
      ohai "Install Link #{lib}/voicevox/libonnxruntime.so.#{v} => #{lib}/libvoicevox_libonnxruntime.so{,.#{v}}"
      lib.install_symlink "voicevox/libonnxruntime.so.#{v}" => "libvoicevox_onnxruntime.so.#{v}"
      lib.install_symlink "voicevox/libonnxruntime.so.#{v}" => "libvoicevox_onnxruntime.so"

      # --- Copy lib/voicevox/libonnxruntime.so.{VER} -> #{buildpath}/target/debug/libonnxruntime.so.{VER}
      (buildpath/"target/debug").mkpath
      ohai "Copy #{lib}/voicevox/libonnxruntime.so.#{v} => #{buildpath}/target/debug/libonnxruntime.so.#{v}"
      cp lib/"voicevox/libonnxruntime.so.#{v}", buildpath/"target/debug/libonnxruntime.so.#{v}"
    end

    # --- Extract OpenJTalk dictionary ---
    resource("open_jtalk_dic_utf_8").stage do
      ohai "Install open_jtalk_utf_8-#{VERSION_OPENJTALK_DIC}/* => #{share}/voicevox/dic/*"
      (share/"voicevox/dic").install Dir["*"]
    end

    # --- Cargo build ---
    ENV["LLVM_SYS_150_PREFIX"] = Formula["llvm"].opt_prefix
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix

    cargo_args =  ["build", "--release"]
    cargo_args << "-p" << "voicevox_core_c_api"
    cargo_args << "-p" << "voicevox_core_python_api"
    cargo_args << "-p" << "voicevox_core_java_api"
    cargo_args << "-p" << "test_util"
    cargo_args << "-p" << "voicevox_core"
    cargo_args << "-p" << "voicevox_core_macros"
    cargo_args << "-p" << "xtask"
    cargo_args << "--features" << "load-onnxruntime"

    system "cargo", *cargo_args

    # --- Build & Install Python API ---
    Dir.chdir("#{buildpath}/crates/voicevox_core_python_api") do
      system "#{Formula["maturin"].opt_bin}/maturin", "build", "--release"

      (buildpath/"target/wheels").glob("*.whl") do |whl|
        # --- Rename voicevox-core-0.0.0-*.whl => voicevox-core-{ver}-*.whl
        dstwhl = whl.basename.to_s.gsub("-0.0.0-", "-#{version}-")
        ohai "Install #{whl} => #{share}/voicevox/wheels/#{dstwhl}"
        (share/"voicevox/wheels").install whl => dstwhl
      end

      venv = virtualenv_create(libexec, "python3.12")
      (share/"voicevox/wheels").glob("*.whl") { |whl| venv.pip_install whl }
    end

    # --- Install C API Library ---
    lib.install buildpath/"target/release/libvoicevox_core.so" => "libvoicevox_core.so.#{version}"
    lib.install_symlink "libvoicevox_core.so.#{version}" => "libvoicevox_core.so"

    # --- Install C API Header ---
    voicevox_core_h = buildpath/"crates/voicevox_core_c_api/include/voicevox_core.h"
    inreplace voicevox_core_h, %r{^//#define VOICEVOX_LOAD_ONNXRUNTIME}, "#define VOICEVOX_LOAD_ONNXRUNTIME"
    include.install voicevox_core_h

    # --- Install generated sample.vvm ---
    sample_vvm_path = buildpath/"crates/test_util/data/model/sample.vvm"
    (share/"voicevox/models").install sample_vvm_path if sample_vvm_path.exist?

    # ---Build VOICEVOX CORE C & Python API CLI, etc. ---
    resource("voicevox_core_cli").stage do
      system ENV.cc, "-o", "./voicevox-core-cli",
        "./voicevox-core-cli.c", "-I#{include}", "-L#{lib}", "-lvoicevox_core", "-ldl"
      bin.install "./voicevox-core-cli"

      (libexec/"bin").install "./voicevox-core-cli.py"
      (bin/"voicevox-core-pycli").write <<~EOS
        #!/bin/bash
        set -euo pipefail
        exec #{libexec}/bin/python #{libexec}/bin/voicevox-core-cli.py "$@"
      EOS

      inreplace "./voicevox_core.pc.in", /@prefix@/, prefix.to_s
      (lib/"pkgconfig").install "./voicevox_core.pc.in" => "voicevox_core.pc"
    end
  end

  def caveats
    <<~EOS
      VOICEVOX Core #{version} has been installed.

      Bundled components:
        - VOICEVOX-specific ONNX Runtime
        - Open JTalk UTF-8 dictionary (fixed version)
        - sample.vvm (generated during build)
        - VOICEVOX CORE C API CLI
        - VOICEVOX CORE Python API CLI

      Installed paths:
        Library:
          #{opt_lib}/libvoicevox_core.so
          #{opt_lib}/libvoicevox_core.so.#{version}

        ONNX Runtime:
          #{opt_lib}/voicevox/libonnxruntime.so
          #{opt_lib}/voicevox/libonnxruntime.so.#{VERSION_ONNX_RUNTIME}
          #{opt_lib}/libvoicevox_onnxruntime.so
          #{opt_lib}/libvoicevox_onnxruntime.so.#{VERSION_ONNX_RUNTIME}

        Header:
          #{opt_include}/voicevox_core.h

        Dictionary:
          #{opt_share}/voicevox/dic

        Models:
          #{opt_share}/voicevox/models

        Python API Wheels:
          #{opt_share}/voicevox/wheels/*.whl

        VOICEVOX CORE C API CLI:
          #{opt_bin}/voicevox-core-cli

        VOICEVOX CORE Python API CLI:
          #{opt_bin}/voicevox-core-pycli

      Note:
        Full VVM voice models are NOT included.
        Please download them separately.
    EOS
  end

  test do
    assert_path_exists lib/"libvoicevox_core.so"

    system "#{bin}/voicevox-core-cli", "-o", "#{testpath}/hello_c.wav", "'こんにちは。テストです。'"
    assert_path_exists testpath/"hello_c.wav"
    ohai "Remove #{testpath}/hello_c.wav"
    rm testpath/"hello_c.wav"

    system "#{bin}/voicevox-core-pycli", "-o", "#{testpath}/hello_py.wav", "'こんにちは。テストです。'"
    assert_path_exists testpath/"hello_py.wav"
    ohai "Remove #{testpath}/hello_py.wav"
    rm testpath/"hello_py.wav"
  end
end
