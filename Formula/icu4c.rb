class Icu4c < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/"
  url "https://ssl.icu-project.org/files/icu4c/61.1/icu4c-61_1-src.tgz"
  mirror "https://downloads.sourceforge.net/project/icu/ICU4C/61.1/icu4c-61_1-src.tgz"
  version "61.1"
  sha256 "d007f89ae8a2543a53525c74359b65b36412fa84b3349f1400be6dcf409fafef"
  head "https://ssl.icu-project.org/repos/icu/trunk/icu4c/", :using => :svn

  bottle do
    cellar :any
    sha256 "be8b3ba9420c4da1a75b2e6ebb7a0b835e2919d6499216383f0f313b1d9bb26b" => :high_sierra
    sha256 "07bad03c12d39c9216caa94ff85a2308ab187417d667f59cba9bc727eddcf2ec" => :sierra
    sha256 "5c24ef444ff69c23872efeca53ee9dc98a67c141d4a162bc1349d8bd73a79cd8" => :el_capitan
    sha256 "9b2c0602e87376bb08ad8e79ada8befa5c33556b3def9b10419ca1764556d6eb" => :x86_64_linux
  end

  keg_only :provided_by_macos, "macOS provides libicucore.dylib (but nothing else)"

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j24" if ENV["CIRCLECI"]

    args = %W[--prefix=#{prefix} --disable-samples --disable-tests --enable-static]
    args << "--with-library-bits=64" if MacOS.prefer_64_bit?

    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    if File.readable? "/usr/share/dict/words"
      system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
    else
      (testpath/"hello").write "hello\nworld\n"
      system "#{bin}/gendict", "--uchars", "hello", "dict"
    end
  end
end
