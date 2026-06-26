class ShyamlRs < Formula
  desc "Command-line tool for working with YAML files"
  homepage "https://github.com/0k/shyaml-rs"
  # Crate: https://crates.io/crates/shyaml-rs
  url "https://static.crates.io/crates/shyaml-rs/shyaml-rs-0.3.2.crate"
  # version is automatically extracted from the url
  sha256 "46dbc216a9b92b5d82412ffa9114109f4500c8c02e4330588800d0edba264686"
  license "MIT"
  revision 3

  bottle do
    root_url "https://github.com/DilumAluthge/homebrew-tap/releases/download/shyaml-rs-0.3.2_3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8c4fe8256f938e0e065f306ea2d28997ba5a35ba19635b538d8bd219e74e81cf"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "b8c542685def9b379a7c7a1f234872b092625a5798415210f6cbd5865401ac87"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "adeba9afca3b57784ebad09752797faee924cd70ade12e4366ac9e0b3dbfcd0c"
    sha256 cellar: :any,                 x86_64_linux:  "07d5b1c03266e8ac46edd71d3660f7e4b288db49c80c61ad1feae3a6e311c41e"
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
