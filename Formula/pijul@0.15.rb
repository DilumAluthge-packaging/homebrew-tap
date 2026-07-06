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
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul@0.15-0.15.0_2"
    sha256 cellar: :any, arm64_tahoe:   "e780a25a1a9a474d6ea92633efe7b82d367462744c7f66f0c6d1b1300bc9a3c4"
    sha256 cellar: :any, arm64_sequoia: "3d569f500e58b714c55e3c33a351ad092a497f31f6d7c83b8541582bf3eedcc1"
    sha256 cellar: :any, arm64_sonoma:  "396a834cc32d2d29be92c26c14caf65d2a35344bfb9d9386b18bdd3b56660d15"
    sha256 cellar: :any, x86_64_linux:  "81e81ded119382cb51c4ec8bde6167b0c4ba928536fe5d152cc6259a314331fc"
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
