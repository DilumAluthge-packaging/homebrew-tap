class ShyamlRs < Formula
  desc "Command-line tool for working with YAML files"
  homepage "https://github.com/0k/shyaml-rs"
  # Crate: https://crates.io/crates/shyaml-rs
  url "https://static.crates.io/crates/shyaml-rs/shyaml-rs-0.3.4.crate"
  # version is automatically extracted from the url
  sha256 "debc2be8ac7da2cc6cf749ad1231ea151476b635ef55e93eafea3acbb2892dc8"
  license "MIT"
  # revision 0

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/shyaml-rs-0.3.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "cd8c622986835de22404a0326f9c1702700da8228d5d206344ce1b4a19cea253"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "30b5b3eb69e431fe3949ad9cec883788f22d1d07f715387e9ab7d06a944fdcc9"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e16c45a6ea26c318f6fd0db3afe911db2e13bb0175bdde8aa61f556aeb83d439"
  end

  depends_on "rust" => :build
  depends_on "openssl@3"

  conflicts_with "shyaml", because: "both install `shyaml` binaries"

  def install
    # Ensure that the `openssl` crate picks up the desired library
    # https://docs.rs/openssl/0.10.75/openssl/#manual
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@3")

    # Build shyaml-rs from source, and install it into the prefix
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    system bin/"shyaml", "--version"

    str = '{foo: "Hello", bar: "World", baz: "Goodbye"}'
    assert_equal "World", pipe_output("#{bin}/shyaml get-value bar", str)
  end
end
