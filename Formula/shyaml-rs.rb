class ShyamlRs < Formula
  desc "Command-line tool for working with YAML files"
  homepage "https://github.com/0k/shyaml-rs"
  # Crate: https://crates.io/crates/shyaml-rs
  url "https://static.crates.io/crates/shyaml-rs/shyaml-rs-0.3.4.crate"
  # version is automatically extracted from the url
  sha256 "debc2be8ac7da2cc6cf749ad1231ea151476b635ef55e93eafea3acbb2892dc8"
  license "MIT"
  revision 1

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/shyaml-rs-0.3.4_1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "6c09c383d407123713fbfa0ca02cd8a1da1e095579ee22177be9b8c4837c3517"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "91f0d20ece9558734df9dafa2618c2cfe50b1292135f6255b3a052e5c76b4bbc"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9879a7c8b3629cf3de01b50bd35106a1047e794644d55f1633f8b0a58ae33f53"
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
