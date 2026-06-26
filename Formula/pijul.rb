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
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.15.crate"
  # version is automatically extracted from the url
  sha256 "67f7aa09d89b58698b30d3f71ed6edbdc2450dcc80c485aa484d5c02143ac326"
  license "GPL-2.0"
  # revision 0

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul-1.0.0-beta.14_1"
    sha256 cellar: :any, arm64_tahoe:   "b8dc2683c33f5f40d1a81db1b6431640e7b4ecb4c5858a66e1da6f8da2ced724"
    sha256 cellar: :any, arm64_sequoia: "aa59413f587c6840e12cd1f2a30e663433b1dbc0afee1174d8899595e26ab65e"
    sha256 cellar: :any, arm64_sonoma:  "fb78600635b65454c4605953785dd50fe46a70c19bb11c4cc2eece43e8f497c8"
    sha256 cellar: :any, x86_64_linux:  "d4651ce7c9434c95188074282cb9c491569833a87deea457e3db63437c941614"
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
    system bin/"pijul", "init"
    %w[haunted house].each { |f| touch testpath/f }
    assert_equal "No tracked files\n", shell_output("#{bin}/pijul ls")
    system bin/"pijul", "add", "haunted", "house"
    assert_equal "haunted\nhouse\n", shell_output("#{bin}/pijul ls")

    begin
      # Need to set up an SSH keypair and SSH agent for testing, because `pijul identity new` requires it
      ssh_dir = testpath/".ssh"
      mkdir ssh_dir
      chmod 0700, ssh_dir
      key = ssh_dir/"pijul-test-key"
      system "ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", key
      shell_output("ssh-agent -s").scan(/^(SSH_AUTH_SOCK|SSH_AGENT_PID)=([^;]+);/).each do |name, value|
        ENV[name] = value
      end
      system "ssh-add", key

      system bin/"pijul", "identity", "new",
             "--no-link",
             "--display-name", "Test User",
             "--email", "noreply@example.com"
      system bin/"pijul", "record", "--all",
             "--message='Initial patch'",
             "--author='Test User <noreply@example.com>'"
      assert_equal "haunted\nhouse\n", shell_output("#{bin}/pijul ls")
    ensure
      system "ssh-agent", "-k" if ENV["SSH_AGENT_PID"]
    end
  end
end
