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
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul-1.0.0-beta.17_2"
    sha256 cellar: :any, arm64_tahoe:   "53de32036611c4c4ad9dd670e27affe9b43d70e46c61fdad267bc2384b737acc"
    sha256 cellar: :any, arm64_sequoia: "cd16cb69690d6551eabe92be1d0d60b96d5631d5e0b6b10d9379d4599d51ccff"
    sha256 cellar: :any, arm64_sonoma:  "ec128885df6137a00c2831f169e4e3e6b262a46b77ab9ebf33f6ced524027606"
    sha256 cellar: :any, x86_64_linux:  "11c36677f4630103a1d009b463059d7e8675ca38b812c62b41ec78dd76075a32"
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
