# frozen_string_literal: true

module PijulTest
  def run_pijul_tests
    (testpath/"testdir-main").mkpath

    cd testpath/"testdir-main" do
      system bin/"pijul", "init"

      %w[haunted house].each do |f|
        touch f
      end

      assert_equal "No tracked files\n", shell_output("#{bin}/pijul ls")

      system bin/"pijul", "add", "haunted", "house"
      assert_equal "haunted\nhouse\n", shell_output("#{bin}/pijul ls")

      begin
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
               "--message=Initial patch",
               "--author=Test User <noreply@example.com>"

        assert_equal "haunted\nhouse\n", shell_output("#{bin}/pijul ls")

        (testpath/"testdir-upstream-988").mkpath
        cd testpath/"testdir-upstream-988" do
          system bin/"pijul", "clone", "https://nest.pijul.com/pijul/pijul"
          assert_predicate testpath/"testdir-upstream-988"/"pijul", :directory?
          assert_predicate testpath/"testdir-upstream-988"/"pijul/Cargo.toml", :file?
        end
      ensure
        system "ssh-agent", "-k" if ENV["SSH_AGENT_PID"]
      end
    end
  end
end
