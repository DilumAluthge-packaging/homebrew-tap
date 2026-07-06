# The pijul formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/21702ef2c02ae7a5d925de7aed6defd0beefa93d
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License for the formula code in `Homebrew/homebrew-core`: BSD (that's not the license for the Pijul software itself)

class PijulAT015 < Formula
  desc "Patch-based distributed version control system"
  # Web page: https://pijul.org
  # Crate: https://crates.io/crates/pijul
  homepage "https://docs.rs/crate/pijul"
  url "https://static.crates.io/crates/pijul/pijul-0.15.0.crate"
  # version is automatically extracted from the url
  sha256 "51d7b44e03f2c428fea010318fea041fae3a1b9a6946aa79cf8c152707959157"
  license "GPL-2.0-or-later"
  revision 1

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul@0.15-0.15.0_1"
    sha256 cellar: :any, arm64_tahoe:   "b500b0522c3a40f50477466cbe039b09dcb13503379891704a64f1f2cd281f44"
    sha256 cellar: :any, arm64_sequoia: "5c36a653ffce9e9fee36de06c6c115ab99865e612383b6ce0c2c46026bac7512"
    sha256 cellar: :any, arm64_sonoma:  "361944dabdd9eea5c93aa3c2b2fca971d80a267c0c3f5e1c641b6f7b6aa0a2dc"
    sha256 cellar: :any, x86_64_linux:  "8ec9bddc8dda7d2e681c9373cd83f2e8e0b6d9c487a0d1bbdbd594140777034f"
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
    system bin/"pijul", "init"
    %w[haunted house].each { |f| touch testpath/f }
    assert_equal "No tracked files\n", shell_output("#{bin}/pijul ls")
    system bin/"pijul", "add", "haunted", "house"
    assert_equal "haunted\nhouse\n", shell_output("#{bin}/pijul ls")

    begin
      # Need to set up an SSH keypair and SSH agent for testing, because `pijul identity new` requires it
      #
      # Basically, the dependency tree looks like this:
      # 1. We want to test that `pijul record` works
      # 2. `pijul record` depends on having an identity already exist
      # 3. In order to create an identity, we have to run `pijul identity new`
      # 4. `pijul identity new` depends on an SSH keypair and SSH agent being available
      # Therefore, in order to test `pijul record`, we need to have an SSH keypair and SSH agent available
      # during inside the sandbox.
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
