# The pijul formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License: BSD

class Pijul < Formula
  desc "Patch-based distributed version control system"
  homepage "https://pijul.org"
  # Crate: https://crates.io/crates/pijul
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.12.crate"
  # version is automatically extracted from the url
  sha256 "cede03df443e55f8c47c7f213a67c37f8f8d7ceeff3578e9ba9a1e0df63191e2"
  license "GPL-2.0"
  # revision 1

  bottle do
    root_url "https://github.com/DilumAluthge/homebrew-tap/releases/download/pijul-1.0.0-beta.12"
    sha256 cellar: :any, arm64_tahoe:   "feeb4c65c50bf754cbdb1759859bacd0c346e6f4e6583568d11cae332dd6c11a"
    sha256 cellar: :any, arm64_sequoia: "6606b57d80bc45a3b737befc51581f6cb03f37e51a07cb9a9d2d5751e3aa9f9d"
    sha256 cellar: :any, arm64_sonoma:  "38ea51a6fbbf7bc258fc2a0b9b3d144fc60eb8a1c22ef4c8c9020c925bbfee77"
    sha256 cellar: :any, x86_64_linux:  "5d4dc425e12d48fdbc9f6de7a61abba7b22e45db1d71eb19094d224b127f15b3"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libsodium"
  depends_on "openssl@3"

  on_linux do
    depends_on "dbus"
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    # https://docs.rs/openssl/0.10.75/openssl/#manual
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix

    # Build pijul, and install it into the Homebrew prefix:
    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    system bin/"pijul", "--no-prompt", "init"
    %w[haunted house].each { |f| touch testpath/f }
    assert_equal "No tracked files\n", shell_output("#{bin}/pijul ls")
    system bin/"pijul", "--no-prompt", "add", "haunted", "house"
    # pijul identity new --no-link --no-prompt --display-name 'Test User' --email 'noreply@example.com'
    # pijul --no-prompt record --all --message='Initial patch' --author='Test User <noreply@example.com>'
    assert_equal "haunted\nhouse\n", shell_output("#{bin}/pijul ls")
  end
end
