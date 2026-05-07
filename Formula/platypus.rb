# The platypus formula was removed from homebrew-core in
# https://github.com/Homebrew/homebrew-core/commit/d72fd20fcf630707a97b23316c2789d1b46fecb2
# This formula is based on the last version before removal
# Credit: Homebrew contributors
# License: BSD
#
# Parts of this formula are also based on:
# https://github.com/sveinbjornt/Platypus/blob/85196da49d3efe6e87f04b5963f732bcbb7d6c9b/wip/platypus.rb
# Credit: Sveinbjorn Thordarson, and other Platypus contributors
# License: BSD

class Platypus < Formula
  desc "Create macOS applications from {Perl,Ruby,sh,Python} scripts"
  homepage "https://sveinbjorn.org/platypus"
  # GitHub repo: https://github.com/sveinbjornt/Platypus
  url "https://github.com/sveinbjornt/Platypus.git",
      revision: "fda6025c28e4f6027be5ae757a144fedb629a537"
  version "5.6.0-dev.fda6025c28"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"
  license "BSD-3-Clause"
  # revision 0

  bottle do
    root_url "https://github.com/DilumAluthge-packaging/homebrew-tap/releases/download/platypus-5.5.0_6"
    rebuild 1
    sha256 arm64_tahoe:   "870043487cdeff2c310bb64ea9b716410d87c2c09aec616f7cbdc0084e90deed"
    sha256 arm64_sequoia: "022eb2c5310a040c8e4ee07da35fd30c231e68d09dc6d5850f7934a2c29f6a50"
    sha256 arm64_sonoma:  "a4cca3ef29e97d8f8f6af34867c39ff110cc2e401b9d41a1800313564edd67c5"
    sha256 sequoia:       "f2fb66c79e9867119712fc1bbefcb1fed43ee8cb6f0132350042de77bbf2fcd0"
  end

  # make comes automatically when you install the Xcode CLT

  depends_on xcode: ["8.0", :build]
  depends_on :macos

  def install
    # Parts of this section are based on:
    # https://github.com/sveinbjornt/Platypus/blob/85196da49d3efe6e87f04b5963f732bcbb7d6c9b/wip/platypus.rb
    # Credit: Sveinbjorn Thordarson, and other Platypus contributors

    # Fix hardcoded paths in Common.h to point to Homebrew's share directory
    # This ensures the 'platypus' tool can find 'ScriptExec' and 'MainMenu.nib'
    inreplace "Common.h" do |s|
      s.gsub! "/usr/local/share/platypus", pkgshare
    end

    if Hardware::CPU.intel?
      # Necessary to make Platypus compile on Intel
      ENV.delete("HOMEBREW_OPTFLAGS")
    end

    # Build Platypus
    system "make", "build_unsigned"

    # Install the executable
    bin.install "products/platypus_clt" => "platypus"

    # Install the man page
    man1.install "CLT/man/platypus.1"

    # Install the helper app and resources to #{pkgshare} (share directory)
    #
    # Without this, platypus is not runnable
    # https://github.com/DilumAluthge-packaging/homebrew-tap/issues/18
    # https://github.com/Homebrew/homebrew-core/issues/18734
    cd "products/ScriptExec.app/Contents" do
      pkgshare.install "Resources/MainMenu.nib", "MacOS/ScriptExec"
    end
  end

  def caveats
    <<~EOS
      This formula only installs the command-line Platypus tool, not the GUI.

      The GUI can be downloaded from the Platypus website:
        https://sveinbjorn.org/platypus
    EOS
  end

  test do
    system bin/"platypus", "--version"
    system bin/"platypus", "--help"

    # Regression test for https://github.com/DilumAluthge-packaging/homebrew-tap/issues/18
    File.open("my_platypus_test_script.bash", "w") do |f|
      f.write('#!/usr/bin/env bash\n')
      f.write('\n')
      f.write('echo "Hello, Platypus on macOS!"\n')
      f.write('read -p "Press Enter to exit"\n')
    end
    ENV["TMPDIR"] = ENV["HOMEBREW_TEMP"] + "/"
    refute_path_exists "./MyPlatypusTestApp.app/Contents/Info.plist"
    system bin/"platypus",
           "-a", "MyPlatypusTestApp",
           "-o", "Text Window",
           "./my_platypus_test_script.bash",
           "./MyPlatypusTestApp.app"
    assert_path_exists "./MyPlatypusTestApp.app/Contents/Info.plist"
    ENV["TMPDIR"] = nil
  end
end
