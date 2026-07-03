# The pijul formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License for the formula code in `Homebrew/homebrew-core`: BSD (that's not the license for the Pijul software itself)

class Pijul < Formula
  desc "Patch-based distributed version control system"
  # Web page: https://pijul.org
  # Crate: https://crates.io/crates/pijul
  homepage "https://docs.rs/crate/pijul"
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.14.crate"
  # version is automatically extracted from the url
  sha256 "186ffba86b172f450ea9771779e611446faf46ef3e06daf2a95402af3cea284d"
  license "GPL-2.0"
  # revision 0

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul-1.0.0-beta.14"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:   "b1bc9d394281567dbda2d232d1c451caec107cadf03f1903f3a6a8cb29effb33"
    sha256 cellar: :any, arm64_sequoia: "3ba531ea2640534f3131bdcb29d4be7a656c96f883db63dda7d5215b407fca8a"
    sha256 cellar: :any, arm64_sonoma:  "9255707b08887b0cffc99e69f9d01a55f5fbc720da5ee5c6a87429a3398d45b8"
    sha256 cellar: :any, x86_64_linux:  "252fab3a7a0c67782b9b6027642a95c8aea9bfaa1b86dfb36663605b6d968a82"
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
