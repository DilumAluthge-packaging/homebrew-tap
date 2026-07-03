class ShyamlRs < Formula
  desc "Command-line tool for working with YAML files"
  homepage "https://github.com/0k/shyaml-rs"
  # Crate: https://crates.io/crates/shyaml-rs
  url "https://static.crates.io/crates/shyaml-rs/shyaml-rs-0.3.3.crate"
  # version is automatically extracted from the url
  sha256 "bfc4e887290afb007b52533e0634c35dd239a430e52924f94158eea90f522633"
  license "MIT"
  revision 2

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/shyaml-rs-0.3.3_2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "277baaf0678d0e55b95fd51699049bdd8c4ca9072706901cdbd554bd2deb89a0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0a3ee8ad146dc20da1917f7b89b686b62875390b0d344364617e1be229be3f2b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9840ef510d67542ac88c9ce5da09f1e600184cdec68b58464fa85dd0092892dc"
  end

  depends_on "rust" => :build

  # For now, mark this formula as macOS-only
  # (because the Linux build is currently broken - 0.3.2 was fine, but 0.3.3 is broken)
  # TODO: Start building Linux bottles again, once the Linux build has been fixed upstream
  depends_on :macos

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
