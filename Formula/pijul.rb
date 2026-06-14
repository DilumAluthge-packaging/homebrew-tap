# The pijul formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License: BSD

class Pijul < Formula
  desc "Patch-based distributed version control system"
  homepage "https://pijul.org"
  # Crate: https://crates.io/crates/pijul
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.11.crate"
  # version is automatically extracted from the url
  sha256 "8a4fc27aa81ee061310d57fce2df9cc45f3149ddb00bdfab2b816beb0359b13d"
  license "GPL-2.0"
  revision 3

  bottle do
    root_url "https://github.com/DilumAluthge/homebrew-tap/releases/download/pijul-1.0.0-beta.11_3"
    sha256 cellar: :any, arm64_tahoe:   "2bbb4a40dc128f2bee90c11e90419b99ba21040929d8965a4b47be8b96f6f3ea"
    sha256 cellar: :any, arm64_sequoia: "cb7cd11ef12ff9dfcecdbf9c6a33ad5da26ddc1db5e21f562c52a8c229c7d26b"
    sha256 cellar: :any, arm64_sonoma:  "cdc36cf3d3bcecde23969872d6354e984463f32b888c484d84ddadac14481220"
    sha256 cellar: :any, x86_64_linux:  "580d6bdf8a5ece6d7b4e043dc5bb25da898b274ee2fe95920eae6f52d19e0f85"
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
