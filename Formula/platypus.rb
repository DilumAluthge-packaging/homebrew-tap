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
  url "https://github.com/sveinbjornt/Platypus/archive/refs/tags/v5.5.0.tar.gz"
  # version is automatically extracted from the url
  sha256 "4a12806aef43d13f67a6d55c765da6209b42543b421fadacaf3a2462c3e6221c"
  license "BSD-3-Clause"
  revision 3

  depends_on "base64" => :build
  depends_on "make" => :build
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
    # https://github.com/DilumAluthge/homebrew-tap/issues/18
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

    # # Regression test for https://github.com/DilumAluthge/homebrew-tap/issues/18
    # File.open("my_platypus_test_script.bash", "w") do |f|
    #   f.write('#!/usr/bin/env bash\n')
    #   f.write('\n')
    #   f.write('echo "Hello, Platypus on macOS!"\n')
    #   f.write('read -p "Press Enter to exit"\n')
    # end
    # ENV["TMPDIR"] = ENV["HOMEBREW_TEMP"] + "/"
    # refute_path_exists "./MyPlatypusTestApp.app/Contents/Info.plist"
    # system bin/"platypus",
    #        "-a", "MyPlatypusTestApp",
    #        "-o", "Text Window",
    #        "./my_platypus_test_script.bash",
    #        "./MyPlatypusTestApp.app"
    # assert_path_exists "./MyPlatypusTestApp.app/Contents/Info.plist"
    # ENV["TMPDIR"] = nil
  end
end
