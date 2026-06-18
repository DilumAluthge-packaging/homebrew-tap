# The pijul formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License: BSD

class Pijul < Formula
  desc "Patch-based distributed version control system"
  homepage "https://pijul.org"
  # Crate: https://crates.io/crates/pijul
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.13.crate"
  # version is automatically extracted from the url
  sha256 "d5f8e59409b31bfa76a3b45c0e076f5852a4eb6b3134497b9a902927bdd6f9bf"
  license "GPL-2.0"
  # revision 1

  bottle do
    root_url "https://github.com/DilumAluthge/homebrew-tap/releases/download/pijul-1.0.0-beta.13"
    sha256 cellar: :any, arm64_tahoe:   "ff9b2eb52af5df39a88735ab7f8803e2bb6f374252e7ea822dd6ad050fcfcd69"
    sha256 cellar: :any, arm64_sequoia: "ad14afacae2370639fc495d9182b375a296885a65af4f033ab0a54cd80528bea"
    sha256 cellar: :any, arm64_sonoma:  "cc8f32b807d1af2147d7f0ab578aa397fe29c0910a1845785a5081622d43ee43"
    sha256 cellar: :any, x86_64_linux:  "0d59d52c5602931d626f7524ffceca4356cceebe94fc3c8c3c3ad67856c4f889"
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
    assert_equal "haunted\nhouse\n", shell_output("#{bin}/pijul ls")
    system bin/"pijul", "identity", "new",
           "--no-link", "--no-prompt",
           "--display-name", "Test User",
           "--email", "noreply@example.com"
    system bin/"pijul", "--no-prompt", "record", "--all",
           "--message='Initial patch'",
           "--author='Test User <noreply@example.com>'"
    assert_equal "haunted\nhouse\n", shell_output("#{bin}/pijul ls")
  end
end
