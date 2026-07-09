# The pijul formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License for the formula code in `Homebrew/homebrew-core`: BSD (that's not the license for the Pijul software itself)

require_relative "../Library/FormulaHelpers/pijul_test"

class PijulAT015 < Formula
  include PijulTest

  desc "Patch-based distributed version control system"
  # Web page: https://pijul.org
  # Crate: https://crates.io/crates/pijul
  homepage "https://docs.rs/crate/pijul"
  url "https://static.crates.io/crates/pijul/pijul-0.15.0.crate"
  # version is automatically extracted from the url
  sha256 "51d7b44e03f2c428fea010318fea041fae3a1b9a6946aa79cf8c152707959157"
  license "GPL-2.0-or-later"
  revision 3

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul@0.15-0.15.0_3"
    sha256 cellar: :any, arm64_tahoe:   "1df2d14f9512466b75dbf1c5121a5ef3357295a38bb1feebda0b0b2acde7e1df"
    sha256 cellar: :any, arm64_sequoia: "e2ee775eb32d50ed959432a05b3b5d0b049ea88292807a7939f2c7da3356fcdb"
    sha256 cellar: :any, arm64_sonoma:  "f31bc1684200bd9eeabb7b623b8d71ae103c9d358a30c67c88bbf3009d29f318"
    sha256 cellar: :any, x86_64_linux:  "e83995d29fd4c1cb5ad9127e3ea88cee257c70538c3e1c621f37c98dbdcc8f2e"
  end

  # We have to mark this as keg-only, to avoid clashing with the main `pijul` formula
  keg_only :versioned_formula

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libsodium"
  depends_on "openssl@3"

  on_linux do
    depends_on "openssh" => :test
    depends_on "dbus"
    depends_on "zlib"
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    # https://docs.rs/openssl/0.10.75/openssl/#manual
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@3")

    # Build pijul, and install it into the Homebrew prefix:
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    run_pijul_tests
  end
end
