class ShyamlRs < Formula
  desc "Command-line tool for working with YAML files"
  homepage "https://github.com/0k/shyaml-rs"
  # Crate: https://crates.io/crates/shyaml-rs
  url "https://static.crates.io/crates/shyaml-rs/shyaml-rs-0.3.2.crate"
  # version is automatically extracted from the url
  sha256 "46dbc216a9b92b5d82412ffa9114109f4500c8c02e4330588800d0edba264686"
  license "MIT"
  revision 2

  bottle do
    root_url "https://github.com/DilumAluthge/homebrew-tap/releases/download/shyaml-rs-0.3.2_2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "1e56bba7015b0815ad28765bea429a9c64add4701589268b4d49e3404718880e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c4c22b16098204deae736e2debf6b3b90cf168f923bcd78bc41f9dcc8b9ecc8c"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d29f3270cbf64227a71ae9f30f11efe2f3c6bf44d8289d7668c54fbe9310bbdd"
    sha256 cellar: :any,                 x86_64_linux:  "496ab9e9f8dd7ed42d69c9fe075b0860bb8c23f1658f93fff4a2ac14c609da9c"
  end

  depends_on "rust" => :build
  depends_on "openssl@3"

  conflicts_with "shyaml", because: "both install `shyaml` binaries"

  def install
    # Ensure that the `openssl` crate picks up the desired library
    # https://docs.rs/openssl/0.10.75/openssl/#manual
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix

    # Build shyaml-rs from source, and install it into the prefix
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    system bin/"shyaml", "--version"

    str = '{foo: "Hello", bar: "World", baz: "Goodbye"}'
    assert_equal "World", pipe_output("#{bin}/shyaml get-value bar", str)
  end
end
