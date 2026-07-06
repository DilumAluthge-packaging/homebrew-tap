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
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul@0.15-0.15.0"
    sha256 cellar: :any, arm64_tahoe:   "05fafa34d41457a71e97125fb63a3196008739acf2b6d75fb1d95f66458dded2"
    sha256 cellar: :any, arm64_sequoia: "d543da82d31c4cec1f134d4f4da0c1310ed3a59caf09f73b37115dd4a3c7ad84"
    sha256 cellar: :any, arm64_sonoma:  "1ab3a2b8518b0b5d61fa3f3caf28948b4c78e7af313b43caff2870aa9ed62847"
    sha256 cellar: :any, x86_64_linux:  "8796e9389d5e178e0ae3b74db559be57dcf5f5ed4e749abc13cb2c5ef686bf58"
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
