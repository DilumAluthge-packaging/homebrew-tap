class ShyamlRs < Formula
  desc "Command-line tool for working with YAML files"
  homepage "https://github.com/0k/shyaml-rs"
  # Crate: https://crates.io/crates/shyaml-rs
  url "https://static.crates.io/crates/shyaml-rs/shyaml-rs-0.3.3.crate"
  # version is automatically extracted from the url
  sha256 "bfc4e887290afb007b52533e0634c35dd239a430e52924f94158eea90f522633"
  license "MIT"
  # revision 0

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/shyaml-rs-0.3.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "b87c5d7a9610b6ba8ae91316c6135f810633d64aca05b42c45b7db2d2a77ad9e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0b6f59fa9ce37f8d37b966f05c8385d5fb3abf05c6f55594dc51e18e25a970be"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4b267b74fc5ad66ca71a16549fd1f3e4478873d76b31ef12d20de0ba2a017dc4"
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
