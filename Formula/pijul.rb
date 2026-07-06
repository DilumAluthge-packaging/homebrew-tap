# The pijul formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License for the formula code in `Homebrew/homebrew-core`: BSD (that's not the license for the Pijul software itself)

require_relative "../Library/FormulaHelpers/pijul_test"

class Pijul < Formula
  include PijulTest

  desc "Patch-based distributed version control system"
  # Web page: https://pijul.org
  # Crate: https://crates.io/crates/pijul
  homepage "https://docs.rs/crate/pijul"
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.17.crate"
  # version is automatically extracted from the url
  sha256 "81e9a6685477a853d0025b0ecc174848b449b7f5f527c1520ce0a1da76732b73"
  license "GPL-2.0"
  revision 2

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul-1.0.0-beta.17_1"
    sha256 cellar: :any, arm64_tahoe:   "cbc29f739478a46760170283a5d45853764fa42af6e7b437ad9a140b4b3019f4"
    sha256 cellar: :any, arm64_sequoia: "4f08ab5df00295198eba90b1c671c7b5eddff13fba3a59acb39760c47b5bdb8e"
    sha256 cellar: :any, arm64_sonoma:  "9b15994a9b7f555acd69276c2536930aa19283635ed0e605e8c292730bf366e5"
    sha256 cellar: :any, x86_64_linux:  "6a7967ec579994fcf488387ac4765872945b3fdb49f1b2727db34088fc0400fd"
  end

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
