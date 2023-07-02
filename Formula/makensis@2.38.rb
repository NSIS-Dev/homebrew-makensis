class MakensisAT238 < Formula
  desc "System to create Windows installers"
  homepage "https://nsis.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nsis/NSIS%202/2.38/nsis-2.38-src.tar.bz2"
  sha256 "1493ea75ebacfd92066b8fb8f495d9c422a642953b92d08108bf9da8a5c047f3"
  license "Zlib"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "fc4524675c0efffcdedcc5bb92d348afa0577c33fd69e1ef75a8da48cf0c6e90"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4e9d197faa2cb6ee296902f69def0deb0dcc30db077cc6ff2943e12a5c4bdb3c"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "4656747f66941fb5b2f4adaad2c4bdd64e99a48c1938a580f91befce75700c4d"
    sha256 cellar: :any_skip_relocation, ventura:        "4532aeda1faa4cd83fe4c881f34a59dc87e4e24d69b1b6b196ac16e84ede3a21"
    sha256 cellar: :any_skip_relocation, monterey:       "e4df4ea446eaf4b905b3e9f102a133894cb36d7b33620be03b5374fa59703975"
    sha256 cellar: :any_skip_relocation, big_sur:        "21f3aa213be2e8c0a0a2d992fb117cc5e5c5cf625b3299bcf1f7506c117900f5"
    sha256 cellar: :any_skip_relocation, catalina:       "0e86809dd3b7c95a587bc467a7b12a2ab07cacf91f31ead7174fffe3cc1d7c6f"
    sha256 cellar: :any_skip_relocation, mojave:         "d2c3aeb784d8aa8192360a20a7410b5b4f617deae10d59b18535cafa2bc5809f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ed7437e47f43473d9a9a81652697d21373f11346401fc7a20d0a35357ca73ea8"
  end

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsis/NSIS%202/2.38/nsis-2.38.zip"
    sha256 "82ef0aa78bfbf482ed691cab5af47cb16085614e7fe7a319acf36071f1a2603e"
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
