class MakensisAT251 < Formula
  desc "System to create Windows installers"
  homepage "https://nsis.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nsis/NSIS%202/2.51/nsis-2.51-src.tar.bz2"
  sha256 "43d4c9209847e35eb6e2c7cd5a7586e1445374c056c2c7899e40a080e17a1be7"
  license "Zlib"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "edd2d0dcc5ca368334522b123210e7d9d3336efc5e0091f12500fa02a8e304d8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "065f088b4c9681f571c8e73b76bcd730ac34b5ab86ac011707d31b28479b8533"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "71dd1af5b0c2c9a040bac2d58965ba3141dbb2c23a95f36d7ad7fb2b2e1b40fa"
    sha256 cellar: :any_skip_relocation, sonoma: "985171f35c2c617499f333b4926367ee656660b85e9a83c045a691633e1af9d1"
    sha256 cellar: :any_skip_relocation, ventura: "b41b708bb2a20b5f006d3123070d7a9d16c02796201a86fa5456b7673a299994"
    sha256 cellar: :any_skip_relocation, arm64_linux: "232ea0628f6282522669f5d4763bfe740ce920696e1f4fb0e5c68f4eabc186c3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2c8e1672901d8376fcbcc0579302f0338629852fde0a262cdab694613fe89785"
  end

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsis/NSIS%202/2.51/nsis-2.51.zip"
    sha256 "43065a52a586166174c87294ae322baef898af8b782019e8a7ffd625f64f8e35"
  end

  # scons appears to have no builtin way to override the compiler selection,
  # and the only options supported on OS X are 'gcc' and 'g++'.
  # Use the right compiler by forcibly altering the scons config to set these
  patch :DATA

  def install
    args = [
      "PREFIX_DOC=#{share}/nsis/Docs",
      "SKIPUTILS=Makensisw,NSIS Menu,zip2exe",
      # Don't strip, see https://github.com/Homebrew/homebrew/issues/28718
      "STRIP=0",
      "VERSION=#{version}",
    ]

    args << "NSIS_CONFIG_LOG=yes" if build.with? "advanced-logging"
    args << "NSIS_MAX_STRLEN=8192" if build.with? "large-strings"
    args << "DEBUG=1" if build.with? "debug"
    args << "APPEND_LINKFLAGS=-Wl,-rpath,#{rpath}" if OS.linux?

    system "scons", "makensis", *args

    install_path = if build.with? "debug"
      "build/udebug/makensis/makensis"
    else
      "build/urelease/makensis/makensis"
    end

    bin.install install_path
    (share/"nsis").install resource("nsis")
  end

  test do
    # Workaround for https://sourceforge.net/p/nsis/bugs/1165/
    ENV["LANG"] = "en_GB.UTF-8"
    %w[COLLATE CTYPE MESSAGES MONETARY NUMERIC TIME].each do |lc_var|
      ENV["LC_#{lc_var}"] = "en_GB.UTF-8"
    end

    system "#{bin}/makensis", "-VERSION"
    system "#{bin}/makensis", "-HDRINFO"
    system "#{bin}/makensis", "#{share}/nsis/Examples/bigtest.nsi", "-XOutfile /dev/null"
  end
end

__END__
diff --git a/SCons/config.py b/SCons/config.py
index a344456..37c575b 100755
--- a/SCons/config.py
+++ b/SCons/config.py
@@ -1,3 +1,5 @@
+import os
+
 Import('defenv')

 ### Configuration options
@@ -440,6 +442,9 @@ Help(cfg.GenerateHelpText(defenv))
 env = Environment()
 cfg.Update(env)

+defenv['CC'] = os.environ['CC']
+defenv['CXX'] = os.environ['CXX']
+
 def AddValuedDefine(define):
   defenv.Append(NSIS_CPPDEFINES = [(define, env[define])])
