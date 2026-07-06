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
  url "https://static.crates.io/crates/pijul/pijul-1.0.0-beta.17.crate"
  # version is automatically extracted from the url
  sha256 "81e9a6685477a853d0025b0ecc174848b449b7f5f527c1520ce0a1da76732b73"
  license "GPL-2.0"
  revision 1

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/pijul-1.0.0-beta.17_1"
    sha256 cellar: :any, arm64_tahoe:   "cbc29f739478a46760170283a5d45853764fa42af6e7b437ad9a140b4b3019f4"
    sha256 cellar: :any, arm64_sequoia: "4f08ab5df00295198eba90b1c671c7b5eddff13fba3a59acb39760c47b5bdb8e"
    sha256 cellar: :any, arm64_sonoma:  "9b15994a9b7f555acd69276c2536930aa19283635ed0e605e8c292730bf366e5"
    sha256 cellar: :any, x86_64_linux:  "6a7967ec579994fcf488387ac4765872945b3fdb49f1b2727db34088fc0400fd"
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
    (testpath/"testdir-main").mkpath
    cd testpath/"testdir-main"
    system bin/"pijul", "init"
    %w[haunted house].each do |f|
      touch f
    end
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

      # Regression test for https://nest.pijul.com/pijul/pijul/discussion/988
      # (#988 "Bug with pijul clone https://")
      (testpath/"testdir-upstream-988").mkpath
      cd testpath/"testdir-upstream-988" do
        system bin/"pijul", "clone", "https://nest.pijul.com/pijul/pijul"
        assert_predicate testpath/"testdir-upstream-988"/"pijul", :directory?
        assert_predicate testpath/"testdir-upstream-988"/"pijul/Cargo.toml", :file?
      end
    ensure
      system "ssh-agent", "-k" if ENV["SSH_AGENT_PID"]
    end
    # ^^^ begin
  end
  # ^^^ test
end
# ^^^ class
