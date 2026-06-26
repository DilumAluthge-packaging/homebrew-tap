# The pijul formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License: BSD

class Pijul < Formula
  desc "Patch-based distributed version control system"
  # Web page: https://pijul.org
  # Crate: https://crates.io/crates/pijul
  homepage "https://docs.rs/crate/pijul"
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.13.crate"
  # version is automatically extracted from the url
  sha256 "d5f8e59409b31bfa76a3b45c0e076f5852a4eb6b3134497b9a902927bdd6f9bf"
  license "GPL-2.0"
  revision 1

  bottle do
    root_url "https://github.com/DilumAluthge/homebrew-tap/releases/download/pijul-1.0.0-beta.13_1"
    sha256 cellar: :any, arm64_tahoe:   "546748e0d09141e3f1e15895f23b893761c017f73d88a39edc18828ef8940a83"
    sha256 cellar: :any, arm64_sequoia: "81a17128112b03fbf130449d117a594e0408bf85d43939c791073efd2a0ba7e1"
    sha256 cellar: :any, arm64_sonoma:  "574a5e839f9d00dcb732537eca5ca5188560fcaa0886baf9c7962749a9e80e39"
    sha256 cellar: :any, x86_64_linux:  "173384d0cf9b31b942a3972641ac28145b116287a82d0123133e1bb07b48a86c"
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
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@3")

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
