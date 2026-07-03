class ShyamlRs < Formula
  desc "Command-line tool for working with YAML files"
  homepage "https://github.com/0k/shyaml-rs"
  # Crate: https://crates.io/crates/shyaml-rs
  url "https://static.crates.io/crates/shyaml-rs/shyaml-rs-0.3.3.crate"
  # version is automatically extracted from the url
  sha256 "bfc4e887290afb007b52533e0634c35dd239a430e52924f94158eea90f522633"
  license "MIT"
  revision 1

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/shyaml-rs-0.3.3_1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "bd6c6cb0435ae1451898aaacdea5fd085d1a6914a6fbb172c41702bdb86b80d4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c7e55bd0fe2e014f78f0dc6f12acd756a462e4f3223152b4abf4aa54402c9e1b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4f18ef1505ead359a2b9ad6af1f7a291372f8153a2671061d9023dca23c227c8"
  end

  depends_on "rust" => :build
  depends_on "openssl@3"

  # For now, mark this formula as macOS-only (because the Linux build is currently broken - 0.3.2 was fine, but 0.3.3 is broken)
  # TODO: Start building Linux bottles again, once the Linux build has been fixed upstream
  depends_on :macos

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
