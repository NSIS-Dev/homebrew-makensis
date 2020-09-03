class MakensisAT237 < Formula
  desc "System to create Windows installers"
  homepage "https://nsis.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nsis/NSIS%202/2.37/nsis-2.37-src.tar.bz2"
  sha256 "7d1238d543d304c2a74b0ff62e4178b895af161c6dcb7e3df9932379662ab6ed"

  livecheck do
    url :stable
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "889d630bf8637f68e90a9591a373ee44bde8d9d6a9395171e024fdced27f26ef" => :catalina
    sha256 "b40f5a388f0dddeb2c3d274bdc43fbba6cc0a9f613d056f0981bc60350252448" => :mojave
    sha256 "fe92934c874a27ead142b769d1c1258c6fd3baa66f2f005cad3f57ccd759734f" => :high_sierra
  end

  option "with-advanced-logging", "Enable advanced logging of all installer actions"
  option "with-large-strings", "Enable strings up to 8192 characters instead of default 1024"
  option "with-debug", "Build executables with debugging information"

  depends_on "scons" => :build

  resource "nsis" do
    url "https://downloads.sourceforge.net/project/nsis/NSIS%202/2.37/nsis-2.37.zip"
    sha256 "64c07e7b5da4f474a3d80ef35e62a03a69db6c2bd0215b4582e8eb562efae1d6"
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

    system "scons", "makensis", *args
    channel = build.with? "debug" ? "debug" : "release"
    bin.install "build/u#{channel}/makensis/makensis"
    (share/"nsis").install resource("nsis")
  end

  test do
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
