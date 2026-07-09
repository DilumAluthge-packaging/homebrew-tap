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
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.18.crate"
  # version is automatically extracted from the url
  sha256 "0500d14ab41adea4f0d71f03b9d1be895a0638e025204f5b6ab90e46c40684ff"
  license "GPL-2.0"
  # revision 0

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul-1.0.0-beta.18"
    sha256 cellar: :any, arm64_tahoe:   "bfdd8d493fa906dd059839a5994605e69d49b8cf6d35cb348710eac74902251a"
    sha256 cellar: :any, arm64_sequoia: "be495b71febfd30a5fc22241f12da1da9a671bfab7e1911ae8d0d0e814c2b0d8"
    sha256 cellar: :any, arm64_sonoma:  "fd2d1f8db2e503d992ef23ed8c8d787b1c24d29f68c3c529b198962295934b5b"
    sha256 cellar: :any, x86_64_linux:  "8840b6f81157be1f5cd658f2e103e0666a6f8d76552e8913f3544c7603526e22"
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
