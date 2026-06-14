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
  revision 1

  bottle do
    root_url "https://github.com/DilumAluthge/homebrew-tap/releases/download/pijul-1.0.0-beta.12_1"
    sha256 cellar: :any, arm64_tahoe:   "70d58109115a4721c226f24227735e78c738f498d86aae1149661f02b2f5c349"
    sha256 cellar: :any, arm64_sequoia: "509736d3d02721d2e421a9de7ce3873c3d049f54575a346837705c65faf169f4"
    sha256 cellar: :any, arm64_sonoma:  "e280891b1cdf71af0a7f7fd0b4fd54b50fe9ea77328c932d7b3a396068d11e95"
    sha256 cellar: :any, x86_64_linux:  "16a21b818c8676cae8302a8c50ed5eadf44094acdd363a4a6603871e7db4e0fa"
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
